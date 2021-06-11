locals {
  subnet_names = ["web", "app", "db"]
  spoke_vcn_names = { for v in var.spoke_vcn_cidrs : "spoke${index(var.spoke_vcn_cidrs, v)}" => {
    name = "${var.service_label}-spoke${index(var.spoke_vcn_cidrs, v)}-vcn"
    cidr = v
    }
  }
  #   single_vcn_name = {"${var.service_label}-lz-vcn" = { name : }}
  #     single_vcn = { single_vcn_name = {
  #     compartment_id    = module.cis_compartments.compartments[local.network_compartment_name].id
  #     cidr              = var.spoke_vcn_cidrs[0]
  #     dns_label         = "lz"
  #     is_create_igw     = var.hub_spoke_architecture ? false : ( !var.no_internet_access == true ? true : false )
  #     # Update to to remove DRG
  #     is_attach_drg     = tobool(var.is_vcn_onprem_connected) == true || var.hub_spoke_architecture == true ? true : false
  #     block_nat_traffic = false
  #     defined_tags      = null
  #     subnets = { for s in local.subnet_names : "${vcn.name}-${s}-subnet" => {
  #       compartment_id  = null
  #       defined_tags    = null
  #       cidr            = cidrsubnet(vcn.cidr, 4, index(local.subnet_names, s))
  #       dns_label       =  s
  #       private         = var.hub_spoke_architecture || var.no_internet_access ? true : false
  #       dhcp_options_id = null
  #       }
  #     }

  #     } }
  spoke_vcns = { for key, vcn in local.spoke_vcn_names : vcn.name => {
    compartment_id    = module.cis_compartments.compartments[local.network_compartment_name].id
    cidr              = vcn.cidr
    dns_label         = key
    is_create_igw     = var.hub_spoke_architecture ? false : (!var.no_internet_access == true ? true : false)
    is_create_drg     = tobool(var.is_vcn_onprem_connected) == true || var.hub_spoke_architecture == true ? true : false
    is_attach_drg     = tobool(var.is_vcn_onprem_connected) == true || var.hub_spoke_architecture == true ? true : false
    block_nat_traffic = false
    defined_tags      = null
    subnets = { for s in local.subnet_names : "${vcn.name}-${s}-subnet" => {
      compartment_id  = null
      defined_tags    = null
      cidr            = cidrsubnet(vcn.cidr, 4, index(local.subnet_names, s))
      dns_label       = s
      private         = var.hub_spoke_architecture || var.no_internet_access ? true : (s == "web" ? false : true)
      dhcp_options_id = null
      }
    }

    }
  }
  vcn_ids = module.lz_spoke_vcns.vcns
  subnets = module.lz_spoke_vcns.subnets

  web_spoke_route_route_tables = { for key, subnet in local.subnets : replace(key, "subnet", "route-table") => {
    compartment_id = subnet.compartment_id
    vcn_id         = subnet.vcn_id
    subnet_id      = subnet.id
    defined_tags   = null
    route_rules = [{
      is_create         = var.hub_spoke_architecture || var.no_internet_access ? true : false
      destination       = local.valid_service_gateway_cidrs[0]
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = module.lz_spoke_vcns.service_gateways[subnet.vcn_id].id
      description       = null
      },
      {
        is_create         = !var.hub_spoke_architecture && !var.no_internet_access ? true : false
        destination       = local.valid_service_gateway_cidrs[1]
        destination_type  = "SERVICE_CIDR_BLOCK"
        network_entity_id = module.lz_spoke_vcns.service_gateways[subnet.vcn_id].id
        description       = null
      },
      {
        is_create         = var.hub_spoke_architecture
        destination       = local.anywhere
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.lz_spoke_vcns.drg != null ? module.lz_spoke_vcns.drg.id : null
        description       = null
      },
      {
        is_create         = !var.hub_spoke_architecture && !var.no_internet_access ? true : false
        destination       = local.anywhere
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.lz_spoke_vcns.internet_gateways != null ? module.lz_spoke_vcns.internet_gateways[subnet.vcn_id].id : null
        description       = null

      },
      {
        is_create         = tobool(var.is_vcn_onprem_connected) == true && !var.hub_spoke_architecture == true ? true : false
        destination       = var.onprem_cidr
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.lz_spoke_vcns.drg != null ? module.lz_spoke_vcns.drg.id : null
        description       = null

      }

    ]
  } if length(regexall(".*-web-*", key)) > 0 }

  app_spoke_route_route_tables = { for key, subnet in local.subnets : replace(key, "subnet", "route-table") => {
    compartment_id = subnet.compartment_id
    vcn_id         = subnet.vcn_id
    subnet_id      = subnet.id
    defined_tags   = null
    route_rules = [{
      is_create         = true
      destination       = local.valid_service_gateway_cidrs[0]
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = module.lz_spoke_vcns.service_gateways[subnet.vcn_id].id
      description       = null
      },
      {
        is_create         = var.hub_spoke_architecture
        destination       = local.anywhere
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.lz_spoke_vcns.drg != null ? module.lz_spoke_vcns.drg.id : null
        description       = null
      },
      {
        is_create         = !var.hub_spoke_architecture && !var.no_internet_access ? true : false
        destination       = local.anywhere
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.lz_spoke_vcns.nat_gateways != null ? module.lz_spoke_vcns.nat_gateways[subnet.vcn_id].id : null
        description       = null

      },
      {
        is_create         = tobool(var.is_vcn_onprem_connected) == true && !var.hub_spoke_architecture == true ? true : false
        destination       = var.onprem_cidr
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.lz_spoke_vcns.drg != null ? module.lz_spoke_vcns.drg.id : null
        description       = null

      }

    ]
  } if length(regexall(".*-app-*", key)) > 0 }

  db_spoke_route_route_tables = { for key, subnet in local.subnets : replace(key, "subnet", "route-table") => {
    compartment_id = subnet.compartment_id
    vcn_id         = subnet.vcn_id
    subnet_id      = subnet.id
    defined_tags   = null
    route_rules = [{
      is_create         = true
      destination       = local.valid_service_gateway_cidrs[0]
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = module.lz_spoke_vcns.service_gateways[subnet.vcn_id].id
      description       = null
      },
      {
        is_create         = var.hub_spoke_architecture
        destination       = local.anywhere
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.lz_spoke_vcns.drg != null ? module.lz_spoke_vcns.drg.id : null
        description       = null
      }

    ]
  } if length(regexall(".*-db-*", key)) > 0 }


  #   hub_spoke_route_tables = { for key, subnet in local.subnets : replace(key, "subnet", "route-table") => {
  #     compartment_id = subnet.compartment_id
  #     vcn_id         = subnet.vcn_id
  #     subnet_id      = subnet.id
  #     defined_tags   = null
  #     route_rules = [{
  #       is_create         = true
  #       destination       = "0.0.0.0/0"
  #       destination_type  = "CIDR_BLOCK"
  #       network_entity_id = module.lz_spoke_vcns.drg.id
  #       description       = null
  #       },
  #       {
  #         is_create         = true
  #         destination       = local.valid_service_gateway_cidrs[0]
  #         destination_type  = "SERVICE_CIDR_BLOCK"
  #         network_entity_id = module.lz_spoke_vcns.service_gateways[subnet.vcn_id].id
  #         description       = null
  #     }]
  #     }
  #   }

  spoke_subnet_route_tables = merge(local.web_spoke_route_route_tables, local.app_spoke_route_route_tables, local.db_spoke_route_route_tables)
  #   single_vcn_route_tables = {
  #     "hbspk-spoke0-vcn-web-route-table" = {
  #       compartment_id = subnet.compartment_id
  #       vcn_id         = subnet.vcn_id
  #       subnet_id      = subnet.id
  #       defined_tags   = null
  #       route_rules = [{
  #           is_create         = var.hub_spoke_architecture || var.no_internet_access ? true : false
  #           destination       = local.valid_service_gateway_cidrs[0]
  #           destination_type  = "SERVICE_CIDR_BLOCK"
  #           network_entity_id = module.lz_spoke_vcns.service_gateways[subnets[hbspk-spoke0-vcn-web-route-table].vcn_id].id
  #         },
  #         {
  #           is_create         = !var.hub_spoke_architecture && !var.no_internet_access ? true : false
  #           destination       = local.valid_service_gateway_cidrs[1]
  #           destination_type  = "SERVICE_CIDR_BLOCK"
  #           network_entity_id = module.cis_vcn.service_gateway.id
  #         },
  #         {
  #           is_create         = var.hub_spoke_architecture
  #           destination       = local.anywhere
  #           destination_type  = "CIDR_BLOCK"
  #           network_entity_id = module.cis_vcn.drg != null ? module.cis_vcn.drg.id : null
  #         },
  #         {
  #           is_create         = !var.hub_spoke_architecture && !var.no_internet_access ? true : false
  #           destination       = local.anywhere
  #           destination_type  = "CIDR_BLOCK"
  #           network_entity_id = module.cis_vcn.internet_gateway != null ? module.cis_vcn.internet_gateway.id : null 
  #         },
  #         {
  #           is_create         = tobool(var.is_vcn_onprem_connected) == true && !var.hub_spoke_architecture == true ? true : false 
  #           destination       = var.onprem_cidr
  #           destination_type  = "CIDR_BLOCK"
  #           network_entity_id = module.cis_vcn.drg != null ? module.cis_vcn.drg.id : null
  #         }
  #       ]
  #     },
  #     "hbspk-spoke0-vcn-app-route-table" = {
  #       compartment_id = subnet.compartment_id
  #       vcn_id         = subnet.vcn_id
  #       subnet_id      = subnet.id
  #       defined_tags   = null
  #     },
  #     "hbspk-spoke0-vcn-db-route-table" = {
  #       compartment_id = subnet.compartment_id
  #       vcn_id         = subnet.vcn_id
  #       subnet_id      = subnet.id
  #       defined_tags   = null
  #     }
  #   }

}



module "lz_spoke_vcns" {
  source               = "../modules/network/vcn-basic"
  compartment_id       = module.cis_compartments.compartments[local.network_compartment_name].id
  service_label        = var.service_label
  service_gateway_cidr = local.valid_service_gateway_cidrs[0]
  is_create_drg        = true
  vcns                 = local.spoke_vcns

}


module "lz_route_tables" {
  source               = "../modules/network/vcn-routing"
  compartment_id       = module.cis_compartments.compartments[local.network_compartment_name].id
  subnets_route_tables = local.spoke_subnet_route_tables
}
