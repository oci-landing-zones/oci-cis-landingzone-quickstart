# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_ocid" {
  type        = string
  description = "The tenancy ocid."
} 

variable "tag_namespace_compartment_id" {
  type        = string
  description = "The default compartment ocid for tag namespace."
  default     = ""
} 

variable "tag_defaults_compartment_id" {
  type        = string
  description = "The default compartment ocid for tag defaults."
  default     = ""
} 

variable "tag_namespace_name" {
  type        = string
  description = "The tag namespace name"
  default     = ""
}  

variable "tag_namespace_description" {
  type        = string
  description = "The tag namespace description"
  default     = ""
}

variable "tag_namespace_defined_tags" {
  type        = map(string)
  description = "Map of key-value pairs of defined tags. (Optional)"
  default     = null
}

variable "tag_namespace_freeform_tags" {
  type        = map(string)
  description = "Map of key-value pairs of freeform tags. (Optional)"
  default     = null
}

variable "is_namespace_retired" {
  type        = string
  description = "Whether or not the namespace is retired"
  default     = false
}

variable "oracle_default_namespace_name" {
  type        = string
  description = "The Oracle default tag namespace name"
  default     = "Oracle-Tags"
}

variable "is_create_namespace" {
  type = bool
  description = "Whether the namespace should be created."
  default = true
}

variable "tags" {
  type = map(object({
    tag_description         = string,
    tag_is_cost_tracking    = bool,
    tag_is_retired          = bool,
    tag_defined_tags        = map(string),
    make_tag_default        = bool,
    tag_default_value       = string,
    tag_default_is_required = bool
  }))
}    