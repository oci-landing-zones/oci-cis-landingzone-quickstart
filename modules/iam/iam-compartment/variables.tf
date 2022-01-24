# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartments" {
  type = map(object({
    parent_id     = string
    name          = string
    description   = string
    enable_delete = string
    defined_tags  = map(string) 
    freeform_tags = map(string) 
  }))
}  
