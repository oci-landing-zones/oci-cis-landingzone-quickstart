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
  type = map(object({
    compartment_id    = string,
    cidr              = string,
    dns_label         = string,
    is_create_igw     = bool,
    is_attach_drg     = bool,
    block_nat_traffic = bool,
    defined_tags      = map(string),
    freeform_tags     = map(string),
    subnets = map(object({
      compartment_id    = string,
      name              = string,
      cidr              = string,
      dns_label         = string,
      private           = bool,
      dhcp_options_id   = string,
      defined_tags      = map(string),
      freeform_tags     = map(string),
      security_lists    = map(object({
        is_create      = bool,
        compartment_id = string,
        defined_tags   = map(string),
        freeform_tags  = map(string),
        ingress_rules  = list(object({
          is_create    = bool,
          stateless    = bool,
          protocol     = string,
          description  = string,
          src          = string,
          src_type     = string,
          src_port_min = number,
          src_port_max = number,
          dst_port_min = number,
          dst_port_max = number,
          icmp_type    = number,
          icmp_code    = number
        })),
        egress_rules = list(object({
          is_create    = bool,
          stateless    = bool,
          protocol     = string,
          description  = string,
          dst          = string,
          dst_type     = string,
          src_port_min = number,
          src_port_max = number,
          dst_port_min = number,
          dst_port_max = number,
          icmp_type    = number,
          icmp_code    = number
        }))
      }))
    }))
  }))
}
