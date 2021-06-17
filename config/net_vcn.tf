# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  # # Subnet Names used can be changed first subnet will be Public if var.no_internet_access is false
  # spoke_subnet_names = ["web", "app", "db"]
  # # Subnet Names used can be changed first subnet will be Public if var.no_internet_access is false
  # dmz_subnet_names = ["outdoor","indoor","mgmt","ha", "diag"]

  spoke_vcn_names = { for v in var.spoke_vcn_cidrs : "spoke${index(var.spoke_vcn_cidrs, v)}" => {
    name = "${var.service_label}-spoke${index(var.spoke_vcn_cidrs, v)}-vcn"
    cidr = v
    }
  }


  ### VCNs ###
  spoke_vcns = { for key, vcn in local.spoke_vcn_names : vcn.name => {
    compartment_id    = module.lz_compartments.compartments[local.network_compartment_name].id
    cidr              = vcn.cidr
    dns_label         = key
    is_create_igw     = var.dmz_vcn_cidr != null ? false : (!var.no_internet_access == true ? true : false)
    is_create_drg     = var.is_vcn_onprem_connected == true || var.hub_spoke_architecture == true ? true : false
    is_attach_drg     = var.is_vcn_onprem_connected == true || var.hub_spoke_architecture == true ? true : false
    block_nat_traffic = false
    defined_tags      = null
    subnets = { for s in local.spoke_subnet_names : "${vcn.name}-${s}-subnet" => {
      compartment_id  = null
      defined_tags    = null
      cidr            = cidrsubnet(vcn.cidr, 4, index(local.spoke_subnet_names, s))
      dns_label       = s
      private         = var.hub_spoke_architecture || var.no_internet_access ? true : (index(local.spoke_subnet_names, s) == 0 ? false : true)
      dhcp_options_id = null
      }
    }
    }
  }

  # All VCNs
  all_lz_spoke_vcns = local.spoke_vcns

  # Output from VCNs
  all_lz_spoke_vcn_ids = module.lz_vcn_spokes.vcns
  all_lz_spoke_subnets = module.lz_vcn_spokes.subnets

  ### Route Tables ###
  ## Web Subnet Route Tables
  web_spoke_route_route_tables = { for key, subnet in local.all_lz_spoke_subnets : replace(key, "subnet", "route-table") => {
    compartment_id = subnet.compartment_id
    vcn_id         = subnet.vcn_id
    subnet_id      = subnet.id
    defined_tags   = null
    route_rules = concat([{
      is_create         = var.dmz_vcn_cidr != null || var.no_internet_access ? true : false
      destination       = local.valid_service_gateway_cidrs[0]
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = module.lz_vcn_spokes.service_gateways[subnet.vcn_id].id
      description       = "All OSN Sercices to SGW"
      },
      {
        is_create         = var.dmz_vcn_cidr == null  && !var.no_internet_access ? true : false
        destination       = local.valid_service_gateway_cidrs[1]
        destination_type  = "SERVICE_CIDR_BLOCK"
        network_entity_id = module.lz_vcn_spokes.service_gateways[subnet.vcn_id].id
        description       = "Object Storage Services to SGW"
      },
      {
        is_create         = var.dmz_vcn_cidr != null
        destination       = local.anywhere
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.lz_vcn_spokes.drg != null ? module.lz_vcn_spokes.drg.id : null
        description       = "All traffic goes to the DMZ"
      },
      {
        is_create         = var.hub_spoke_architecture && var.is_vcn_onprem_connected && var.dmz_vcn_cidr == null
        destination       = var.onprem_cidr
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.lz_vcn_spokes.drg != null ? module.lz_vcn_spokes.drg.id : null
        description       = "${var.onprem_cidr} to DRG"
      },
      {
        is_create         = var.dmz_vcn_cidr == null && !var.no_internet_access ? true : false
        destination       = local.anywhere
        destination_type  = "CIDR_BLOCK"
        network_entity_id = var.dmz_vcn_cidr == null && !var.no_internet_access ? module.lz_vcn_spokes.internet_gateways[subnet.vcn_id].id : null
        description       = "${local.anywhere} to Internet Gateway"

      },
      {
        is_create         = var.dmz_vcn_cidr != null && var.hub_spoke_architecture
        destination       = local.anywhere
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.lz_vcn_spokes.drg != null ? module.lz_vcn_spokes.drg.id : null
        description       = "${local.anywhere} to DRG"

      }
    ],
    [ for vcn_name, vcn in local.all_lz_spoke_vcn_ids : {
      is_create = var.hub_spoke_architecture && var.dmz_vcn_cidr == null
      destination = vcn.cidr_block
      destination_type = "CIDR_BLOCK"
      network_entity_id = module.lz_vcn_spokes.drg != null ? module.lz_vcn_spokes.drg.id : null
      description = "${vcn_name} traffic to DRG"
    } if subnet.vcn_id != vcn.id
  ]
  )
  } if length(regexall(".*-${local.spoke_subnet_names[0]}-*", key)) > 0 }

  ## App Subnet Route Tables
  app_spoke_route_route_tables = { for key, subnet in local.all_lz_spoke_subnets : replace(key, "subnet", "route-table") => {
    compartment_id = subnet.compartment_id
    vcn_id         = subnet.vcn_id
    subnet_id      = subnet.id
    defined_tags   = null
    route_rules = concat([{
      is_create         = true
      destination       = local.valid_service_gateway_cidrs[0]
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = module.lz_vcn_spokes.service_gateways[subnet.vcn_id].id
      description       = "All OSN Services to SGW"
      },
      {
        is_create         = var.hub_spoke_architecture
        destination       = local.anywhere
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.lz_vcn_spokes.drg != null ? module.lz_vcn_spokes.drg.id : null
        description       = "${local.anywhere} to DRG to access spokes and ${var.onprem_cidr}"
      },
      {
        is_create         = var.hub_spoke_architecture && var.is_vcn_onprem_connected && var.dmz_vcn_cidr == null
        destination       = var.onprem_cidr
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.lz_vcn_spokes.drg != null ? module.lz_vcn_spokes.drg.id : null
        description       = "${var.onprem_cidr} to DRG"
      },
      {
        is_create         = !var.hub_spoke_architecture && !var.no_internet_access ? true : false
        destination       = local.anywhere
        destination_type  = "CIDR_BLOCK"
        network_entity_id = !var.hub_spoke_architecture && !var.no_internet_access ? module.lz_vcn_spokes.nat_gateways[subnet.vcn_id].id : null
        description       = "${local.anywhere} to NAT Gateway for private subnets"

      },
      {
        is_create         = var.is_vcn_onprem_connected == true && !var.hub_spoke_architecture == true ? true : false
        destination       = var.onprem_cidr
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.lz_vcn_spokes.drg != null ? module.lz_vcn_spokes.drg.id : null
        description       = "${local.anywhere} to DRG to access ${var.onprem_cidr}"

      }

    ],
    [ for vcn_name, vcn in local.all_lz_spoke_vcn_ids : {
      is_create = var.hub_spoke_architecture && var.dmz_vcn_cidr == null
      destination = vcn.cidr_block
      destination_type = "CIDR_BLOCK"
      network_entity_id = module.lz_vcn_spokes.drg != null ? module.lz_vcn_spokes.drg.id : null
      description = "${vcn_name} traffic to DRG"
    } if subnet.vcn_id != vcn.id
  ]
  )
  } if length(regexall(".*-${local.spoke_subnet_names[1]}-*", key)) > 0 }

  ## Database Subnet Route Tables
  db_spoke_route_route_tables = { for key, subnet in local.all_lz_spoke_subnets : replace(key, "subnet", "route-table") => {
    compartment_id = subnet.compartment_id
    vcn_id         = subnet.vcn_id
    subnet_id      = subnet.id
    defined_tags   = null
    route_rules = concat([{
      is_create         = true
      destination       = local.valid_service_gateway_cidrs[0]
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = module.lz_vcn_spokes.service_gateways[subnet.vcn_id].id
      description       = "All OSN Services to SGW"
      },
      {
        is_create         = var.hub_spoke_architecture && var.is_vcn_onprem_connected && var.dmz_vcn_cidr == null
        destination       = var.onprem_cidr
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.lz_vcn_spokes.drg != null ? module.lz_vcn_spokes.drg.id : null
        description       = "${var.onprem_cidr} to DRG"
      },
      {
        is_create         = var.hub_spoke_architecture && var.dmz_vcn_cidr != null
        destination       = local.anywhere
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.lz_vcn_spokes.drg != null ? module.lz_vcn_spokes.drg.id : null
        description       = "${local.anywhere} to DRG to access spokes and ${var.onprem_cidr}"
      }
    ],
    [ for vcn_name, vcn in local.all_lz_spoke_vcn_ids : {
      is_create = var.hub_spoke_architecture && var.dmz_vcn_cidr == null
      destination = vcn.cidr_block
      destination_type = "CIDR_BLOCK"
      network_entity_id = module.lz_vcn_spokes.drg != null ? module.lz_vcn_spokes.drg.id : null
      description = "${vcn_name} traffic to DRG"
    } if subnet.vcn_id != vcn.id
  ]
  )
  } if length(regexall(".*-${local.spoke_subnet_names[2]}-*", key)) > 0 }
  


  lz_spoke_subnet_route_tables = merge(local.web_spoke_route_route_tables,
    local.app_spoke_route_route_tables,
    local.db_spoke_route_route_tables,
  local.outdoor_dmz_route_route_tables)

}

module "lz_vcn_spokes" {
  source               = "../modules/network/vcn-basic"
  compartment_id       = module.lz_compartments.compartments[local.network_compartment_name].id
  service_label        = var.service_label
  service_gateway_cidr = local.valid_service_gateway_cidrs[0]
  is_create_drg        = var.is_vcn_onprem_connected || var.hub_spoke_architecture
  vcns                 = local.all_lz_spoke_vcns
}


module "lz_route_tables_spokes" {
  depends_on           = [ module.lz_vcn_spokes ]
  source               = "../modules/network/vcn-routing"
  compartment_id       = module.lz_compartments.compartments[local.network_compartment_name].id
  subnets_route_tables = local.lz_spoke_subnet_route_tables
}

