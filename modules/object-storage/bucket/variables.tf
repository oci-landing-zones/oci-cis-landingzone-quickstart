# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "buckets" {
  description = "The buckets to manage."
  type = map(object({
    compartment_id = string,
    name           = string,
    namespace      = string,
    kms_key_id     = string,
    defined_tags   = map(string),
    freeform_tags   = map(string)
  }))
}

variable "cis_level" {
  type = string
  description = "The CIS OCI Benchmark profile level for buckets. Level 1 is be practical and prudent. Level 2 is intended for environments where security is more critical than manageability and usability."
  default = "1"
  validation {
    condition     = contains(["1", "2"], var.cis_level)
    error_message = "Validation failed for cis_level: valid values are 1 or 2."
  }
}

  