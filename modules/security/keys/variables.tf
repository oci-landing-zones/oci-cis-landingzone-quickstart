# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartment_id" {
  type        = string
  description = "The compartment OCID where managed_keys are created."
}

variable "managed_keys" {
  description = "The keys to manage."
  type = map(object({
    vault_id = string,
    key_name = string,
    key_shape_algorithm = string,
    key_shape_length = string,
    service_grantees = list(string),
    group_grantees = list(string)
  }))
  default = {}
}

variable "existing_keys" {
  description = "Existing keys to manage policies for. A policy is managed for each existing key, but keys themselves are not managed."
  type = map(object({
    key_id = string,
    compartment_id = string,
    service_grantees = list(string),
    group_grantees = list(string)
  }))
  default = {}
}

variable "policy_name" {
  type        = string
  description = "The policy name for the managed_keys."
  default     = "lz-keys-policy"
} 

variable "policy_compartment_id" {
  type        = string
  description = "The compartment OCID where the managed_keys policies are managed."
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
