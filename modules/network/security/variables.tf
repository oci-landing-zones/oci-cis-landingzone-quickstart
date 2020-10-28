# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "default_compartment_id" {
  type        = string
  description = "The default compartment OCID to use for resources (unless otherwise specified)."
  default     = ""
}  

variable "vcn_id" {
  type        = string
  description = "The VCN id where the Security List(s) should be created."
  default     = ""
}

variable "vcn_cidr" {
  type        = string
  description = "The vcn cidr block."
  default     = ""
}

variable "default_security_list_id" {
  type        = string
  description = "The id of the default security list."
  default     = ""
}

variable "default_defined_tags" {
  type        = map(string)
  description = "The different defined tags that are applied to each object by default."
  default     = {}
}

variable "default_freeform_tags" {
  type        = map(string)
  description = "The different freeform tags that are applied to each object by default."
  default     = {}
}

variable "anywhere_cidr" {
  default = "0.0.0.0/0"
}

variable "ports_not_allowed_from_anywhere_cidr" {
  type    = list(number)
  default = [22,3389] # By default, ssh and rdp standard ports are not allowed from anywhere cidr
}

variable "security_lists" {
  type = map(object({
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
    compartment_id  = string,
    defined_tags    = map(string),
    freeform_tags   = map(string),
    ingress_rules   = list(object({
      description   = string,
      stateless     = bool,
      protocol      = string,
      src           = string,
      # Allowed values: CIDR_BLOCK, SERVICE_CIDR_BLOCK, NETWORK_SECURITY_GROUP, NSG_NAME
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
      description   = string,
      stateless     = bool,
      protocol      = string,
      dst           = string,
      # Allowed values: CIDR_BLOCK, SERVICE_CIDR_BLOCK, NETWORK_SECURITY_GROUP, NSG_NAME
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
  description = "Parameters for customizing Network Security Group(s)."
  default = {}
}

variable "standalone_nsg_rules" {
  type = object({
    ingress_rules   = list(object({
      nsg_id        = string,
      description   = string,
      stateless     = bool,
      protocol      = string,
      src           = string,
      # Allowed values: CIDR_BLOCK, SERVICE_CIDR_BLOCK, NETWORK_SECURITY_GROUP, NSG_NAME
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
      nsg_id        = string,
      description   = string,
      stateless     = bool,
      protocol      = string,
      dst           = string,
      # Allowed values: CIDR_BLOCK, SERVICE_CIDR_BLOCK, NETWORK_SECURITY_GROUP, NSG_NAME
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
  })
  description = "Any standalone NSG rules that should be added (whether or not the NSG is defined here)."
  default = {
    ingress_rules: [], 
    egress_rules: []
  }
}