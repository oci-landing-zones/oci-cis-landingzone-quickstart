# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration creates three empty security lists.
### The security rules are driven by NSGs (Network Security Groups). See cis2_3-4.tf
### Add security rules as needed. See commented section as an example.

module "cis_security_lists" {
  source                   = "../modules/network/security"
  default_compartment_id   = module.lz_compartments.compartments[local.network_compartment_name].id
  vcn_id                   = module.cis_vcn.vcn.id
  default_security_list_id = module.cis_vcn.vcn.default_security_list_id
  
  security_lists = { 
    (local.public_subnet_security_list_name) = { 
      compartment_id  = null
      defined_tags    = null
      freeform_tags   = null
      ingress_rules   = null
      egress_rules    = null
    /*  
      ingress_rules   = [{
        stateless     = false
        protocol      = "6"
        src           = var.public_src_bastion_cidr
        src_type      = "CIDR_BLOCK"
        src_port      = null
        dst_port      = {
          min = 22
          max = 22
        }
        icmp_type     = null
        icmp_code     = null
      }]
      egress_rules    = [{
        stateless     = false
        protocol      = "6"
        dst           = var.private_subnet_app_cidr
        dst_type      = "CIDR_BLOCK"
        src_port      = null
        dst_port      = {
          min = 22
          max = 22
        }
        icmp_type     = null
        icmp_code     = null
      }]
    */  
    },
    (local.private_subnet_app_security_list_name) = { 
      compartment_id  = null
      defined_tags    = null
      freeform_tags   = null
      ingress_rules   = null
      egress_rules    = null
    },
    (local.private_subnet_db_security_list_name) = { 
      is_create       = true
      compartment_id  = null
      defined_tags    = null
      freeform_tags   = null
      ingress_rules   = null
      egress_rules    = null
    } 
  }
}  

module "cis_dmz_security_lists" {
  count                  = var.hub_spoke_architecture == true ? 1 : 0
  source                   = "../modules/network/security"
  default_compartment_id   = module.cis_compartments.compartments[local.network_compartment_name].id
  vcn_id                   = module.cis_dmz_vcn[0].vcn.id
  default_security_list_id = module.cis_dmz_vcn[0].vcn.default_security_list_id

  security_lists = {
    (local.dmz_vcn_security_list_name) = {
      compartment_id = null
      defined_tags   = null
      freeform_tags  = null
      ingress_rules  = null
      egress_rules   = null
    }
  }
}

module "cis_spoke2_security_lists" {
  source                   = "../modules/network/security"
  count                    = var.hub_spoke_architecture == true ? 1 : 0
  default_compartment_id   = module.cis_compartments.compartments[local.network_compartment_name].id
  vcn_id                   = module.cis_spoke2_vcn[0].vcn.id
  default_security_list_id = module.cis_spoke2_vcn[0].vcn.default_security_list_id

  security_lists = {
    (local.spoke2_private_subnet_app_security_list_name) = {
      compartment_id = null
      defined_tags   = null
      freeform_tags  = null
      ingress_rules  = null
      egress_rules   = null
    },
    (local.spoke2_private_subnet_db_security_list_name) = {
      is_create      = true
      compartment_id = null
      defined_tags   = null
      freeform_tags  = null
      ingress_rules  = null
      egress_rules   = null
    }
  }
}  