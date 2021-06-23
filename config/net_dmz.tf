# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  dmz_vcn = var.hub_spoke_architecture && var.dmz_vcn_cidr != null ? { (local.dmz_vcn_name.name) = {
    compartment_id    = module.lz_compartments.compartments[local.network_compartment_name].id
    cidr              = var.dmz_vcn_cidr
    dns_label         = "dmz"
    is_create_igw     = !var.no_internet_access
    is_create_drg     = false
    is_attach_drg     = true
    block_nat_traffic = false
    defined_tags      = null
    subnets = { for s in range(var.dmz_number_of_subnets) : "${local.dmz_vcn_name.name}-${local.dmz_subnet_names[s]}-snt" => {
      compartment_id  = null
      defined_tags    = null
      cidr            = cidrsubnet(var.dmz_vcn_cidr, var.dmz_subnet_size, s)
      dns_label       = local.dmz_subnet_names[s]
      private         = var.no_internet_access ? true : s == 0 ? false : true
      dhcp_options_id = null
      }
    }
    }

  } : {}

  dmz_route_tables = { for key, subnet in module.lz_vcn_dmz.subnets : replace("${key}-route-table", "vcn-", "") => {
    compartment_id = subnet.compartment_id
    vcn_id         = subnet.vcn_id
    subnet_id      = subnet.id
    defined_tags   = null
    route_rules = concat([{
      is_create         = var.no_internet_access
      destination       = local.valid_service_gateway_cidrs[0]
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = module.lz_vcn_dmz.service_gateways[subnet.vcn_id].id
      description       = "All OSN Services to SGW"
      },
      {
        is_create         = !var.no_internet_access
        destination       = local.valid_service_gateway_cidrs[1]
        destination_type  = "SERVICE_CIDR_BLOCK"
        network_entity_id = module.lz_vcn_dmz.service_gateways[subnet.vcn_id].id
        description       = "Object Storage Services to SGW"
      },
      {
        is_create         = !var.no_internet_access
        destination       = local.anywhere
        destination_type  = "CIDR_BLOCK"
        network_entity_id = !var.no_internet_access ? module.lz_vcn_dmz.internet_gateways[subnet.vcn_id].id : null
        description       = "${local.anywhere} to IGW"

      }
      ],
      [for vcn_name, vcn in module.lz_vcn_spokes.vcns : {
        is_create         = var.hub_spoke_architecture
        destination       = vcn.cidr_block
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.lz_vcn_spokes.drg != null ? module.lz_vcn_spokes.drg.id : null
        description       = "${vcn_name} traffic to DRG"
        }
      ],
      [for cidr in var.onprem_cidrs : {
        is_create         = var.is_vcn_onprem_connected
        destination       = cidr
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.lz_vcn_spokes.drg != null ? module.lz_vcn_spokes.drg.id : null
        description       = "${cidr} to DRG"

        }

    ])
  } }

}


module "lz_vcn_dmz" {
  depends_on           = [module.lz_vcn_spokes]
  source               = "../modules/network/vcn-basic"
  compartment_id       = module.lz_compartments.compartments[local.network_compartment_name].id
  service_label        = var.service_label
  service_gateway_cidr = local.valid_service_gateway_cidrs[0]
  is_create_drg        = false # created by spokes VCN
  drg_id               = module.lz_vcn_spokes.drg != null ? module.lz_vcn_spokes.drg.id : null
  vcns                 = local.dmz_vcn
}

module "lz_route_tables_dmz" {
  depends_on           = [module.lz_vcn_dmz]
  source               = "../modules/network/vcn-routing"
  compartment_id       = module.lz_compartments.compartments[local.network_compartment_name].id
  subnets_route_tables = local.dmz_route_tables
}