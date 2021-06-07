module "cis_spoke2_vcn" {
  depends_on           = [module.cis_vcn]
  count                = var.hub_spoke_architecture == true ? 1 : 0
  source               = "../modules/network/vcn"
  compartment_id       = module.cis_compartments.compartments[local.network_compartment_name].id
  vcn_display_name     = local.spoke2_vcn_display_name
  vcn_cidr             = var.spoke2_vcn_cidr
  vcn_dns_label        = "spoke2"
  service_label        = var.service_label
  service_gateway_cidr = local.valid_service_gateway_cidrs[0]
  drg_id               = module.cis_vcn.drg.id
  is_create_drg        = false
  is_create_igw        = false
  is_hub_spoke         = var.hub_spoke_architecture

  subnets = {
    (local.spoke2_private_subnet_web_name) = {
      compartment_id    = null
      defined_tags      = null
      freeform_tags     = null
      dynamic_cidr      = false
      cidr              = var.spoke2_private_subnet_web_cidr
      cidr_len          = null
      cidr_num          = null
      enable_dns        = true
      dns_label         = "spoke2web"
      private           = true
      ad                = null
      dhcp_options_id   = null
      route_table_id    = module.cis_spoke2_vcn[0].subnets_route_tables[local.spoke2_route_table_name].id
      security_list_ids = [module.cis_spoke2_security_lists[0].security_lists[local.spoke2_private_subnet_app_security_list_name].id]
    },
    (local.spoke2_private_subnet_app_name) = {
      compartment_id    = null
      defined_tags      = null
      freeform_tags     = null
      dynamic_cidr      = false
      cidr              = var.spoke2_private_subnet_app_cidr
      cidr_len          = null
      cidr_num          = null
      enable_dns        = true
      dns_label         = "spoke2app"
      private           = true
      ad                = null
      dhcp_options_id   = null
      route_table_id    = module.cis_spoke2_vcn[0].subnets_route_tables[local.spoke2_route_table_name].id
      security_list_ids = [module.cis_spoke2_security_lists[0].security_lists[local.spoke2_private_subnet_app_security_list_name].id]
    },
    (local.spoke2_private_subnet_db_name) = {
      compartment_id    = null
      defined_tags      = null
      freeform_tags     = null
      dynamic_cidr      = false
      cidr              = var.spoke2_private_subnet_db_cidr
      cidr_len          = null
      cidr_num          = null
      enable_dns        = true
      dns_label         = "spoke2db"
      private           = true
      ad                = null
      dhcp_options_id   = null
      route_table_id    = module.cis_spoke2_vcn[0].subnets_route_tables[local.spoke2_route_table_name].id
      security_list_ids = [module.cis_spoke2_security_lists[0].security_lists[local.spoke2_private_subnet_db_security_list_name].id]
    }
  }

  subnets_route_tables = {
    (local.spoke2_route_table_name) = {
      compartment_id = null
      route_rules = [{
        is_create         = true
        destination       = local.valid_service_gateway_cidrs[0]
        destination_type  = "SERVICE_CIDR_BLOCK"
        network_entity_id = module.cis_spoke2_vcn[0].service_gateway.id
        },
        {
          is_create         = true
          destination       = local.anywhere
          destination_type  = "CIDR_BLOCK"
          network_entity_id = module.cis_vcn.drg != null ? module.cis_vcn.drg.id : null
        }
      ]
    }
  }
}

