# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_compartment" "this" {
  provider = oci.home
  id       = local.function_compartment_ocid
}

resource "oci_identity_compartment" "this" {
  provider       = oci.home
  count          = var.deploy_compartment ? 1 : 0
  name           = var.new_compartment_name
  description    = "Compartment for OCI functions"
  compartment_id = var.new_compartment_parent_ocid
}

resource "oci_identity_dynamic_group" "this" {
  provider       = oci.home
  count          = var.deploy_dyn_group_and_policy ? 1 : 0
  compartment_id = var.tenancy_ocid
  matching_rule  = var.enable_resource_scheduler ? "ANY {ALL {resource.type = 'fnfunc', resource.compartment.id = '${local.function_compartment_ocid}'}, ALL {resource.type = 'resourceschedule'}}" : "ALL {resource.type = 'fnfunc', resource.compartment.id = '${local.function_compartment_ocid}'}"
  name           = var.dynamic_group_name
  description    = "Dynamic group for OCI functions"
}

locals {
  policy_dynamic_group_name   = var.deploy_dyn_group_and_policy ? oci_identity_dynamic_group.this[0].name : var.dynamic_group_name
  short_policy_fragments      = [for p in split(",", try(trimspace(var.policy_statements_short), "")) : trimspace(p) if trimspace(p) != ""]
  use_short_policy_statements = var.provide_short_policy_statements == true && length(local.short_policy_fragments) > 0

  dynamic_group_policy_statements = local.use_short_policy_statements ? [
    for p in local.short_policy_fragments : "Allow dynamic-group ${local.policy_dynamic_group_name} to ${p} in compartment ${data.oci_identity_compartment.this.name}"
  ] : [
    for p in split("\n", try(trimspace(var.policy_statements_full), "")) : replace(trimspace(p), "$${dynamic_group_name}", local.policy_dynamic_group_name) if trimspace(p) != ""
  ]

  policy_compartment_override       = try(trimspace(var.policy_compartment_ocid), "")
  effective_policy_compartment_ocid = local.use_short_policy_statements ? local.function_compartment_ocid : (
    local.policy_compartment_override != "" ? local.policy_compartment_override : var.tenancy_ocid
  )

  output_bucket_policy_statements = var.deploy_output_bucket_policy ? [
    "Allow dynamic-group ${local.policy_dynamic_group_name} to read buckets in compartment id ${local.output_bucket_compartment_ocid} where target.bucket.name = '${local.output_bucket_name}'",
    "Allow dynamic-group ${local.policy_dynamic_group_name} to manage objects in compartment id ${local.output_bucket_compartment_ocid} where target.bucket.name = '${local.output_bucket_name}'"
  ] : []
  html_notification_bucket_policy_statements = var.enable_html_report_notifications && !var.deploy_output_bucket_policy ? [
    "Allow dynamic-group ${local.policy_dynamic_group_name} to read buckets in compartment id ${local.output_bucket_compartment_ocid} where target.bucket.name = '${local.output_bucket_name}'",
    "Allow dynamic-group ${local.policy_dynamic_group_name} to read objects in compartment id ${local.output_bucket_compartment_ocid} where target.bucket.name = '${local.output_bucket_name}'"
  ] : []
  html_notification_policy_statements = var.enable_html_report_notifications ? [
    "Allow dynamic-group ${local.policy_dynamic_group_name} to manage buckets in compartment id ${local.output_bucket_compartment_ocid} where target.bucket.name = '${local.output_bucket_name}'",
    "Allow dynamic-group ${local.policy_dynamic_group_name} to use ons-family in compartment id ${local.function_compartment_ocid}"
  ] : []
  faas_ocir_pull_policy_statements = var.create_faas_ocir_pull_policy ? [
    "Allow service faas to read repos in compartment id ${local.repository_compartment_ocid}"
  ] : []
  function_resource_scheduler_policy_statements = var.enable_resource_scheduler ? [
    "Allow dynamic-group ${local.policy_dynamic_group_name} to manage resource-schedule-family in tenancy",
    "Allow dynamic-group ${local.policy_dynamic_group_name} to manage functions-family in tenancy"
  ] : []
  policy_statements = concat(
    local.dynamic_group_policy_statements,
    local.output_bucket_policy_statements,
    local.html_notification_bucket_policy_statements,
    local.html_notification_policy_statements,
    local.faas_ocir_pull_policy_statements,
    local.function_resource_scheduler_policy_statements
  )

}

resource "oci_identity_policy" "this" {
  provider       = oci.home
  count          = var.deploy_dyn_group_and_policy ? 1 : 0
  compartment_id = local.effective_policy_compartment_ocid
  description    = "Policy required for OCI functions."
  name           = var.policy_name
  statements     = local.policy_statements
}

resource "oci_identity_policy" "ocir_vault_deployment" {
  provider       = oci.home
  count          = var.create_ocir_vault_deployment_policy && local.ocir_credentials_from_vault ? 1 : 0
  compartment_id = local.ocir_vault_deployment_policy_compartment_ocid
  description    = "Allows the deployment principal to read the OCI Vault secret bundles used for OCI Registry login."
  name           = var.ocir_vault_deployment_policy_name
  statements     = [local.ocir_vault_deployment_policy_statement]

  lifecycle {
    precondition {
      condition     = local.ocir_vault_deployment_principal_name != ""
      error_message = "Provide ocir_vault_deployment_principal_name when create_ocir_vault_deployment_policy is true."
    }
  }
}
