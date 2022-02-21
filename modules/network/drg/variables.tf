# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartment_id" {
  description = "Compartment's OCID where VCN will be created."
}

variable "service_label" {
  description = "A service label to be used as part of resource names."
}

variable "is_create_drg" {
  description = "Whether a DRG is to be created."
  default     = false
  type        = bool
}

variable "defined_tags" {
  type        = map(string)
  description = "Map of key-value pairs of defined tags. (Optional)"
  default     = null
}

variable "freeform_tags" {
  type        = map(string)
  description = "Map of key-value pairs of freeform tags. (Optional)"
  default     = null
}
