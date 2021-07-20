# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartment_id" {
  description = "Compartment's OCID where VCN will be created."
}

variable "service_label" {
  description = "A service label to be used as part of resource names."
}

variable "service_gateway_cidr" {
  description = "The OSN service cidr accessible through Service Gateway"
  type        = string
}

variable "drg_id" {
  description = "DRG to be attached"
  default     = null
  type        = string
}

variable "vcns" {
  description = "The VCNs."
  type        = map(object({
    compartment_id    = string,
    cidr              = string,
    dns_label         = string,
    is_create_igw     = bool,
    is_attach_drg     = bool,
    block_nat_traffic = bool,
    subnets           = map(object({
      compartment_id    = string,
      cidr              = string,
      dns_label         = string,
      private           = bool,
      dhcp_options_id   = string,
      defined_tags      = map(string)
    })),
    defined_tags      = map(string)
  }))  
}