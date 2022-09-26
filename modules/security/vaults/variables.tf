# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartment_id" {
  type        = string
  description = "The compartment OCID where the vault is managed."
} 

variable "name" {
  type        = string
  description = "The vault name."
  default     = "lz-vault"
}

variable "type" {
  type        = string
  description = "The vault type - DEFAULT (Shared)"
  default     = "DEFAULT"
}

variable "defined_tags" {
  type        = map(string)
  description = "Map of key-value pairs of defined tags for all resources managed by this module."
  default     = null
}

variable "freeform_tags" {
  type        = map(string)
  description = "Map of key-value pairs of freeform tags for all resources managed by this module."
  default     = null
}
