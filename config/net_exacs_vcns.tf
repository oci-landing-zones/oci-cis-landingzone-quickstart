/* # Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  public_subnet_prefix = "pub"
  client_subnet_prefix = "clt"
  backup_subnet_prefix = "bkp"

  exacs_subnet_names = var.add_public_subnet_to_exacs_vcns == true ? [local.public_subnet_prefix, local.client_subnet_prefix, local.backup_subnet_prefix] : [local.client_subnet_prefix, local.backup_subnet_prefix]

  exacs_vcns_map = { for v in var.exacs_vcn_cidrs : "vcn${index(var.exacs_vcn_cidrs, v)}" => {
    name = length(var.exacs_vcn_names) > 0 ? (length(regexall("[a-zA-Z0-9-]+", var.exacs_vcn_names[index(var.exacs_vcn_cidrs, v)])) > 0 ? join("", regexall("[a-zA-Z0-9-]+", var.exacs_vcn_names[index(var.exacs_vcn_cidrs, v)])) : var.exacs_vcn_names[index(var.exacs_vcn_cidrs, v)]) : "${var.service_label}-${index(var.exacs_vcn_cidrs, v)}-vcn"
    cidr = v
    }
  }

  ### VCNs ###
  exacs_vcns = { for key, vcn in local.exacs_vcns_map : vcn.name => {
    compartment_id    = module.lz_compartments.compartments[local.network_compartment_name].id
    cidr              = vcn.cidr
    dns_label         = length(regexall("[a-zA-Z0-9]+", vcn.name)) > 0 ? "${substr(join("", regexall("[a-zA-Z0-9]+", vcn.name)), 0, 11)}${local.region_key}" : "${substr(vcn.name, 0, 11)}${local.region_key}"
    is_create_igw     = length(var.dmz_vcn_cidr) > 0 ? false : (!var.no_internet_access == true ? true : false)
    is_create_drg     = var.is_vcn_onprem_connected == true || var.hub_spoke_architecture == true ? true : false
    is_attach_drg     = var.is_vcn_onprem_connected == true || var.hub_spoke_architecture == true ? true : false
    block_nat_traffic = false
    defined_tags      = null
    subnets = { for s in local.exacs_subnet_names : replace("${vcn.name}-${s}-snt", "-vcn", "") => {
      compartment_id  = null
      defined_tags    = null
      cidr            = cidrsubnet(vcn.cidr, 4, index(local.exacs_subnet_names, s))
      dns_label       = s
      private         = length(var.dmz_vcn_cidr) > 0 || var.no_internet_access ? true : (s == local.public_subnet_prefix ? false : true)
      dhcp_options_id = null
      }}
    }}

  ### Route Tables ###
  ## Public Subnet Route Tables
  pub_route_tables = { for key, subnet in module.lz_exacs_vcns.subnets : replace("${key}-rtable", "vcn-", "") => {
    compartment_id = subnet.compartment_id
    vcn_id         = subnet.vcn_id
    subnet_id      = subnet.id
    defined_tags   = null
    route_rules = concat([{
      is_create         = length(var.dmz_vcn_cidr) > 0 || var.no_internet_access ? true : false
      destination       = local.valid_service_gateway_cidrs[0]
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = module.lz_exacs_vcns.service_gateways[subnet.vcn_id].id
      description       = "All OSN Services to SGW"
      },
      {
        is_create         = length(var.dmz_vcn_cidr) > 0
        destination       = local.anywhere
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.lz_exacs_vcns.drg != null ? module.lz_exacs_vcns.drg.id : null
        description       = "All traffic goes to the DMZ"
      },
      {
        is_create         = length(var.dmz_vcn_cidr) == 0 && !var.no_internet_access ? true : false
        destination       = local.anywhere
        destination_type  = "CIDR_BLOCK"
        network_entity_id = length(var.dmz_vcn_cidr) == 0 && !var.no_internet_access ? module.lz_exacs_vcns.internet_gateways[subnet.vcn_id].id : null
        description       = "${local.anywhere} to Internet Gateway"
      }
      ],
      [for vcn_name, vcn in module.lz_exacs_vcns.vcns : {
        is_create         = var.hub_spoke_architecture && length(var.dmz_vcn_cidr) == 0
        destination       = vcn.cidr_block
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.lz_exacs_vcns.drg != null ? module.lz_exacs_vcns.drg.id : null
        description       = "${vcn_name} to DRG"
        } if subnet.vcn_id != vcn.id
      ],
      [for cidr in var.onprem_cidrs : {
        is_create         = var.is_vcn_onprem_connected && length(var.dmz_vcn_cidr) == 0
        destination       = cidr
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.lz_exacs_vcns.drg != null ? module.lz_exacs_vcns.drg.id : null
        description       = "On-premises ${cidr} to DRG"
        }
      ]
    )
  } if length(regexall(".*-${local.public_subnet_prefix}-*", key)) > 0 }

  ## App Subnet Route Tables
  clt_route_tables = { for key, subnet in module.lz_exacs_vcns.subnets : replace("${key}-rtable", "vcn-", "") => {
    compartment_id = subnet.compartment_id
    vcn_id         = subnet.vcn_id
    subnet_id      = subnet.id
    defined_tags   = null
    route_rules = concat([{
      is_create         = true
      destination       = local.valid_service_gateway_cidrs[0]
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = module.lz_exacs_vcns.service_gateways[subnet.vcn_id].id
      description       = "All OSN Sercices to SGW"
      },
      {
        is_create         = length(var.dmz_vcn_cidr) > 0
        destination       = local.anywhere
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.lz_exacs_vcns.drg != null ? module.lz_exacs_vcns.drg.id : null
        description       = "All traffic goes to the DMZ"
      },
      {
        is_create         = length(var.dmz_vcn_cidr) == 0 && !var.no_internet_access ? true : false
        destination       = local.anywhere
        destination_type  = "CIDR_BLOCK"
        network_entity_id = length(var.dmz_vcn_cidr) == 0 && !var.no_internet_access ? module.lz_exacs_vcns.nat_gateways[subnet.vcn_id].id : null
        description       = "${local.anywhere} to NAT Gateway for private subnets"

      }

      ],
      [for vcn_name, vcn in module.lz_exacs_vcns.vcns : {
        is_create         = var.hub_spoke_architecture && length(var.dmz_vcn_cidr) == 0
        destination       = vcn.cidr_block
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.lz_exacs_vcns.drg != null ? module.lz_exacs_vcns.drg.id : null
        description       = "${vcn_name} to DRG"
        } if subnet.vcn_id != vcn.id
      ],
      [for cidr in var.onprem_cidrs : {
        is_create         = var.is_vcn_onprem_connected && length(var.dmz_vcn_cidr) == 0
        destination       = cidr
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.lz_exacs_vcns.drg != null ? module.lz_exacs_vcns.drg.id : null
        description       = "On-premises ${cidr} to DRG"
        }
      ]
    )
  } if length(regexall(".*-${local.client_subnet_prefix}-*", key)) > 0 }

  ## Database Subnet Route Tables
  bkp_route_tables = { for key, subnet in module.lz_exacs_vcns.subnets : replace("${key}-rtable", "vcn-", "") => {
    compartment_id = subnet.compartment_id
    vcn_id         = subnet.vcn_id
    subnet_id      = subnet.id
    defined_tags   = null
    route_rules = concat([{
      is_create         = true
      destination       = local.valid_service_gateway_cidrs[0]
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = module.lz_exacs_vcns.service_gateways[subnet.vcn_id].id
      description       = "All OSN Services to SGW"
      },
      {
        is_create         = length(var.dmz_vcn_cidr) > 0
        destination       = local.anywhere
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.lz_exacs_vcns.drg != null ? module.lz_exacs_vcns.drg.id : null
        description       = "${local.anywhere} to DRG to access spokes and on-premises"
      }
      ],
      [for vcn_name, vcn in module.lz_exacs_vcns.vcns : {
        is_create         = var.hub_spoke_architecture && length(var.dmz_vcn_cidr) == 0
        destination       = vcn.cidr_block
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.lz_exacs_vcns.drg != null ? module.lz_exacs_vcns.drg.id : null
        description       = "${vcn_name} to DRG"
        } if subnet.vcn_id != vcn.id
      ],
      [for cidr in var.onprem_cidrs : {
        is_create         = var.is_vcn_onprem_connected && length(var.dmz_vcn_cidr) == 0
        destination       = cidr
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.lz_exacs_vcns.drg != null ? module.lz_exacs_vcns.drg.id : null
        description       = "On-premises ${cidr} to DRG"
        }
    ])
  } if length(regexall(".*-${local.backup_subnet_prefix}-*", key)) > 0 }

  exacs_subnets_route_tables = merge(local.pub_route_tables, local.clt_route_tables, local.bkp_route_tables)

}

module "lz_exacs_vcns" {
  source               = "../modules/network/vcn-basic"
  compartment_id       = module.lz_compartments.compartments[local.network_compartment_name].id
  service_label        = var.service_label
  service_gateway_cidr = local.valid_service_gateway_cidrs[0]
  is_create_drg        = var.is_vcn_onprem_connected || var.hub_spoke_architecture
  vcns                 = local.exacs_vcns
}


module "lz_exacs_route_tables" {
  depends_on           = [module.lz_exacs_vcns]
  source               = "../modules/network/vcn-routing"
  compartment_id       = module.lz_compartments.compartments[local.network_compartment_name].id
  subnets_route_tables = local.exacs_subnets_route_tables
}

 */