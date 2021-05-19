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
  description = "Unique prefix added to all resource names created by this module."  
  validation {
    condition     = length(regexall("^[A-Za-z][A-Za-z0-9]{1,7}$", var.unique_prefix)) > 0
    error_message = "The unique_prefix variable is required and must contain alphanumeric characters only, start with a letter and 8 character max."
  }
}
variable "use_existing_provisioning_group" {
    type = bool
    default = false
    description = "Whether or not an existing group is to be used for Landing Zone provisioning. If false, a group is created for each compartment indicated by enclosing_compartment_names variable. In either case, required provsioning permissions are granted to the group(s)."
}
variable "existing_provisioning_group_name" {
    type    = string
    default = ""
    description = "The existing group name to be used for Landing Zone provisioning. Ignored if use_existing_provisioning_group is false."
}
variable "enclosing_compartment_names" {
    type    = list(string)
    default = []
    description = "The names of the enclosing compartments that will be created for Landing Zone compartments. If not provided, one compartment is created with default name <unique_prefix>-top-cmp."
}
variable "existing_enclosing_compartment_parent_ocid" {
    type    = string
    default = ""
    description = "The ocid of the enclosing compartment's parent compartment. It defines where the enclosing compartment is created. If not provided, the enclosing compartment is created in the root compartment."
}
variable "use_existing_lz_groups" {
    type = bool
    default = false
    description = "Whether or not existing Landing Zone groups are to be reused. If false, groups are created for each compartment indicated by enclosing_compartment_names variable. If true, existing group names must be provided."
}
variable "create_tenancy_level_policies" {
    type = bool
    default = true
    description = "Whether or not tenancy level policies for Landing Zone groups are created."
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