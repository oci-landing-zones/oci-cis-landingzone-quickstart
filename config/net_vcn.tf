# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration provisions a VCN, an Internet Gateway, a NAT Gateway, a Service Gateway, three subnets and three route tables.
### Among the subnets, one is public and two are private (meant to host app and db hosts). Each subnet is attached a different route table, with distinct route rules.
### The route table attached to the public subnet has a rule for the Internet Gateway with 0.0.0.0/0 destination 
### The route table attached to the app private subnet has two rules: one for the NAT Gateway with 0.0.0.0/0 destination and one for the Service Gateway with region's Object Store destination 
### The route table attached to the db private subnet has a rule for the Service Gateway with region's Object Store destination

module "cis_vcn" {
  source               = "../modules/network/vcn"
  compartment_id       = module.cis_compartments.compartments[local.network_compartment_name].id
  vcn_display_name     = local.vcn_display_name
  vcn_cidr             = var.vcn_cidr
  vcn_dns_label        = var.service_label
  service_label        = var.service_label
  service_gateway_cidr = local.valid_service_gateway_cidrs[1]
  is_create_drg        = tobool(var.is_vcn_onprem_connected)

  subnets = {
    (local.public_subnet_name) = {
      compartment_id    = null
      defined_tags      = null
      freeform_tags     = null
      dynamic_cidr      = false
      cidr              = var.public_subnet_cidr
      cidr_len          = null
      cidr_num          = null
      enable_dns        = true
      dns_label         = "public"
      private           = false
      ad                = null
      dhcp_options_id   = null
      route_table_id    = module.cis_vcn.route_tables[local.public_subnet_route_table_name].id
      security_list_ids = [module.cis_security_lists.security_lists[local.public_subnet_security_list_name].id]
    }, 
    (local.private_subnet_app_name) = {
      compartment_id    = null
      defined_tags      = null
      freeform_tags     = null
      dynamic_cidr      = false
      cidr              = var.private_subnet_app_cidr
      cidr_len          = null
      cidr_num          = null
      enable_dns        = true
      dns_label         = "appsubnet"
      private           = true
      ad                = null
      dhcp_options_id   = null
      route_table_id    = module.cis_vcn.route_tables[local.private_subnet_app_route_table_name].id
      security_list_ids = [module.cis_security_lists.security_lists[local.private_subnet_app_security_list_name].id]
    },
    (local.private_subnet_db_name) = {
      compartment_id    = null
      defined_tags      = null
      freeform_tags     = null
      dynamic_cidr      = false
      cidr              = var.private_subnet_db_cidr
      cidr_len          = null
      cidr_num          = null
      enable_dns        = true
      dns_label         = "dbsubnet"
      private           = true
      ad                = null
      dhcp_options_id   = null
      route_table_id    = module.cis_vcn.route_tables[local.private_subnet_db_route_table_name].id
      security_list_ids = [module.cis_security_lists.security_lists[local.private_subnet_db_security_list_name].id]
    }
  }

  route_tables         = {
    (local.public_subnet_route_table_name) = {
      compartment_id = null
      route_rules = [{
          is_create         = true
          destination       = var.public_src_lbr_cidr
          destination_type  = "CIDR_BLOCK"
          network_entity_id = module.cis_vcn.internet_gateway.id
        },
        {
          is_create         = tobool(var.is_vcn_onprem_connected)
          destination       = var.onprem_cidr
          destination_type  = "CIDR_BLOCK"
          network_entity_id = module.cis_vcn.drg != null ? module.cis_vcn.drg.id : null
        }
      ]
    },
    (local.private_subnet_app_route_table_name) = {
      compartment_id = null
      route_rules = [{
          is_create         = true
          destination       = local.valid_service_gateway_cidrs[1]
          destination_type  = "SERVICE_CIDR_BLOCK"
          network_entity_id = module.cis_vcn.service_gateway.id
        },
        {
          is_create         = true
          destination       = local.anywhere
          destination_type  = "CIDR_BLOCK"
          network_entity_id = module.cis_vcn.nat_gateway.id
        }
      ]
    },
    (local.private_subnet_db_route_table_name) = {
      compartment_id = null
      route_rules = [{
          is_create         = true
          destination       = local.valid_service_gateway_cidrs[1]
          destination_type  = "SERVICE_CIDR_BLOCK"
          network_entity_id = module.cis_vcn.service_gateway.id
        }
      ]  
    }
  }
}