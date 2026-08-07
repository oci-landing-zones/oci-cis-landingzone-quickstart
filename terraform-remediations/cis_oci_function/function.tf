# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_functions_application" "this" {
  #Required
  compartment_id = local.function_compartment_ocid
  display_name   = "${local.function_name}-function-application"
  subnet_ids     = [var.deploy_infra_for_subnet ? oci_core_subnet.this[0].id : var.existing_subnet_ocid]
  shape          = local.application_shape
  config         = local.function_config
}

resource "oci_artifacts_container_repository" "this" {
  count          = var.create_repository ? 1 : 0
  compartment_id = local.repository_compartment_ocid
  display_name   = local.function_repository_name
  is_public      = false
}

resource "oci_objectstorage_bucket" "cis_reports" {
  count                 = var.deploy_output_bucket ? 1 : 0
  compartment_id        = local.output_bucket_compartment_ocid
  namespace             = data.oci_objectstorage_namespace.namespace.namespace
  name                  = local.output_bucket_name
  access_type           = "NoPublicAccess"
  object_events_enabled = false
  storage_tier          = "Standard"
}

resource "oci_functions_function" "this" {
  depends_on = [
    null_resource.deploy_function_image,
    oci_ons_subscription.html_reports_email
  ]

  application_id                   = oci_functions_application.this.id
  display_name                     = "${local.function_name}-function"
  image                            = local.function_image
  config                           = local.function_config
  memory_in_mbs                    = local.function_memory
  timeout_in_seconds               = local.function_timeout
  detached_mode_timeout_in_seconds = var.detached_mode_timeout_in_seconds
}

resource "terraform_data" "validate_ocir_credentials" {
  input = {
    auth_token_secret_ocid = trimspace(var.ocir_auth_token_secret_ocid)
    direct_username        = trimspace(var.ocir_username)
  }

  lifecycle {
    precondition {
      condition     = trimspace(var.ocir_username) != "" && trimspace(var.ocir_auth_token_secret_ocid) != ""
      error_message = "Provide ocir_username and ocir_auth_token_secret_ocid."
    }
  }
}

resource "null_resource" "deploy_function_image" {
  depends_on = [
    oci_artifacts_container_repository.this,
    oci_identity_policy.ocir_vault_deployment,
    terraform_data.validate_ocir_credentials
  ]

  triggers = {
    container_cli      = var.container_cli
    container_platform = local.container_platform
    image              = local.function_image
    source_hash        = local.function_source_hash
    version            = local.function_version
  }
  provisioner "local-exec" {
    command = local.ocir_login_command
    environment = {
      OCIR_AUTH_TOKEN_SECRET_OCID = trimspace(var.ocir_auth_token_secret_ocid)
      OCIR_TENANCY_NAMESPACE      = data.oci_objectstorage_namespace.namespace.namespace
      OCIR_USERNAME               = var.ocir_username
    }
  }
  provisioner "local-exec" {
    command     = "${var.container_cli} build --platform ${local.container_platform} -t ${local.function_name}:${local.function_version} ."
    working_dir = var.function_working_dir
  }
  provisioner "local-exec" {
    command     = "${var.container_cli} tag ${local.function_name}:${local.function_version} ${local.function_image}"
    working_dir = var.function_working_dir
  }
  provisioner "local-exec" {
    command     = "${var.container_cli} push ${local.function_image}"
    working_dir = var.function_working_dir
  }
}

resource "null_resource" "wait" {
  depends_on = [oci_functions_function.this]
  count      = local.invoke_function_enabled ? 1 : 0
  provisioner "local-exec" {
    command = "sleep 30" # Wait some time before invoking the function
  }
}

resource "terraform_data" "current_time" {
  count = local.invoke_function_enabled ? 1 : 0
  input = timestamp()
}

resource "oci_functions_invoke_function" "this" {
  depends_on  = [null_resource.wait] # Wait some time before invoking the function
  count       = local.invoke_function_enabled ? 1 : 0
  function_id = oci_functions_function.this.id

  invoke_function_body  = var.invoke_function_body
  fn_invoke_type        = var.invoke_function_fn_invoke_type
  base64_encode_content = false
  lifecycle {
    replace_triggered_by = [terraform_data.current_time[0]]
  }
}
