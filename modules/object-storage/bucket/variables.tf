# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "kms_key_id" {
  type        = string
  description = "KMS Key ID"
  default     = ""
}  


variable "buckets" {
  type = map(object({
    compartment_id = string,
    name           = string,
    namespace      = string
  }))
}
  