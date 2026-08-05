# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_ocid" {
  description = "The tenancy OCID for deployment of IAM resources."
}

variable "user_ocid" {
  default = ""
}
variable "fingerprint" {
  default = ""
}
variable "private_key_path" {
  default = ""
}
variable "private_key_password" {
  default = ""
}

variable "region" {
  description = "The region where the resources are deployed."
}

variable "show_advanced_options" {
  description = "Resource Manager UI toggle for advanced OCI controls. This variable is informational only."
  type        = bool
  default     = false
}

variable "deploy_compartment" {
  description = "If true, a compartment is deployed for the function. If false, a compartment must be provided in the variable 'existing_compartment_ocid'."
  type        = bool
  default     = true
}

variable "existing_compartment_ocid" {
  description = "The existing compartment OCID where functions are deployed."
  type        = string
  default     = null
}

variable "new_compartment_parent_ocid" {
  description = "The existing compartment OCID chosen as the parent of the new function compartment."
  type        = string
  default     = null
}

variable "new_compartment_name" {
  description = "The new compartment name."
  type        = string
  default     = "function-cmp"
}

variable "deploy_dyn_group_and_policy" {
  description = "If true, a dynamic group and a policy are deployed for the function. Otherwise, it is assumed the required dynamic group and policy have already been created."
  type        = bool
  default     = true
}

variable "dynamic_group_name" {
  description = "Dynamic group name"
  type        = string
  default     = "function-iam-dynamic-group"
}

variable "policy_name" {
  description = "Policy name"
  type        = string
  default     = "function-iam-policy"
}

variable "provide_short_policy_statements" {
  description = "If true, policy statement must be provided in variable 'policy_statements_short'. If false, the policy statements must be provided in the variable 'policy_statements_free'."
  type        = bool
  default     = false
}

variable "policy_statements_short" {
  description = "Policy statements in short form, with only <verb> <resource>. Use this variable for providing <verb> <resource> combinations for creating basic policy statements (allow dynamic-group <dyn-group-name> to <verb> <resource> in compartment <function-compartment>) in the provided function compartment. Within each expanded statement, the grantee is always the dynamic group name provided in the variable 'dynamic_group_name', and the compartment name is then one referred by 'existing_compartment_ocid' or given by 'new_compartment_name' variable."
  type        = string
  default     = ""
}

variable "policy_statements_full" {
  description = "Policy statements in full format. Use this variable for providing complex statements when required by the function per OCI requirements. When using this variable, you must provide the full statements, as the module will not make any expansions."
  type        = string
  default     = <<EOT
Allow dynamic-group $${dynamic_group_name} to inspect all-resources in tenancy
Allow dynamic-group $${dynamic_group_name} to read instances in tenancy
Allow dynamic-group $${dynamic_group_name} to read load-balancers in tenancy
Allow dynamic-group $${dynamic_group_name} to read buckets in tenancy
Allow dynamic-group $${dynamic_group_name} to read nat-gateways in tenancy
Allow dynamic-group $${dynamic_group_name} to read public-ips in tenancy
Allow dynamic-group $${dynamic_group_name} to read file-family in tenancy
Allow dynamic-group $${dynamic_group_name} to read instance-configurations in tenancy
Allow dynamic-group $${dynamic_group_name} to read network-security-groups in tenancy
Allow dynamic-group $${dynamic_group_name} to read resource-availability in tenancy
Allow dynamic-group $${dynamic_group_name} to read audit-events in tenancy
Allow dynamic-group $${dynamic_group_name} to read users in tenancy
Allow dynamic-group $${dynamic_group_name} to read vss-family in tenancy
Allow dynamic-group $${dynamic_group_name} to read usage-budgets in tenancy
Allow dynamic-group $${dynamic_group_name} to read usage-reports in tenancy
Allow dynamic-group $${dynamic_group_name} to read data-safe-family in tenancy
Allow dynamic-group $${dynamic_group_name} to read vaults in tenancy
Allow dynamic-group $${dynamic_group_name} to read keys in tenancy
Allow dynamic-group $${dynamic_group_name} to read tag-namespaces in tenancy
Allow dynamic-group $${dynamic_group_name} to use ons-family in tenancy where any {request.operation!=/Create*/, request.operation!=/Update*/, request.operation!=/Delete*/, request.operation!=/Change*/}
EOT
}

variable "policy_compartment_ocid" {
  description = "Policy compartment OCID. By default, the policy is created in the compartment where the function is deployed."
  type        = string
  default     = null
}

