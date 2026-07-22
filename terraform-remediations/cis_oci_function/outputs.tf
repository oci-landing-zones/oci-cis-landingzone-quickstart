# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_core_vcn" "this" {
  count  = var.deploy_infra_for_subnet ? 0 : 1
  vcn_id = var.existing_vcn_ocid
}

data "oci_core_subnet" "this" {
  count     = var.deploy_infra_for_subnet ? 0 : 1
  subnet_id = var.existing_subnet_ocid
}

output "functions_compartment_id" {
  description = "The OCID of the functions compartment."
  value       = local.function_compartment_ocid
}

output "functions_compartment_name" {
  description = "The name of the function compartment."
  value       = local.function_compartment_name
}

output "functions_dyn_group_name" {
  description = "The name of the dynamic group for functions."
  value       = var.deploy_dyn_group_and_policy ? oci_identity_dynamic_group.this[0].name : null
}

output "functions_dyn_group_id" {
  description = "The OCID of the dynamic group for functions."
  value       = var.deploy_dyn_group_and_policy ? oci_identity_dynamic_group.this[0].id : null
}

output "functions_policy_name" {
  description = "The name of the function policy."
  value       = var.deploy_dyn_group_and_policy ? oci_identity_policy.this[0].name : null
}

output "functions_policy_id" {
  description = "The OCID of the function policy."
  value       = var.deploy_dyn_group_and_policy ? oci_identity_policy.this[0].id : null
}

output "vcn_id" {
  description = "The VCN OCID."
  value       = var.deploy_infra_for_subnet ? oci_core_vcn.this[0].id : data.oci_core_vcn.this[0].id
}

output "vcn_name" {
  description = "The VCN name."
  value       = var.deploy_infra_for_subnet ? oci_core_vcn.this[0].display_name : data.oci_core_vcn.this[0].display_name
}

output "private_subnet_id" {
  description = "The private subnet OCID."
  value       = var.deploy_infra_for_subnet ? oci_core_subnet.this[0].id : data.oci_core_subnet.this[0].id
}

output "private_subnet_name" {
  description = "The private subnet name."
  value       = var.deploy_infra_for_subnet ? oci_core_subnet.this[0].display_name : data.oci_core_subnet.this[0].display_name
}

output "function_application_id" {
  description = "The OCID of the newly created Function application."
  value       = oci_functions_application.this.id
}

output "function_application_name" {
  description = "The name of the newly created Function application."
  value       = oci_functions_application.this.display_name
}

output "function_id" {
  description = "The OCID of the newly created Function."
  value       = oci_functions_function.this.id
}

output "function_name" {
  description = "The name of the newly created Function."
  value       = oci_functions_function.this.display_name
}

output "function_invoke_endpoint" {
  description = "The base https invoke URL to set on a client in order to invoke a function. This URL will never change over the lifetime of the function and can be cached."
  value       = oci_functions_function.this.invoke_endpoint
}

output "function_image" {
  description = "The OCIR image deployed by the function."
  value       = local.function_image
}

output "function_repository_name" {
  description = "The OCIR repository name used by the function image."
  value       = local.function_repository_name
}

output "ocir_vault_secret_compartment_id" {
  description = "The compartment OCID expected to contain the Vault secrets used for OCI Registry login."
  value       = local.ocir_credentials_from_vault ? local.ocir_vault_secret_compartment_ocid : null
}

output "ocir_vault_deployment_policy_statement" {
  description = "Minimal pre-apply IAM policy statement needed by the deployment principal to read the OCI Registry Vault secret bundles."
  value       = local.ocir_credentials_from_vault ? local.ocir_vault_deployment_policy_statement : null
}

output "ocir_vault_deployment_policy_id" {
  description = "The OCID of the optional policy granting deployment-time access to the OCI Registry Vault secret bundles."
  value       = var.create_ocir_vault_deployment_policy && local.ocir_credentials_from_vault ? oci_identity_policy.ocir_vault_deployment[0].id : null
}

output "output_bucket_name" {
  description = "The Object Storage bucket where CIS reports are written."
  value       = local.output_bucket_name
}

output "output_bucket_compartment_id" {
  description = "The compartment OCID of the Object Storage bucket where CIS reports are written."
  value       = local.output_bucket_compartment_ocid
}

output "function_invocation_test_output" {
  description = "Value of the function invocation test_output."
  value       = local.invoke_function_enabled ? oci_functions_invoke_function.this[0].content : null
}

output "function_log_group_id" {
  description = "The OCID of the function log group."
  value       = var.enable_function_logging ? oci_logging_log_group.this[0].id : null
}

output "function_log_group_name" {
  description = "The name of the function log group."
  value       = var.enable_function_logging ? oci_logging_log_group.this[0].display_name : null
}

output "function_log_id" {
  description = "The OCID of the function log."
  value       = var.enable_function_logging ? oci_logging_log.this[0].id : null
}

output "function_log_name" {
  description = "The name of the function log."
  value       = var.enable_function_logging ? oci_logging_log.this[0].display_name : null
}

output "resource_scheduler_schedule_id" {
  description = "The OCID of the OCI Resource Scheduler schedule."
  value       = var.enable_resource_scheduler ? oci_resource_scheduler_schedule.cis_reports[0].id : null
}

output "resource_scheduler_schedule_name" {
  description = "The display name of the OCI Resource Scheduler schedule."
  value       = var.enable_resource_scheduler ? oci_resource_scheduler_schedule.cis_reports[0].display_name : null
}

output "resource_scheduler_schedule_next_run" {
  description = "The next run time for the OCI Resource Scheduler schedule."
  value       = var.enable_resource_scheduler ? oci_resource_scheduler_schedule.cis_reports[0].time_next_run : null
}

output "html_notification_topic_name" {
  description = "The Notifications topic used for generated cis_summary_report.html emails."
  value       = var.enable_html_report_notifications ? oci_ons_notification_topic.html_reports[0].name : null
}

output "html_notification_topic_id" {
  description = "The OCID of the Notifications topic used for generated cis_summary_report.html emails."
  value       = var.enable_html_report_notifications ? oci_ons_notification_topic.html_reports[0].id : null
}

output "html_notification_subscription_id" {
  description = "The OCID of the email subscription used for generated cis_summary_report.html emails."
  value       = var.enable_html_report_notifications ? oci_ons_subscription.html_reports_email[0].id : null
}
