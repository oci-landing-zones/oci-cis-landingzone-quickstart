variable "tenancy_ocid" {
  description = "The OCID of the tenancy. "
}

variable "dynamic_group_name" {
  description = "The name you assign to the group during creation. The name must be unique across all compartments in the tenancy. "
}

// The description is only used if dynamic_group_create = true.
variable "dynamic_group_description" {
  description = "The description you assign to the Group. Does not have to be unique, and it's changeable. "
  default = ""
}

variable "dynamic_group_create" {
  description = "Create the group or not. If true, the user must have permissions to create the group; If false, group data will be returned about the group if it exists, if not found, then an empty string will be returned for the group ID."
  default     = true
}

variable "dynamic_group_rule" {
  description = "Define a matching rule or a set of matching rules to define the group members."
  default = ""
}

variable "policy_name" {
  description = "The name you assign to the policy during creation.  "
}

// The description is only used if policy_create = true.
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

variable "policy_create" {
  description = "Create the policy or not"
  default     = true
}