variable "ocir_auth_token_secret_ocid" {
  description = "OCI Vault Secret resource OCID containing the OCI Registry auth token. It must begin with ocid1.vaultsecret; do not provide a Vault or encryption key OCID."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.ocir_auth_token_secret_ocid) != "" && can(regex("^ocid1\\.vaultsecret\\.", trimspace(var.ocir_auth_token_secret_ocid)))
    error_message = "ocir_auth_token_secret_ocid must be an OCI Vault Secret resource OCID beginning with 'ocid1.vaultsecret.'. Do not provide an 'ocid1.vault.' Vault OCID or 'ocid1.key.' encryption key OCID."
  }
}

variable "ocir_vault_secret_compartment_ocid" {
  description = "Compartment OCID containing the OCI Vault Secret for the OCI Registry auth token. Defaults to the function compartment and is used for the minimal secret-bundle read policy guidance."
  type        = string
  default     = null
}

variable "create_ocir_vault_deployment_policy" {
  description = "Create a narrow IAM policy that allows the deployment principal to read only the OCI Registry auth-token Secret bundle. The applying principal must already be allowed to manage policies in the policy compartment."
  type        = bool
  default     = false
}

variable "ocir_vault_deployment_principal_type" {
  description = "Principal type for the optional OCI Registry Vault credential read policy. Use 'group' for user/API-key/Cloud Shell deployments or 'dynamic-group' for resource-principal deployments."
  type        = string
  default     = "group"

  validation {
    condition     = contains(["group", "dynamic-group"], trimspace(var.ocir_vault_deployment_principal_type))
    error_message = "ocir_vault_deployment_principal_type must be either 'group' or 'dynamic-group'."
  }
}

variable "ocir_vault_deployment_principal_name" {
  description = "Group or dynamic group name to grant read access to the OCI Registry auth-token Secret bundle when create_ocir_vault_deployment_policy is true."
  type        = string
  default     = ""
}

variable "ocir_vault_deployment_policy_name" {
  description = "Name of the optional policy that grants the deployment principal read access to the OCI Registry auth-token Secret bundle."
  type        = string
  default     = "ocir-vault-secret-bundle-read-policy"
}

variable "ocir_vault_deployment_policy_compartment_ocid" {
  description = "Compartment OCID where the optional OCI Registry Vault deployment policy is created. Defaults to the Vault secret compartment."
  type        = string
  default     = null
}

variable "ocir_username" {
  description = "OCI Registry username used to push the function image. The tenancy namespace is added automatically during login."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.ocir_username) != ""
    error_message = "ocir_username must not be empty."
  }
}

variable "repository_name" {
  description = "The repository prefix in OCI registry. The final image repository is '<repository_name>/<function name>'."
  type        = string
  default     = "oci-cis-report"
}

variable "repository_compartment_ocid" {
  description = "Compartment OCID for the OCIR repository. Defaults to the function compartment."
  type        = string
  default     = null
}

variable "create_repository" {
  description = "Create the OCIR container repository before pushing the function image."
  type        = bool
  default     = true
}

variable "create_faas_ocir_pull_policy" {
  description = "Create a policy statement allowing OCI Functions service to read images from the OCIR repository compartment."
  type        = bool
  default     = true
}

variable "container_cli" {
  description = "Container CLI used to login, tag, and push the function image."
  type        = string
  default     = "docker"
}

variable "fn_cli" {
  description = "Deprecated. Kept only for compatibility with older variable sets."
  type        = string
  default     = "fn"
}

variable "container_platform" {
  description = "Container image platform used when building the function image."
  type        = string
  default     = "linux/arm64"
}

variable "function_working_dir" {
  description = "Function Working Directory"
  type        = string
  default     = "./src/cis-reports"
}

variable "application_shape" {
  description = "OCI Functions application shape."
  type        = string
  default     = "GENERIC_ARM"

  validation {
    condition     = contains(["GENERIC_X86", "GENERIC_ARM"], var.application_shape)
    error_message = "application_shape must be GENERIC_X86 or GENERIC_ARM."
  }
}

variable "force_arm_application_shape" {
  description = "Force the OCI Functions application shape to GENERIC_ARM. Keep true when building linux/arm64 images."
  type        = bool
  default     = true
}

variable "force_x86_application_shape" {
  description = "Deprecated. Kept only for compatibility with older Resource Manager variable sets."
  type        = bool
  default     = false
}

variable "deploy_infra_for_subnet" {
  description = "Deploy infra for subnet, including a VCN, the Subnet itself, a Security List, a Route Table, and a Service Gateway."
  type        = bool
  default     = true
}

variable "existing_vcn_compartment_ocid" {
  description = "Compartment for the existing VCN"
  type        = string
  default     = null
}

variable "existing_vcn_ocid" {
  description = "Existing VCN ID"
  type        = string
  default     = null
}

variable "existing_subnet_ocid" {
  description = "Existing subnet ID"
  type        = string
  default     = null
}

variable "new_vcn_compartment_ocid" {
  description = "Compartment for the new VCN"
  type        = string
  default     = null
}

