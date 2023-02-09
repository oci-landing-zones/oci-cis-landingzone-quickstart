# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_id" {}
variable "user_id" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "private_key_password" {}
variable "home_region" {}

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
    children    = map(object({
      name          = string
      description   = string
      defined_tags  = map(string)
      freeform_tags = map(string)
      children      = map(object({
        name          = string
        description   = string
        defined_tags  = map(string)
        freeform_tags = map(string)
        children      = map(object({
          name          = string
          description   = string
          defined_tags  = map(string)
          freeform_tags = map(string)
          children      = map(object({
            name          = string
            description   = string
            defined_tags  = map(string)
            freeform_tags = map(string)
            children      = map(object({
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
  type = bool
  default = true
}

variable "parent_compartment_id" {
  description = "Compartment where the workload compartment will be created in."
  type = string
  default = ""
}

variable "landing_zone_prefix" {
    description = "Prefix used in your CIS Landing Zone deployment."
    type = string
    default = ""
}

variable "workload_compartment_name" {
  description = "Compartment Name of the workload compartment."
  type = string
  default = "app-workload-cmp"
}

variable "workload_compartment_user_group_name" {
  description = "OCI User group associated with the workload compartment."
  type = string
  default = ""
}


variable "create_database_compartment" {
  description = "Whether a database compartment is created to support the workload."
  type = bool
  default = true
}

variable "database_compartment_name" {
  description = "Compartment Name of the database compartment for the workload."
  type = string
  default = "app-db-workload-cmp"
}

variable "database_workload_compartment_user_group_name" {
    description = "OCI User group associated with workload database compartment."
    type = string
    default = ""
}
