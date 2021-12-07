# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartment_id" {
  type        = string
  description = "The compartment ocid to create resources."
}  

variable "anywhere_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "ports_not_allowed_from_anywhere_cidr" {
  type    = list(number)
  default = [22,3389] # By default, ssh and rdp standard ports are not allowed from anywhere cidr
}

variable "security_lists" {
  type = map(object({
    vcn_id          = string,
    compartment_id  = string,
    defined_tags    = map(string),
    freeform_tags   = map(string),
    ingress_rules   = list(object({
      stateless     = bool,
      protocol      = string,
      src           = string,
      src_type      = string,
      src_port      = object({
        min         = number,
        max         = number
      }),
      dst_port      = object({
        min         = number,
        max         = number
      }),
      icmp_type     = number,
      icmp_code     = number
    })),
    egress_rules    = list(object({
      stateless     = bool,
      protocol      = string,
      dst           = string,
      dst_type      = string,
      src_port      = object({
        min         = number,
        max         = number
      }),
      dst_port      = object({
        min         = number,
        max         = number
      }),
      icmp_type     = number,
      icmp_code     = number
    }))
  }))
  description = "Parameters for customizing Security List(s)."
  default = {}
}

variable "nsgs" {
  type = map(object({
    vcn_id        = string,
    defined_tags  = map(string) 
    freeform_tags = map(string) 
    ingress_rules = map(object({
      is_create    = bool
      description  = string
      protocol     = string,
      stateless    = bool,
      src          = string,
      src_type     = string,
      dst_port_min = number,
      dst_port_max = number,
      src_port_min = number,
      src_port_max = number,
      icmp_type    = number,
      icmp_code    = number
    })),
    egress_rules = map(object({
      is_create    = bool
      description  = string
      protocol     = string,
      stateless    = bool,
      dst          = string,
      dst_type     = string,
      dst_port_min = number,
      dst_port_max = number,
      src_port_min = number,
      src_port_max = number,
      icmp_type    = number,
      icmp_code    = number
    }))
  }))
  description = "Parameters for customizing Network Security Group(s)."
  default = {}
}