variable "new_vcn_name" {
  description = "New VCN name"
  type        = string
  default     = "function-vcn"
}

variable "new_vcn_cidr" {
  description = "New VCN CIDR"
  type        = string
  default     = "10.0.0.0/29"
}

variable "new_subnet_name" {
  description = "New Subnet name"
  type        = string
  default     = "function-subnet"
}

variable "new_subnet_cidr" {
  description = "New Subnet CIDR"
  type        = string
  default     = "10.0.0.0/30"
}

variable "function_parameters_json_string" {
  description = "Additional or overriding function config parameters in JSON format."
  type        = string
  default     = null
}

variable "invoke_function" {
  description = "When true, the function is invoked after deployment. CIS report generation can be long-running, so this defaults to false."
  type        = bool
  default     = false
}

variable "enable_post_deploy_invoke" {
  description = "Safety switch for post-deploy invocation. Keep false for Resource Manager applies; set true with invoke_function only when intentionally testing invocation."
  type        = bool
  default     = false
}

variable "invoke_function_body" {
  description = "JSON body to send if invoke_function is true."
  type        = string
  default     = "{}"
}

variable "invoke_function_fn_invoke_type" {
  description = "Invoke type to use when invoke_function is true."
  type        = string
  default     = "detached"

  validation {
    condition     = contains(["sync", "detached"], var.invoke_function_fn_invoke_type)
    error_message = "invoke_function_fn_invoke_type must be sync or detached."
  }
}

variable "enable_function_logging" {
  description = "When true, function logging is enabled."
  type        = bool
  default     = true
}

variable "function_timeout_in_seconds" {
  description = "Function execution timeout in seconds. OCI Functions rejects values above 300 for normal invocations."
  type        = number
  default     = 300

  validation {
    condition     = var.function_timeout_in_seconds >= 30 && var.function_timeout_in_seconds <= 300
    error_message = "function_timeout_in_seconds must be between 30 and 300 seconds."
  }
}

variable "detached_mode_timeout_in_seconds" {
  description = "Detached invocation timeout for long-running CIS report generation."
  type        = number
  default     = 1800
}

variable "deploy_output_bucket" {
  description = "Create a private Object Storage bucket for CIS report output."
  type        = bool
  default     = true
}

variable "output_bucket_name" {
  description = "Object Storage bucket for report output. Defaults to '<function-name>-<region-key>-reports'."
  type        = string
  default     = null
}

variable "output_bucket_compartment_ocid" {
  description = "Compartment OCID for the output bucket. Defaults to the function compartment."
  type        = string
  default     = null
}

variable "deploy_output_bucket_policy" {
  description = "Add scoped bucket/object write policy statements for the function dynamic group."
  type        = bool
  default     = true
}

variable "enable_html_report_notifications" {
  description = "Create a notification topic and email subscription. The CIS function publishes a report-ready email with a 4-hour ObjectRead PAR after it creates cis_summary_report.html."
  type        = bool
  default     = false
}

variable "notification_email" {
  description = "Email address to subscribe to generated cis_summary_report.html notifications."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.notification_email) == "" || can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", trimspace(var.notification_email)))
    error_message = "notification_email must be blank or a valid email address."
  }
}

variable "html_notification_topic_name" {
  description = "Notification topic name used for generated cis_summary_report.html emails."
  type        = string
  default     = "cis-report-html-notifications"
}

variable "regions_to_run_in" {
  description = "Comma-separated OCI region names to scan. Empty string scans all subscribed regions."
  type        = string
  default     = ""
}

variable "report_level" {
  description = "CIS recommendation level to generate."
  type        = number
  default     = 2

  validation {
    condition     = contains([1, 2], var.report_level)
    error_message = "report_level must be 1 or 2."
  }
}

variable "report_raw_data" {
  description = "Generate raw resource CSV output."
  type        = bool
  default     = false
}

variable "script_version" {
  description = "CIS reports script version to run. Use latest for the current upstream main branch, bundled for a script packaged with the function image, or a release tag."
  type        = string
  default     = "latest"
}

variable "experimental_options_note" {
  description = "Visible Resource Manager note for experimental runtime options. This value is informational only."
  type        = string
  default     = "Note: These options are experimental. If executed in larger tenancies, results may not work as expected or may take a long time to complete. Use at your own risk."
}

variable "report_obp" {
  description = "Generate OCI best-practice checks."
  type        = bool
  default     = false
}

variable "report_summary_json" {
  description = "Generate the CIS summary JSON file."
  type        = bool
  default     = true
}

variable "report_all_resources" {
  description = "Use Search service to query all resources. This can increase runtime."
  type        = bool
  default     = false
}

variable "redact_output" {
  description = "Redact OCIDs in generated CSV and JSON output."
  type        = bool
  default     = false
}

