# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_objectstorage_namespace" "namespace" {}

data "oci_identity_regions" "these" {}

data "oci_identity_tenancy" "this" {
  tenancy_id = var.tenancy_ocid
}

data "oci_core_services" "these" {}

locals {
  regions_map         = { for r in data.oci_identity_regions.these.regions : r.key => r.name } # All regions indexed by region key.
  regions_map_reverse = { for r in data.oci_identity_regions.these.regions : r.name => r.key } # All regions indexed by region name.
  home_region_key     = data.oci_identity_tenancy.this.home_region_key                         # Home region key obtained from the tenancy data source
  region_key          = lower(local.regions_map_reverse[trimspace(var.region)])                # Region key obtained from the region name

  osn_cidrs = { for s in data.oci_core_services.these.services : s.cidr_block => s.id }

  function_compartment_ocid = var.deploy_compartment ? oci_identity_compartment.this[0].id : var.existing_compartment_ocid
  function_compartment_name = var.deploy_compartment ? oci_identity_compartment.this[0].name : data.oci_identity_compartment.this.name

  function_vcn_compartment_ocid = coalesce(var.new_vcn_compartment_ocid, local.function_compartment_ocid)

  function_descriptor = yamldecode(file("${var.function_working_dir}/func.yaml"))
  function_name       = local.function_descriptor.name
  function_version    = local.function_descriptor.version
  function_memory     = try(local.function_descriptor.memory, 512)
  function_timeout    = coalesce(var.function_timeout_in_seconds, try(local.function_descriptor.timeout, null))
  application_shape        = var.force_arm_application_shape == true ? "GENERIC_ARM" : var.application_shape
  container_platform       = var.force_arm_application_shape == true ? "linux/arm64" : var.container_platform
  invoke_function_enabled = var.enable_post_deploy_invoke == true && var.invoke_function == true

  repository_compartment_ocid                  = try(trimspace(var.repository_compartment_ocid), "") != "" ? trimspace(var.repository_compartment_ocid) : local.function_compartment_ocid
  repository_name                              = trim(var.repository_name, "/")
  function_repository_name                     = "${local.repository_name}/${local.function_name}"
  function_image                               = "${local.region_key}.ocir.io/${data.oci_objectstorage_namespace.namespace.namespace}/${local.function_repository_name}:${local.function_version}"
  ocir_registry                                = "${local.region_key}.ocir.io"
  ocir_credentials_from_vault                  = var.use_ocir_vault_credentials == true
  ocir_username_secret_ocid                    = trimspace(var.ocir_username_secret_ocid)
  ocir_auth_token_secret_ocid                  = trimspace(var.ocir_auth_token_secret_ocid)
  ocir_vault_secret_compartment_ocid            = try(trimspace(var.ocir_vault_secret_compartment_ocid), "") != "" ? trimspace(var.ocir_vault_secret_compartment_ocid) : local.function_compartment_ocid
  ocir_vault_deployment_policy_compartment_ocid = try(trimspace(var.ocir_vault_deployment_policy_compartment_ocid), "") != "" ? trimspace(var.ocir_vault_deployment_policy_compartment_ocid) : local.ocir_vault_secret_compartment_ocid
  ocir_vault_deployment_principal_type          = trimspace(var.ocir_vault_deployment_principal_type)
  ocir_vault_deployment_principal_name          = trimspace(var.ocir_vault_deployment_principal_name)
  ocir_vault_deployment_principal_placeholder   = local.ocir_vault_deployment_principal_type == "dynamic-group" ? "<deployment-dynamic-group>" : "<deployment-group>"
  ocir_vault_deployment_policy_principal        = local.ocir_vault_deployment_principal_name != "" ? local.ocir_vault_deployment_principal_name : local.ocir_vault_deployment_principal_placeholder
  ocir_vault_secret_id_condition                = "where any {target.secret.id = '${local.ocir_username_secret_ocid}', target.secret.id = '${local.ocir_auth_token_secret_ocid}'}"
  ocir_vault_deployment_policy_statement        = "Allow ${local.ocir_vault_deployment_principal_type} ${local.ocir_vault_deployment_policy_principal} to read secret-bundles in compartment id ${local.ocir_vault_secret_compartment_ocid} ${local.ocir_vault_secret_id_condition}"
  ocir_login_command                            = <<-EOT
    set -eu

    decode_secret() {
      secret_id="$1"
      secret_label="$2"

      encoded_content="$(oci secrets secret-bundle get --secret-id "$secret_id" --query 'data."secret-bundle-content".content' --raw-output)" || {
        echo "Unable to retrieve $secret_label from OCI Vault. Verify that the value is a Secret resource OCID beginning with ocid1.vaultsecret and that the deployment principal can read its secret bundle." >&2
        return 1
      }

      [ -n "$encoded_content" ] || {
        echo "OCI Vault returned empty content for $secret_label." >&2
        return 1
      }

      printf '%s' "$encoded_content" | python3 -c 'import base64,sys; sys.stdout.write(base64.b64decode(sys.stdin.read().strip(), validate=True).decode("utf-8"))'
    }

    if [ "$OCIR_USE_VAULT_CREDENTIALS" = "true" ]; then
      command -v oci >/dev/null 2>&1 || { echo "OCI CLI is required when use_ocir_vault_credentials is true." >&2; exit 1; }
      command -v python3 >/dev/null 2>&1 || { echo "python3 is required to decode OCI Vault secret bundle content." >&2; exit 1; }
      ocir_user="$(decode_secret "$OCIR_USERNAME_SECRET_OCID" "the OCI Registry username secret")"
      ocir_token="$(decode_secret "$OCIR_AUTH_TOKEN_SECRET_OCID" "the OCI Registry auth token secret")"
    else
      ocir_user="$OCIR_USERNAME"
      ocir_token="$OCIR_PASSWORD"
    fi

    [ -n "$ocir_user" ] || { echo "The OCI Registry username is empty." >&2; exit 1; }
    [ -n "$ocir_token" ] || { echo "The OCI Registry auth token is empty." >&2; exit 1; }

    printf '%s' "$ocir_token" | ${var.container_cli} login ${local.ocir_registry} --username "$OCIR_TENANCY_NAMESPACE/$ocir_user" --password-stdin
  EOT

  function_source_files = fileset(var.function_working_dir, "**")
  function_source_hash  = sha256(join("", [for source_file in sort(local.function_source_files) : filesha256("${var.function_working_dir}/${source_file}")]))

  output_bucket_compartment_ocid = try(trimspace(var.output_bucket_compartment_ocid), "") != "" ? trimspace(var.output_bucket_compartment_ocid) : local.function_compartment_ocid
  output_bucket_name             = try(trimspace(var.output_bucket_name), "") != "" ? trimspace(var.output_bucket_name) : replace("${local.function_name}-${local.region_key}-reports", "_", "-")

  html_report_notification_enabled    = var.enable_html_report_notifications == true
  html_report_notification_email      = trimspace(var.notification_email)
  html_report_notification_topic_name = try(trimspace(var.html_notification_topic_name), "") != "" ? (
    trimspace(var.html_notification_topic_name)
  ) : replace("${local.function_name}-${local.region_key}-html-notifications", "_", "-")

  function_default_config = {
    output_bucket                                      = local.output_bucket_name
    regions_to_run_in                                  = var.regions_to_run_in
    raw_data                                           = tostring(var.report_raw_data)
    obp                                                = tostring(var.report_obp)
    script_version                                     = var.script_version
    report_level                                       = tostring(var.report_level)
    report_summary_json                                = tostring(var.report_summary_json)
    all_resources                                      = tostring(var.report_all_resources)
    redact_output                                      = tostring(var.redact_output)
    html_notification_enabled                          = tostring(local.html_report_notification_enabled)
    html_notification_topic_id                         = local.html_report_notification_enabled ? oci_ons_notification_topic.html_reports[0].id : ""
    html_notification_topic_endpoint                   = local.html_report_notification_enabled ? oci_ons_notification_topic.html_reports[0].api_endpoint : ""
    html_notification_object_storage_namespace          = data.oci_objectstorage_namespace.namespace.namespace
    html_notification_object_storage_region             = var.region
    html_notification_output_bucket_compartment_id      = local.output_bucket_compartment_ocid
    html_notification_output_bucket_compartment_name    = local.output_bucket_compartment_ocid == local.function_compartment_ocid ? (
      data.oci_identity_compartment.this.name
    ) : ""
  }
  function_override_config = try(trimspace(var.function_parameters_json_string), "") != "" ? { for k, v in jsondecode(var.function_parameters_json_string) : trimspace(k) => trimspace(tostring(v)) } : {}
  function_config          = merge(local.function_default_config, local.function_override_config)

  resource_scheduler_recurrence_details = try(trimspace(var.resource_scheduler_recurrence_details), "") != "" ? trimspace(var.resource_scheduler_recurrence_details) : (
    var.resource_scheduler_recurrence_type == "CRON" ? "0 0 * * *" : "FREQ=${var.resource_scheduler_frequency};INTERVAL=${var.resource_scheduler_interval}"
  )
  resource_scheduler_time_starts        = var.resource_scheduler_start_time_mode == "SELECTED_DATE_TIME" ? "${var.resource_scheduler_start_year}-${var.resource_scheduler_start_month}-${var.resource_scheduler_start_day}T${var.resource_scheduler_start_hour}:${var.resource_scheduler_start_minute}:00Z" : null
  resource_scheduler_time_ends          = var.resource_scheduler_end_time_mode == "SELECTED_DATE_TIME" ? "${var.resource_scheduler_end_year}-${var.resource_scheduler_end_month}-${var.resource_scheduler_end_day}T${var.resource_scheduler_end_hour}:${var.resource_scheduler_end_minute}:00Z" : null
}
