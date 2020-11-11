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

resource "oci_core_subnet" "this" {
  for_each = var.subnets
    vcn_id                      = var.vcn_id
    cidr_block                  = each.value.cidr
    compartment_id              = var.default_compartment_id
    defined_tags                = each.value.defined_tags
    freeform_tags               = each.value.freeform_tags
    display_name                = each.key
    prohibit_public_ip_on_vnic  = each.value.private
    dns_label                   = each.value.dns_label
    dhcp_options_id             = each.value.dhcp_options_id
    route_table_id              = each.value.route_table_id
    security_list_ids           = each.value.security_list_ids
}