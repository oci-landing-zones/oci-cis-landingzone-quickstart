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
  type = string
  description = "The tenancy home region."
}
variable "unique_prefix" {
  type = string
  description = "A unique prefix across the tenancy that is added to all resource names created by this module."  
  validation {
    condition     = length(regexall("^[A-Za-z][A-Za-z0-9]{1,7}$", var.unique_prefix)) > 0
    error_message = "The unique_prefix variable is required and must contain alphanumeric characters only, start with a letter and 8 character max."
  }
}
variable "use_existing_provisioning_group" {
    type = bool
    default = false
    description = "Whether or not an existing group will be used for Landing Zone provisioning. If unchecked, one group is created for each compartment defined by enclosing_compartment_names variable."
}
variable "existing_provisioning_group_name" {
    type    = string
    default = ""
    description = "The name of an existing group to be used for provisioning all resources in the compartments defined by enclosing_compartment_names variable. Ignored if use_existing_provisioning_group is false."
}
variable "enclosing_compartment_names" {
    type    = list(string)
    default = []
    description = "The names of the enclosing compartments that will be created to hold Landing Zone compartments. If not provided, one compartment is created with default name <unique_prefix>-top-cmp. Max number of compartments is 5."
    validation {
        condition     = length(var.enclosing_compartment_names) <= 5
        error_message = "Max number of values exceeded for enclosing_compartment_names. Max number is 5."
    }
}
variable "existing_enclosing_compartments_parent_ocid" {
    type    = string
    default = ""
    description = "The enclosing compartments parent compartment. It defines where enclosing compartments are created. If not provided, the enclosing compartments are created in the root compartment."
}
variable "use_existing_lz_groups" {
    type = bool
    default = false
    description = "Whether or not existing groups are to be reused for Landing Zone. If unchecked, one set of groups is created for each compartment defined by enclosing_compartment_names variable. If checked, existing group names must be provided and this single set will be able to manage resources in all those compartments."
}
variable "create_tenancy_level_policies" {
    type = bool
    default = true
    description = "Whether or not policies for Landing Zone groups are created at the root compartment. If unchecked, Landing Zone groups will not be able to manage resources at the root compartment level."
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