variable "tenancy_ocid" {
  description = "The OCID of the tenancy. "
}

variable "compartment_name" {
  description = "The name you assign to the compartment during creation. The name must be unique across all compartments in the tenancy. "
}

// The description is only used if compartment_create = true.
variable "compartment_description" {
  description = "The description you assign to the compartment. Does not have to be unique, and it's changeable. "
  default = ""
}

variable "compartment_create" {
  description = "Create the compartment or not. If true, the compartment will be managed by this module, and the user must have permissions to create the compartment; If false, compartment data will be returned about the compartment if it exists, if not found, then an empty string will be returned for the compartment ID."
  default     = true
}
