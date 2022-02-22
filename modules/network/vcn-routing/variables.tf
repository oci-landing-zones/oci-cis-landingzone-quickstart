# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartment_id" {
  description = "Compartment OCID."
  type        = string
}

variable "subnets_route_tables" {
  description = "Subnet Route Tables"
  type        = map(object({
    compartment_id    = string,
    vcn_id            = string,
    defined_tags      = map(string),
    freeform_tags     = map(string),
    subnet_id         = string,
    route_rules = list(object({
      is_create         = bool
      destination       = string
      destination_type  = string
      network_entity_id = string
      description       = string
    }))
    defined_tags      = map(string)
  }))  
}