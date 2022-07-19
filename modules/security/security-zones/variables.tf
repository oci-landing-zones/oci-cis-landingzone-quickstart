# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

#---------------------------------------------------------------
#--- Cloud Guard Security Zone Recipe variables ----------------
#---------------------------------------------------------------
variable "security_zones" {
  type = map(object({
    tenancy_ocid        = string
    service_label       = string
    compartment_id      = string
    description         = string
    security_policies   = list(string)
    cis_level           = string
    defined_tags        = map(string)
    freeform_tags       = map(string)
  }))
}  


# variable "tenancy_ocid" {
#     description = "The tenancy ocid."
#     type = string
# }

# variable "service_label" {
#     description = "The service label."
#     type = string
# }

# variable "compartment_id" {
#     description = "The compartment ocid where to create the Service Connector."
#     type = string
# }

# variable "display_name" {
#     description = "The Security Zone display name."
#     type = string
#     default = "security-zone-recipe"
# }

# variable "description" {
#     description = "The Security Zone descrption."
#     type = string
#     default = "security-zone"
# }

# variable "cis_level" {
#     description = "Which CIS Level of controls to include in the security zone."
#     type = string
#     default = "2"
#     validation {
#         condition     = contains(["1", "2",], var.cis_level)
#         error_message = "Validation failed for cis_level: valid values are 1 or 2"
#     }
# }

# variable "security_policies" {
#     description = "List of security zone policies that will make up the recipe."
#     type = list
#     default = []
# }

# variable "defined_tags" {
#     description = "The Security Zone defined tags."
#     type = map(string)
#     default = null
# }

# variable "freeform_tags" {
#     description = "The Security Zone freeform tags."
#     type = map(string)
#     default = null
# }

