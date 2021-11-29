# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "dynamic_groups" {
  type = map(object({
    description    = string
    compartment_id = string
    matching_rule  = string
    defined_tags   = map(string)
    freeform_tags  = map(string)
  }))
}  