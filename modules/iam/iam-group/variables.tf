# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_ocid" {
  description = "The OCID of the tenancy. "
}

variable "group_name" {
  description = "The name you assign to the group during creation. The name must be unique across all compartments in the tenancy. "
}

variable "group_description" {
  description = "The description you assign to the Group. Does not have to be unique, and it's changeable. "
  default = ""
}
variable "user_names" {
  description = "List of user names. "
  default     = []
}

variable "policy_name" {
  description = "The name you assign to the policy during creation.  "
}

variable "policy_description" {
  description = "The description you assign to the policy. Does not have to be unique, and it's changeable. "
  default = ""
}

variable "policy_statements" {
  description = "Define policy consists of one or more policy statements. "
  default     = []
}

variable "policy_compartment_id" {
  description = "The compartment id assign to policy."
}