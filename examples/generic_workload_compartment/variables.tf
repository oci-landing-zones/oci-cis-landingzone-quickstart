# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
# ------------------------------------------------------
# ----- Environment
# ------------------------------------------------------
variable "tenancy_ocid" {}
variable "user_ocid" {}
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

#-------------------------------------------------------------
#-- Arbitrary compartments topology
#-------------------------------------------------------------
variable "compartments" {
  description = "The compartments structure, given as a map of objects nested up to 6 levels."
  type = map(object({
    name          = string
    description   = string
    parent_id     = string
    defined_tags  = map(string)
    freeform_tags = map(string)
    children = map(object({
      name          = string
      description   = string
      defined_tags  = map(string)
      freeform_tags = map(string)
      children = map(object({
        name          = string
        description   = string
        defined_tags  = map(string)
        freeform_tags = map(string)
        children = map(object({
          name          = string
          description   = string
          defined_tags  = map(string)
          freeform_tags = map(string)
          children = map(object({
            name          = string
            description   = string
            defined_tags  = map(string)
            freeform_tags = map(string)
            children = map(object({
              name          = string
              description   = string
              defined_tags  = map(string)
              freeform_tags = map(string)
            }))
          }))
        }))
      }))
    }))
  }))
  default = {}
}

variable "enable_compartments_delete" {
  description = "Whether compartments are physically deleted upon destroy."
  type        = bool
  default     = true
}

variable "existing_lz_enclosing_compartment_ocid" {
  description = "Compartment where the workload compartment will be created in."
  type        = string
  default     = ""
}

variable "existing_lz_security_compartment_ocid" {
  description = "Existing CIS Landing Zone Security Compartment"
  type        = string
  default     = ""
}

variable "existing_lz_network_compartment_ocid" {
  description = "Existing CIS Landing Zone Network Compartment"
  type        = string
  default     = ""
}

variable "service_label" {
  description = "Prefix used in your CIS Landing Zone deployment."
  type        = string
  default     = ""
}

variable "workload_compartment_name" {
  description = "Compartment Name of the workload compartment."
  type        = string
  default     = "app-workload-cmp"
}

variable "existing_appdev_admin_group_name" {
  type    = string
  default = ""
}
variable "existing_database_admin_group_name" {
  type    = string
  default = ""
}

variable "database_compartment_name" {
  description = "Compartment Name of the database compartment for the workload."
  type        = string
  default     = "app-db-workload-cmp"
}

variable "create_database_compartment" {
  description = "Whether a database compartment is created to support the workload."
  type        = bool
  default     = false
}

variable "workload_team_manages_database" {
  description = "Select this if your workload team "
  
}