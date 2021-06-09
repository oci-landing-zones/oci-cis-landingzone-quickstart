# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration provisions a VCN, an Internet Gateway, a NAT Gateway, a Service Gateway, three subnets and three route tables.
### Among the subnets, one is public and two are private (meant to host app and db hosts). Each subnet is attached a different route table, with distinct route rules.
### The route table attached to the public subnet has a rule for the Internet Gateway with 0.0.0.0/0 destination 
### The route table attached to the app private subnet has two rules: one for the NAT Gateway with 0.0.0.0/0 destination and one for the Service Gateway with region's Object Store destination 
### The route table attached to the db private subnet has a rule for the Service Gateway with region's Object Store destination

module "cis_dmz_vcn" {
  count                = var.hub_spoke_architecture == true ? 1 : 0
  depends_on           = [module.cis_vcn]
  source               = "../modules/network/vcn"
  compartment_id       = module.cis_compartments.compartments[local.network_compartment_name].id
  vcn_display_name     = local.dmz_vcn_display_name
  vcn_cidr             = var.dmz_vcn_cidr
  vcn_dns_label        = "dmz"
  service_label        = var.service_label
  service_gateway_cidr = local.valid_service_gateway_cidrs[0]
  is_create_drg        = false
  is_create_igw        = !var.no_internet_access
  is_hub_spoke         = var.hub_spoke_architecture
  drg_id               = module.cis_vcn.drg.id
  
  subnets = {
    (local.dmz_bastion_subnet_name) = {
      compartment_id    = null
      defined_tags      = null
      freeform_tags     = null
      dynamic_cidr      = false
      cidr              = var.dmz_bastion_subnet_cidr
      cidr_len          = null
      cidr_num          = null
      enable_dns        = true
      dns_label         = "bastion"
      private           = var.no_internet_access
      ad                = null
      dhcp_options_id   = null
      route_table_id    = module.cis_dmz_vcn[0].subnets_route_tables[local.dmz_bastion_subnet_route_table_name].id
      security_list_ids = [module.cis_dmz_security_lists[0].security_lists[local.dmz_bastion_subnet_security_list_name].id]
    },
    (local.dmz_services_subnet_name) = {
      compartment_id    = null
      defined_tags      = null
      freeform_tags     = null
      dynamic_cidr      = false
      cidr              = var.dmz_services_subnet_cidr
      cidr_len          = null
      cidr_num          = null
      enable_dns        = true
      dns_label         = "services"
      private           = var.no_internet_access
      ad                = null
      dhcp_options_id   = null
      route_table_id    = module.cis_dmz_vcn[0].subnets_route_tables[local.dmz_services_subnet_route_table_name].id
      security_list_ids = [module.cis_dmz_security_lists[0].security_lists[local.dmz_services_subnet_security_list_name].id]
    }
  }

  subnets_route_tables = {
    (local.dmz_bastion_subnet_route_table_name) = {
      compartment_id = null
      route_rules = [{
        is_create         = var.no_internet_access
        destination       = local.valid_service_gateway_cidrs[1]
        destination_type  = "SERVICE_CIDR_BLOCK"
        network_entity_id = module.cis_dmz_vcn[0].service_gateway.id
        },
        {
        is_create         = !var.no_internet_access
        destination       = local.valid_service_gateway_cidrs[1]
        destination_type  = "SERVICE_CIDR_BLOCK"
        network_entity_id = module.cis_dmz_vcn[0].service_gateway.id
        },
        {
          is_create         = tobool(var.is_vcn_onprem_connected)
          destination       = var.onprem_cidr
          destination_type  = "CIDR_BLOCK"
          network_entity_id = module.cis_vcn.drg != null ? module.cis_vcn.drg.id : null
        },
        {
          is_create         = true
          destination       = var.vcn_cidr
          destination_type  = "CIDR_BLOCK"
          network_entity_id = module.cis_vcn.drg != null ? module.cis_vcn.drg.id : null
        },
        {
          is_create         = true
          destination       = var.spoke2_vcn_cidr
          destination_type  = "CIDR_BLOCK"
          network_entity_id = module.cis_vcn.drg != null ? module.cis_vcn.drg.id : null
        },
        {
          is_create         = !var.no_internet_access
          destination       = local.anywhere
          destination_type  = "CIDR_BLOCK"
          network_entity_id = module.cis_dmz_vcn[0].internet_gateway != null ? module.cis_dmz_vcn[0].internet_gateway.id : null
        }
      ]
    },
    (local.dmz_services_subnet_route_table_name) = {
      compartment_id = null
      route_rules = [{
        is_create         = var.no_internet_access
        destination       = local.valid_service_gateway_cidrs[1]
        destination_type  = "SERVICE_CIDR_BLOCK"
        network_entity_id = module.cis_dmz_vcn[0].service_gateway.id
        },
        {
        is_create         = !var.no_internet_access
        destination       = local.valid_service_gateway_cidrs[1]
        destination_type  = "SERVICE_CIDR_BLOCK"
        network_entity_id = module.cis_dmz_vcn[0].service_gateway.id
        },
        {
          is_create         = tobool(var.is_vcn_onprem_connected)
          destination       = var.onprem_cidr
          destination_type  = "CIDR_BLOCK"
          network_entity_id = module.cis_vcn.drg != null ? module.cis_vcn.drg.id : null
        },
        {
          is_create         = true
          destination       = var.vcn_cidr
          destination_type  = "CIDR_BLOCK"
          network_entity_id = module.cis_vcn.drg != null ? module.cis_vcn.drg.id : null
        },
        {
          is_create         = true
          destination       = var.spoke2_vcn_cidr
          destination_type  = "CIDR_BLOCK"
          network_entity_id = module.cis_vcn.drg != null ? module.cis_vcn.drg.id : null
        },
        {
          is_create         = !var.no_internet_access
          destination       = local.anywhere
          destination_type  = "CIDR_BLOCK"
          network_entity_id = module.cis_dmz_vcn[0].internet_gateway != null ? module.cis_dmz_vcn[0].internet_gateway.id : null
        }
      ]
    }
  }
}