# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

/**************************************
variable "policies" {
  type = map(object({
    compartment_id = string  
    description    = string
    statements     = list(string)
    defined_tags   = map(string)
    freeform_tags  = map(string)
  }))
}
**************************************/