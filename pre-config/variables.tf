# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

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
variable "home_region" {
  type        = string
  description = "The tenancy home region."
}
variable "unique_prefix" {
  type        = string
  description = "A unique prefix across the tenancy that is added to all resource names created by this module."
  default     = ""
  validation {
    condition     = length(var.unique_prefix) == 0 || length(regexall("^[A-Za-z][A-Za-z0-9]{1,15}$", var.unique_prefix)) > 0
    error_message = "Validation failed for unique_prefix: if provided, value must contain alphanumeric characters only, start with a letter and 16 character max."
  }
}
#Advanced options check box used in schema.yml
variable "advanced_options" {
  type        = bool
  default     = false
}

variable "use_existing_provisioning_group" {
  type        = bool
  default     = false
  description = "Whether or not an existing group will be used for Landing Zone provisioning. If false, one group is created for each compartment defined by enclosing_compartment_names variable."
}
variable "existing_provisioning_group_name" {
  type        = string
  default     = ""
  description = "The name of an existing group to be used for provisioning all resources in the compartments defined by enclosing_compartment_names variable. Ignored if use_existing_provisioning_group is false."
}
variable "enclosing_compartment_names" {
    type    = list(string)
    default = []
    description = "The names of the enclosing compartments that will be created to hold Landing Zone compartments. If not provided, one compartment is created with default name <unique_prefix>-top-cmp."
}
variable "existing_enclosing_compartments_parent_ocid" {
  type        = string
  default     = ""
  description = "The enclosing compartments parent compartment. It defines where enclosing compartments are created. If not provided, the enclosing compartments are created in the root compartment."
}
variable "use_existing_groups" {
  type        = bool
  default     = false
  description = "Whether or not existing groups are to be reused for Landing Zone. If false, one set of groups is created for each compartment defined by enclosing_compartment_names variable. If checked, existing group names must be provided and this single set will be able to manage resources in all those compartments."
}
variable "grant_services_policies" {
  type        = bool
  default     = true
  description = "Whether services policies should be granted. If these policies already exist in the root compartment, set it to false for avoiding policies duplication. Services policies are required by some OCI services, like Cloud Guard, Vulnerability Scanning and OS Management."
}
variable "existing_iam_admin_group_name" {
  type    = string
  default = ""
}
variable "existing_cred_admin_group_name" {
  type    = string
  default = ""
}
variable "existing_security_admin_group_name" {
  type    = string
  default = ""
}
variable "existing_network_admin_group_name" {
  type    = string
  default = ""
}
variable "existing_appdev_admin_group_name" {
  type    = string
  default = ""
}
variable "existing_database_admin_group_name" {
  type    = string
  default = ""
}
variable "existing_auditor_group_name" {
  type    = string
  default = ""
}
variable "existing_announcement_reader_group_name" {
    type    = string
    default = ""
}
variable "existing_exainfra_admin_group_name" {
    type    = string
    default = ""
}

variable "existing_cost_admin_group_name" {
  type    = string
  default = ""
}

variable "existing_security_fun_dyn_group_name" {
  type    = string
  default = ""
  description = "Existing dynamic group to be used by security functions."
}

variable "existing_appdev_fun_dyn_group_name" {
  type    = string
  default = ""
  description = "Existing dynamic group to be used by application related functions."
}

variable "existing_compute_agent_dyn_group_name" {
  type    = string
  default = ""
  description = "Existing dynamic group to be used by Compute's management agent."
}

variable "existing_database_kms_dyn_group_name" {
  type    = string
  default = ""
  description = "Existing dynamic group to be used by databases to manage vaults and keys."
}  