variable "enable_resource_scheduler" {
  description = "Create an OCI Resource Scheduler schedule to run the CIS report function automatically."
  type        = bool
  default     = false
}

variable "resource_scheduler_display_name" {
  description = "Display name for the OCI Resource Scheduler schedule."
  type        = string
  default     = "cis-report-function-schedule"
}

variable "resource_scheduler_description" {
  description = "Description for the OCI Resource Scheduler schedule."
  type        = string
  default     = "Runs the OCI CIS report function on a recurring schedule."
}

variable "resource_scheduler_recurrence_type" {
  description = "Resource Scheduler recurrence type. ICAL uses the guided frequency and interval fields unless an advanced recurrence expression is provided."
  type        = string
  default     = "ICAL"

  validation {
    condition     = contains(["ICAL", "CRON"], var.resource_scheduler_recurrence_type)
    error_message = "resource_scheduler_recurrence_type must be ICAL or CRON."
  }
}

variable "resource_scheduler_frequency" {
  description = "ICAL FREQ value used to build the schedule recurrence."
  type        = string
  default     = "WEEKLY"

  validation {
    condition     = contains(["SECONDLY", "MINUTELY", "HOURLY", "DAILY", "WEEKLY", "MONTHLY", "YEARLY"], var.resource_scheduler_frequency)
    error_message = "resource_scheduler_frequency must be SECONDLY, MINUTELY, HOURLY, DAILY, WEEKLY, MONTHLY, or YEARLY."
  }
}

variable "resource_scheduler_interval" {
  description = "ICAL INTERVAL value used to build the schedule recurrence."
  type        = number
  default     = 1

  validation {
    condition     = var.resource_scheduler_interval >= 1 && var.resource_scheduler_interval <= 99
    error_message = "resource_scheduler_interval must be between 1 and 99."
  }
}

variable "resource_scheduler_recurrence_details" {
  description = "Advanced Resource Scheduler recurrence expression. Leave empty to build an ICAL expression from frequency and interval."
  type        = string
  default     = ""
}

variable "resource_scheduler_state" {
  description = "Target lifecycle state for the OCI Resource Scheduler schedule."
  type        = string
  default     = "ACTIVE"

  validation {
    condition     = contains(["ACTIVE", "INACTIVE"], var.resource_scheduler_state)
    error_message = "resource_scheduler_state must be ACTIVE or INACTIVE."
  }
}

variable "resource_scheduler_start_time_mode" {
  description = "Whether to omit an explicit schedule start time or build one from selected UTC date and time fields."
  type        = string
  default     = "NO_EXPLICIT_START"

  validation {
    condition     = contains(["NO_EXPLICIT_START", "SELECTED_DATE_TIME"], var.resource_scheduler_start_time_mode)
    error_message = "resource_scheduler_start_time_mode must be NO_EXPLICIT_START or SELECTED_DATE_TIME."
  }
}

variable "resource_scheduler_start_year" {
  description = "UTC year for the selected schedule start time."
  type        = string
  default     = "2026"
}

variable "resource_scheduler_start_month" {
  description = "UTC month for the selected schedule start time."
  type        = string
  default     = "01"
}

variable "resource_scheduler_start_day" {
  description = "UTC day for the selected schedule start time."
  type        = string
  default     = "01"
}

variable "resource_scheduler_start_hour" {
  description = "UTC hour for the selected schedule start time."
  type        = string
  default     = "00"
}

variable "resource_scheduler_start_minute" {
  description = "UTC minute for the selected schedule start time."
  type        = string
  default     = "00"
}

variable "resource_scheduler_end_time_mode" {
  description = "Whether to omit an explicit schedule end time or build one from selected UTC date and time fields."
  type        = string
  default     = "NO_EXPLICIT_END"

  validation {
    condition     = contains(["NO_EXPLICIT_END", "SELECTED_DATE_TIME"], var.resource_scheduler_end_time_mode)
    error_message = "resource_scheduler_end_time_mode must be NO_EXPLICIT_END or SELECTED_DATE_TIME."
  }
}

variable "resource_scheduler_end_year" {
  description = "UTC year for the selected schedule end time."
  type        = string
  default     = "2026"
}

variable "resource_scheduler_end_month" {
  description = "UTC month for the selected schedule end time."
  type        = string
  default     = "12"
}

variable "resource_scheduler_end_day" {
  description = "UTC day for the selected schedule end time."
  type        = string
  default     = "31"
}

variable "resource_scheduler_end_hour" {
  description = "UTC hour for the selected schedule end time."
  type        = string
  default     = "23"
}

variable "resource_scheduler_end_minute" {
  description = "UTC minute for the selected schedule end time."
  type        = string
  default     = "59"
}
