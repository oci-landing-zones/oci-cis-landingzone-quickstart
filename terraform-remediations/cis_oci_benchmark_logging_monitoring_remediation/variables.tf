# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
# ------------------------------------------------------
# ----- Environment
# ------------------------------------------------------
variable "tenancy_ocid" {}
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
  validation {
    condition     = length(trim(var.region, "")) > 0
    error_message = "Validation failed for region: value is required."
  }
}

# ------------------------------------------------------
# ----- Workload Specific 
# ------------------------------------------------------

variable "service_label" {
  validation {
    condition     = length(regexall("^[A-Za-z][A-Za-z0-9]{1,19}$", var.service_label)) > 0
    error_message = "Validation failed for service_label: value is required and must contain alphanumeric characters only, starting with a letter up to a maximum of 20 characters."
  }
}

variable "homeregion" {
  type        = bool
  description = "Home Region Deployment"
}

# ------------------------------------------------------
# ----- Cost Management - Budget
# ------------------------------------------------------
variable "budget_alert_threshold" {
  type        = number
  default     = 100
  description = "The threshold for triggering the alert expressed as a percentage. 100% is the default."
  validation {
    condition     = var.budget_alert_threshold > 0 && var.budget_alert_threshold < 10000
    error_message = "Validation failed for budget_alert_threshold: The threshold percentage should be greater than 0 and less than or equal to 10,000, with no leading zeros and a maximum of 2 decimal places."
  }
}
variable "budget_amount" {
  type        = number
  default     = 1000
  description = "The amount of the budget expressed as a whole number in the currency of the customer's rate card."
}
variable "create_budget" {
  type        = bool
  default     = false
  description = "Create a budget."
}
variable "budget_alert_email_endpoints" {
  type        = list(string)
  default     = []
  description = "List of email addresses for all cost related notifications."
  validation {
    condition     = length([for e in var.budget_alert_email_endpoints : e if length(regexall("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", e)) > 0]) == length(var.budget_alert_email_endpoints)
    error_message = "Validation failed budget_alert_email_endpoints: invalid email address."
  }
}

# ------------------------------------------------------
# ----- Events and Notifications
# ------------------------------------------------------
variable "enable_net_events" {
  type        = bool
  description = "Enable Network Event Notifications."
  default     = false
}

variable "network_admin_email_endpoints" {
  type        = list(string)
  default     = []
  description = "List of email addresses for all network related notifications."
  validation {
    condition     = length([for e in var.network_admin_email_endpoints : e if length(regexall("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", e)) > 0]) == length(var.network_admin_email_endpoints)
    error_message = "Validation failed for network_admin_email_endpoints: invalid email address."
  }
}

variable "compartment_id_for_net_events" {
  description = "The compartment where network events should reside will default to root."
  type        = string
  default     = null
}

variable "enable_iam_events" {
  type        = bool
  description = "Enable IAM Event Notifications"
  default     = false
}

variable "security_admin_email_endpoints" {
  type        = list(string)
  default     = []
  description = "List of email addresses for all security related notifications."
  validation {
    condition     = length([for e in var.security_admin_email_endpoints : e if length(regexall("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", e)) > 0]) == length(var.security_admin_email_endpoints)
    error_message = "Validation failed for security_admin_email_endpoints: invalid email address."
  }
}

variable "compartment_id_for_iam_events" {
  description = "The compartment where iam events should reside will default to root."
  type        = string
  default     = null
}

variable "create_alarms_as_enabled" {
  type        = bool
  default     = false
  description = "Creates alarm artifacts in disabled state when set to false."
}

variable "alarms_admin_email_endpoints" {
  type        = list(string)
  default     = []
  description = "List of email addresses for related notifications."
  validation {
    condition     = length([for e in var.alarms_admin_email_endpoints : e if length(regexall("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", e)) > 0]) == length(var.alarms_admin_email_endpoints)
    error_message = "Validation failed for alarms_admin_email_endpoints: invalid email address."
  }
}

variable "compartment_id_for_alarms" {
  description = "The compartment where alarm events should reside will default to root."
  type        = string
  default     = null
}


# ------------------------------------------------------
# ----- Cloud Guard
# ------------------------------------------------------
variable "configure_cloud_guard" {
  type        = bool
  description = "Determines whether the Cloud Guard service should be enabled. If true, Cloud Guard is enabled and the Root compartment is configured with a Cloud Guard target, as long as there is no pre-existing Cloud Guard target for the Root compartment (or target creation will fail)."
  default     = false
}

variable "cloud_guard_reporting_region" {
  description = "Cloud Guard reporting region, where Cloud Guard reporting resources are kept. If not set, it defaults to home region."
  type        = string
  default     = null
}

variable "compartment_id_for_cg_events" {
  description = "The compartment where Cloud Guard events should reside will default to root."
  type        = string
  default     = null
}

variable "cloudguard_email_endpoints" {
  type        = list(string)
  default     = []
  description = "List of email addresses for Cloud Guard related events."
  validation {
    condition     = length([for e in var.cloudguard_email_endpoints : e if length(regexall("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", e)) > 0]) == length(var.cloudguard_email_endpoints)
    error_message = "Validation failed for cloudguard_email_endpoints: invalid email address."
  }
}
