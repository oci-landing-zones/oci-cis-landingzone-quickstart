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
    validation {
        condition     = length(trim(var.home_region,"")) > 0
        error_message = "The home_region variable is required."
  }
}
variable "unique_prefix" {
    validation {
        condition     = length(regexall("^[A-Za-z][A-Za-z0-9]{1,7}$", var.unique_prefix)) > 0
        error_message = "The unique_prefix variable is required and must contain alphanumeric characters only, start with a letter and 8 character max."
  }
}
variable "create_lz_provisioning_group" {
    default = true
}
variable "existing_provisioning_group_name" {
    default = null
}
variable "create_lz_groups" {
    default = true
}