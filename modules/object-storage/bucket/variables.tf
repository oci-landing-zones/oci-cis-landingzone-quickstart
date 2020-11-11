# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "region" {
  type        = string
  description = "Region"
  default     = ""
} 

variable "tenancy_ocid" {
  type        = string
  description = "Tenancy OCID"
  default     = ""
} 

variable "compartment_name" {
  type        = string
  description = "Compartment Name"
  default     = ""
}  

variable "kms_key_id" {
  type        = string
  description = "KMS Key ID"
  default     = ""
}  


variable "buckets" {
  type = map(object({
    compartment_id = string,
  }))
}
  