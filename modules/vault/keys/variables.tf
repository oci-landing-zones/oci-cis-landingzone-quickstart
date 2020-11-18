# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_ocid" {
  type        = string
  description = "Tenancy ID"
  default     = ""
} 

variable "compartment_id" {
  type        = string
  description = "The default compartment OCID to use for resources (unless otherwise specified)."
  default     = ""
} 

variable "compartment_name" {
  type        = string
  description = "Compartment anme"
  default     = ""
} 

variable "vault_name" {
  type        = string
  description = "Vault Name"
  default     = ""
} 

variable "vault_type" {
  type        = string
  description = "Vault Type - DEFAULT (Shared)"
  default     = "DEFAULT"
}  

variable "region" {
  type        = string
  description = "Region"
  default     = ""
}  

variable "keys" {
  type = map(object({
    key_shape_algorithm = string,
    key_shape_length = string
  }))
}


