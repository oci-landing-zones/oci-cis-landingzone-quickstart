# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration creates three empty security lists.
### The security rules are driven by NSGs (Network Security Groups). See net_nsgs.tf
### Add security rules as needed.

locals {
  web_security_lists = { for k, v in module.lz_vcn_spokes.vcns : "${k}-web-security-list" => {
    vcn_id : v.id, compartment_id : null, defined_tags : null, ingress_rules : null, egress_rules : null
  } if length(regexall(".*spoke*", k)) > 0 }
  app_security_lists = { for k, v in module.lz_vcn_spokes.vcns : "${k}-app-security-list" => {
    vcn_id : v.id, compartment_id : null, defined_tags : null, ingress_rules : null, egress_rules : null
  } if length(regexall(".*spoke*", k)) > 0 } 
  db_security_lists = { for k, v in module.lz_vcn_spokes.vcns : "${k}-db-security-list" => {
    vcn_id : v.id, compartment_id : null, defined_tags : null, ingress_rules : null, egress_rules : null
  } if length(regexall(".*spoke*", k)) > 0}

  dmz_security_lists = var.dmz_vcn_cidr != null ? { for k, v in module.lz_vcn_dmz.subnets : replace("${k}-security-list","subnet-","") => {
    vcn_id: v.vcn_id, compartment_id : null, defined_tags : null, ingress_rules : null, egress_rules : null }} : {}

}

module "lz_security_lists" {
  source           = "../modules/network/security"
  compartment_id   = module.lz_compartments.compartments[local.network_compartment_name].id
  security_lists = merge(local.web_security_lists, local.app_security_lists, local.db_security_lists, local.dmz_security_lists)
}   


resource "oci_core_default_security_list" "default_security_list" {
  for_each = var.dmz_vcn_cidr == null ? module.lz_vcn_spokes.vcns : merge(module.lz_vcn_spokes.vcns, module.lz_vcn_dmz.vcns)
    manage_default_resource_id = each.value.default_security_list_id
    ingress_security_rules {
      protocol  = "1"
      stateless = false
      source    = local.anywhere
      icmp_options {
        type = 3
        code = 4
      }
    }
    ingress_security_rules {
      protocol  = "1"
      stateless = false
      source    = each.value.cidr_block
      icmp_options {
        type = 3
        code = null
    }
  }
}