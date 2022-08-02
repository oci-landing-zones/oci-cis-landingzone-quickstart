# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

#---------------------------------------------------------------
#--- Cloud Guard Security Zone Recipe variables ----------------
#---------------------------------------------------------------
variable "security_zones" {
  type = map(object({
    tenancy_ocid        = string
    service_label       = string
    compartment_id      = string
    description         = string
    security_policies   = list(string)
    cis_level           = string
    defined_tags        = map(string)
    freeform_tags       = map(string)
  }))
}  