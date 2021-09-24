# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  dmz_vcn = var.hub_spoke_architecture && length(var.dmz_vcn_cidr) > 0 ? { (local.dmz_vcn_name.name) = {
    compartment_id    = module.lz_compartments.compartments[local.network_compartment.key].id
    cidr              = var.dmz_vcn_cidr
    dns_label         = "dmz"
    is_create_igw     = !var.no_internet_access
    is_attach_drg     = var.dmz_for_firewall == true ? false : true
    block_nat_traffic = false
    defined_tags      = null
    subnets = { for s in range(var.dmz_number_of_subnets) : "${local.dmz_vcn_name.name}-${local.dmz_subnet_names[s]}-subnet" => {
      compartment_id  = null
      name            = "${local.dmz_vcn_name.name}-${local.dmz_subnet_names[s]}-subnet"
      cidr            = cidrsubnet(var.dmz_vcn_cidr, var.dmz_subnet_size, s)
      dns_label       = local.dmz_subnet_names[s]
      private         = var.no_internet_access ? true : s == 0 || (local.is_mgmt_subnet_public && s == 2) ? false : true
      dhcp_options_id = null
      defined_tags    = null
      security_lists = { "security-list" : {
        compartment_id : null
        is_create : true
        ingress_rules : []
        egress_rules : []
        defined_tags  = null
        freeform_tags = null
      }}
    }}
  }} : {}

  dmz_route_tables = { for key, subnet in module.lz_vcn_dmz.subnets : replace("${key}-rtable", "vcn-", "") => {
    compartment_id = subnet.compartment_id
    vcn_id         = subnet.vcn_id
    subnet_id      = subnet.id
    defined_tags   = null
    route_rules = concat([{
      is_create         = var.no_internet_access
      destination       = local.valid_service_gateway_cidrs[0]
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = module.lz_vcn_dmz.service_gateways[subnet.vcn_id].id
      description       = "Traffic destined to ${local.valid_service_gateway_cidrs[0]} goes to Service Gateway."
      },
      {
        is_create         = !var.no_internet_access
        destination       = local.valid_service_gateway_cidrs[1]
        destination_type  = "SERVICE_CIDR_BLOCK"
        network_entity_id = module.lz_vcn_dmz.service_gateways[subnet.vcn_id].id
        description       = "Traffic destined to ${local.valid_service_gateway_cidrs[1]} goes to Service Gateway."
      },
      {
        is_create         = !var.no_internet_access
        destination       = local.anywhere
        destination_type  = "CIDR_BLOCK"
        network_entity_id = !var.no_internet_access ? module.lz_vcn_dmz.internet_gateways[subnet.vcn_id].id : null
        description       = "Traffic destined to ${local.anywhere} CIDR range goes to Internet Gateway."

      }
      ],
      [for vcn_name, vcn in module.lz_vcn_spokes.vcns : {
        is_create         = var.hub_spoke_architecture
        destination       = vcn.cidr_block
        destination_type  = "CIDR_BLOCK"
        network_entity_id = var.existing_drg_id != "" ? var.existing_drg_id : (module.lz_drg.drg != null ? module.lz_drg.drg.id : null)
        description       = "Traffic destined to ${vcn_name} VCN (${vcn.cidr_block} CIDR range) goes to DRG."
        }
      ],
      [for cidr in var.onprem_cidrs : {
        is_create         = true
        destination       = cidr
        destination_type  = "CIDR_BLOCK"
        network_entity_id = var.existing_drg_id != "" ? var.existing_drg_id : (module.lz_drg.drg != null ? module.lz_drg.drg.id : null)
        description       = "Traffic destined to on-premises ${cidr} CIDR range goes to DRG."
        }
      ],
      [for cidr in var.exacs_vcn_cidrs : {
        is_create         = var.hub_spoke_architecture
        destination       = cidr
        destination_type  = "CIDR_BLOCK"
        network_entity_id = var.existing_drg_id != "" ? var.existing_drg_id : (module.lz_drg.drg != null ? module.lz_drg.drg.id : null)
        description       = "Traffic destined to Exadata VCN (${cidr} CIDR range) goes to DRG."
        }
      ])
  }}
}


module "lz_vcn_dmz" {
  depends_on           = [module.lz_vcn_spokes]
  source               = "../modules/network/vcn-basic"
  compartment_id       = module.lz_compartments.compartments[local.network_compartment.key].id
  service_label        = var.service_label
  service_gateway_cidr = local.valid_service_gateway_cidrs[0]
  drg_id               = var.existing_drg_id != "" ? var.existing_drg_id : (module.lz_drg.drg != null ? module.lz_drg.drg.id : null)
  vcns                 = local.dmz_vcn
}

module "lz_route_tables_dmz" {
  depends_on           = [module.lz_vcn_dmz]
  source               = "../modules/network/vcn-routing"
  compartment_id       = module.lz_compartments.compartments[local.network_compartment.key].id
  subnets_route_tables = local.dmz_route_tables
}