# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# default values
locals {
  subnet_defaults     = {
    display_name      = null
    compartment_id    = null
    defined_tags      = {}
    freeform_tags     = {}
    dynamic_cidr      = false
    cidr              = null
    cidr_len          = 28
    cidr_num          = null
    enable_dns        = true
    dns_label         = "subnet"
    private           = true
    ad                = null
    dhcp_options_id   = null
    route_table_id    = null
    security_list_ids = null
  }
  keys                = keys(var.subnets)
}

# resource definition
resource "oci_core_subnet" "this" {
  count                       = length(local.keys)
  
  vcn_id                      = var.vcn_id
  cidr_block                  = var.subnets[local.keys[count.index]].dynamic_cidr != true ? (local.subnet_defaults.dynamic_cidr == false ? var.subnets[local.keys[count.index]].cidr : (cidrsubnet((var.subnets[local.keys[count.index]].cidr != null ? var.subnets[local.keys[count.index]].cidr : var.vcn_cidr), ((var.subnets[local.keys[count.index]].cidr_len != null ? var.subnets[local.keys[count.index]].cidr_len : local.subnet_defaults.cidr_len) - split("/", (var.subnets[local.keys[count.index]].cidr != null ? var.subnets[local.keys[count.index]].cidr : var.vcn_cidr))[1]), (var.subnets[local.keys[count.index]].cidr_num != null ? var.subnets[local.keys[count.index]].cidr_num : count.index)))) : cidrsubnet((var.subnets[local.keys[count.index]].cidr != null ? var.subnets[local.keys[count.index]].cidr : var.vcn_cidr), ((var.subnets[local.keys[count.index]].cidr_len != null ? var.subnets[local.keys[count.index]].cidr_len : local.subnet_defaults.cidr_len) - split("/", (var.subnets[local.keys[count.index]].cidr != null ? var.subnets[local.keys[count.index]].cidr : var.vcn_cidr))[1]), (var.subnets[local.keys[count.index]].cidr_num != null ? var.subnets[local.keys[count.index]].cidr_num : count.index))
  compartment_id              = var.subnets[local.keys[count.index]].compartment_id != null ? var.subnets[local.keys[count.index]].compartment_id : var.default_compartment_id
  defined_tags                = var.subnets[local.keys[count.index]].defined_tags != null ? var.subnets[local.keys[count.index]].defined_tags : local.subnet_defaults.defined_tags
  freeform_tags               = var.subnets[local.keys[count.index]].freeform_tags != null ? var.subnets[local.keys[count.index]].freeform_tags : local.subnet_defaults.freeform_tags
  display_name                = local.keys[count.index] != null ? local.keys[count.index] : "${local.subnet_defaults.display_name}-${count.index}"
  prohibit_public_ip_on_vnic  = var.subnets[local.keys[count.index]].private != null ? var.subnets[local.keys[count.index]].private : local.subnet_defaults.private
  dns_label                   = var.subnets[local.keys[count.index]].enable_dns != false ? (var.subnets[local.keys[count.index]].dns_label != null ? var.subnets[local.keys[count.index]].dns_label : "${local.subnet_defaults.dns_label}${count.index}" ) : null
  dhcp_options_id             = var.subnets[local.keys[count.index]].dhcp_options_id != null ? var.subnets[local.keys[count.index]].dhcp_options_id : local.subnet_defaults.dhcp_options_id
  route_table_id              = var.subnets[local.keys[count.index]].route_table_id != null ? var.subnets[local.keys[count.index]].route_table_id : local.subnet_defaults.route_table_id
  security_list_ids           = var.subnets[local.keys[count.index]].security_list_ids != null ? var.subnets[local.keys[count.index]].security_list_ids : local.subnet_defaults.security_list_ids
}