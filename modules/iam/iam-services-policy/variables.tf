# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_id" {
  description = "The tenancy ocid."
  type = string
}

variable "service_label" {
  description = "The service label, use as a prefix to resource names."
  type = string
}

variable "enable_tenancy_level_policies" {
  description = "Whether policies for OCI services are enabled at the tenancy level."
  type = bool
  default = true
}

variable "tenancy_policy_name" {
  description = "The policy name for tenancy level policies."
  type = string
  default = "services-policy"
}

variable "policies" {
  description = "Managed policies. Notice that tenancy level policies are not to be passed, preferrably. They are best defined inside the module and enabled via enable_tenancy_level_policies variable."
  type = map(object({
    name           = string
    description    = string
    compartment_id = string
    statements     = list(string)
    defined_tags   = map(string)
    freeform_tags  = map(string)
  }))
  default = {}
}

variable "defined_tags" {
  description = "Policies defined tags."
  type = map(string)
  default = null
}

variable "freeform_tags" {
  description = "Policies freeform tags."
  type = map(string)
  default = null
}
