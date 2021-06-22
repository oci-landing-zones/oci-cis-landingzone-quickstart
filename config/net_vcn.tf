# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  # # Subnet Names used can be changed first subnet will be Public if var.no_internet_access is false
  # spoke_subnet_names = ["web", "app", "db"]
  # # Subnet Names used can be changed first subnet will be Public if var.no_internet_access is false
  # dmz_subnet_names = ["outdoor","indoor","mgmt","ha", "diag"]

  vcn_names = { for v in var.vcn_cidrs : "vcn${index(var.vcn_cidrs, v)}" => {
    name = length(var.vcn_names) > 0 ? var.vcn_names[index(var.vcn_cidrs, v)] : "${var.service_label}-${index(var.vcn_cidrs, v)}-vcn"
    cidr = v
    }
  }


  ### VCNs ###
  vcns = { for key, vcn in local.vcn_names : vcn.name => {
    compartment_id    = module.lz_compartments.compartments[local.network_compartment_name].id
    cidr              = vcn.cidr
    dns_label         = key
    is_create_igw     = var.dmz_vcn_cidr != null ? false : (!var.no_internet_access == true ? true : false)
    is_create_drg     = var.is_vcn_onprem_connected == true || var.hub_spoke_architecture == true ? true : false
    is_attach_drg     = var.is_vcn_onprem_connected == true || var.hub_spoke_architecture == true ? true : false
    block_nat_traffic = false
    defined_tags      = null
    subnets = { for s in local.spoke_subnet_names : "${vcn.name}-${s}-snt" => {
      compartment_id  = null
      defined_tags    = null
      cidr            = cidrsubnet(vcn.cidr, 4, index(local.spoke_subnet_names, s))
      dns_label       = s
      private         = var.dmz_vcn_cidr != null || var.no_internet_access ? true : (index(local.spoke_subnet_names, s) == 0 ? false : true)
      dhcp_options_id = null
      }
    }
    }
  }

  # All VCNs
  all_lz_spoke_vcns = local.vcns

  # Output from VCNs
  all_lz_spoke_vcn_ids = module.lz_vcn_spokes.vcns
  all_lz_spoke_subnets = module.lz_vcn_spokes.subnets

  ### Route Tables ###
  ## Web Subnet Route Tables
  web_route_tables = { for key, subnet in local.all_lz_spoke_subnets : replace("${key}-route-table","vcn-","") => {
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
        description       = "Object Storage Service to SGW"
      },
      {
        is_create         = var.dmz_vcn_cidr != null
        destination       = local.anywhere
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.lz_vcn_spokes.drg != null ? module.lz_vcn_spokes.drg.id : null
        description       = "All traffic goes to the DMZ"
      },
      {
        is_create         = var.is_vcn_onprem_connected && var.dmz_vcn_cidr == null
        destination       = var.onprem_cidr[0]
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.lz_vcn_spokes.drg != null ? module.lz_vcn_spokes.drg.id : null
        description       = "${var.onprem_cidr[0]} to DRG"
      },
      {
        is_create         = var.dmz_vcn_cidr == null && !var.no_internet_access ? true : false
        destination       = local.anywhere
        destination_type  = "CIDR_BLOCK"
        network_entity_id = var.dmz_vcn_cidr == null && !var.no_internet_access ? module.lz_vcn_spokes.internet_gateways[subnet.vcn_id].id : null
        description       = "${local.anywhere} to Internet Gateway"

      }
    ],
    [ for vcn_name, vcn in local.all_lz_spoke_vcn_ids : {
      is_create = var.hub_spoke_architecture && var.dmz_vcn_cidr == null
      destination = vcn.cidr_block
      destination_type = "CIDR_BLOCK"
      network_entity_id = module.lz_vcn_spokes.drg != null ? module.lz_vcn_spokes.drg.id : null
      description = "${vcn_name} to DRG"
    } if subnet.vcn_id != vcn.id
  ]
  )
  } if length(regexall(".*-${local.spoke_subnet_names[0]}-*", key)) > 0 }

  ## App Subnet Route Tables
  app_route_tables = { for key, subnet in local.all_lz_spoke_subnets : replace("${key}-route-table","vcn-","") => {
    compartment_id = subnet.compartment_id
    vcn_id         = subnet.vcn_id
    subnet_id      = subnet.id
    defined_tags   = null
    route_rules = concat([{
      is_create         = true
      destination       = local.valid_service_gateway_cidrs[0]
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = module.lz_vcn_spokes.service_gateways[subnet.vcn_id].id
      description       = "All OSN Sercices to SGW"
      },
      {
        is_create         = var.dmz_vcn_cidr != null
        destination       = local.anywhere
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.lz_vcn_spokes.drg != null ? module.lz_vcn_spokes.drg.id : null
        description       = "All traffic goes to the DMZ"
      },
      {
        is_create         = var.is_vcn_onprem_connected && var.dmz_vcn_cidr == null
        destination       = var.onprem_cidr[0]
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.lz_vcn_spokes.drg != null ? module.lz_vcn_spokes.drg.id : null
        description       = "${var.onprem_cidr[0]} to DRG"
      },
      {
        is_create         = var.dmz_vcn_cidr == null && !var.no_internet_access ? true : false
        destination       = local.anywhere
        destination_type  = "CIDR_BLOCK"
        network_entity_id = var.dmz_vcn_cidr == null && !var.no_internet_access ? module.lz_vcn_spokes.nat_gateways[subnet.vcn_id].id : null
        description       = "${local.anywhere} to NAT Gateway for private subnets"

      }

    ],
    [ for vcn_name, vcn in local.all_lz_spoke_vcn_ids : {
      is_create = var.hub_spoke_architecture && var.dmz_vcn_cidr == null
      destination = vcn.cidr_block
      destination_type = "CIDR_BLOCK"
      network_entity_id = module.lz_vcn_spokes.drg != null ? module.lz_vcn_spokes.drg.id : null
      description = "${vcn_name} to DRG"
    } if subnet.vcn_id != vcn.id
  ]
  )
  } if length(regexall(".*-${local.spoke_subnet_names[1]}-*", key)) > 0 }

  ## Database Subnet Route Tables
  db_route_tables = { for key, subnet in local.all_lz_subnets : replace("${key}-route-table","vcn-","") => {
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
        is_create         = var.is_vcn_onprem_connected && var.dmz_vcn_cidr == null
        destination       = var.onprem_cidr[0]
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.lz_vcn_spokes.drg != null ? module.lz_vcn_spokes.drg.id : null
        description       = "${var.onprem_cidr[0]} to DRG"
      },
      {
        is_create         = var.dmz_vcn_cidr != null
        destination       = local.anywhere
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.lz_vcn_spokes.drg != null ? module.lz_vcn_spokes.drg.id : null
        description       = "${local.anywhere} to DRG to access spokes and ${var.onprem_cidr[0]}"
      }
    ],
    [ for vcn_name, vcn in local.all_lz_spoke_vcn_ids : {
      is_create = var.hub_spoke_architecture && var.dmz_vcn_cidr == null
      destination = vcn.cidr_block
      destination_type = "CIDR_BLOCK"
      network_entity_id = module.lz_vcn_spokes.drg != null ? module.lz_vcn_spokes.drg.id : null
      description = "${vcn_name} to DRG"
    } if subnet.vcn_id != vcn.id
  ]
  )
  } if length(regexall(".*-${local.spoke_subnet_names[2]}-*", key)) > 0 }
  
  lz_subnets_route_tables = merge(local.web_route_tables, local.app_route_tables, local.db_route_tables)

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
  subnets_route_tables = local.lz_subnets_route_tables
}

