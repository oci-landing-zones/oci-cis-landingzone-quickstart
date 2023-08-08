# Copyright (c) 2023 Oracle and/or its affiliates.
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
# variable "compartments" {
#   description = "The compartments structure, given as a map of objects nested up to 6 levels."
#   type = map(object({
#     name          = string
#     description   = string
#     parent_id     = string
#     defined_tags  = map(string)
#     freeform_tags = map(string)
#     children = map(object({
#       name          = string
#       description   = string
#       defined_tags  = map(string)
#       freeform_tags = map(string)
#       children = map(object({
#         name          = string
#         description   = string
#         defined_tags  = map(string)
#         freeform_tags = map(string)
#         children = map(object({
#           name          = string
#           description   = string
#           defined_tags  = map(string)
#           freeform_tags = map(string)
#           children = map(object({
#             name          = string
#             description   = string
#             defined_tags  = map(string)
#             freeform_tags = map(string)
#             children = map(object({
#               name          = string
#               description   = string
#               defined_tags  = map(string)
#               freeform_tags = map(string)
#             }))
#           }))
#         }))
#       }))
#     }))
#   }))
#   default = {}
# }

variable "service_label" {
  description = "Prefix used in your CIS Landing Zone deployment."
  type        = string
  default     = ""
}

variable "enable_compartments_delete" {
  description = "Whether compartments are physically deleted upon destroy."
  type        = bool
  default     = true
}

variable "existing_lz_enclosing_compartment_ocid" {
  description = "Enclosing/parent compartment used in your CIS Landing Zone deployment."
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

variable "existing_lz_appdev_compartment_ocid" {
  description = "Existing CIS Landing Zone Appdev Compartment where new compartments will be created"
  type        = string
}


variable "workload_names" {
  description = "List of Workload Names, each workload will get a compartment created in the AppDev Compartment. If create workload groups and polices a group will be created for each workload name."
  type        = list
  
}

variable "create_workload_groups_and_policies" {
  description = "If select a group will be created to align to each workload group created."
  type = bool
  default = true
}

variable "create_workload_dynamic_groups_and_policies" {
  description = "If select a dynamic group for functions in the will be created to align to each workload group created."
  type = bool
  default = true
}


# variable "workload_team_manages_database" {
#   description = "Select this if your workload team "
  
# }