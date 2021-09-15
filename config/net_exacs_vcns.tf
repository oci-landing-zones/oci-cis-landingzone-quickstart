# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  client_subnet_prefix = "clt"
  backup_subnet_prefix = "bkp"
  
  exacs_subnet_names = [local.client_subnet_prefix, local.backup_subnet_prefix]

  exacs_vcns_map = { for v in var.exacs_vcn_cidrs : "vcn${index(var.exacs_vcn_cidrs, v)}" => {
    #name = "${var.exacs_vcn_names[index(var.exacs_vcn_cidrs, v)]}-vcn" 
    name = length(var.exacs_vcn_names) > 0 ? (length(regexall("[a-zA-Z0-9-]+", var.exacs_vcn_names[index(var.exacs_vcn_cidrs, v)])) > 0 ? join("", regexall("[a-zA-Z0-9-]+", var.exacs_vcn_names[index(var.exacs_vcn_cidrs, v)])) : var.exacs_vcn_names[index(var.exacs_vcn_cidrs, v)]) : "${var.service_label}-${index(var.exacs_vcn_cidrs, v)}-exa-vcn"
    cidr = v
    subnets_cidr = {
      (local.client_subnet_prefix): length(var.exacs_client_subnet_cidrs) > 0 ? var.exacs_client_subnet_cidrs[index(var.exacs_vcn_cidrs, v)] : "", 
      (local.backup_subnet_prefix): length(var.exacs_backup_subnet_cidrs) > 0 ? var.exacs_backup_subnet_cidrs[index(var.exacs_vcn_cidrs, v)] : ""
    }
  }}

  ### VCNs ###
  exacs_vcns = { for key, vcn in local.exacs_vcns_map : vcn.name => {
    compartment_id    = module.lz_compartments.compartments[local.network_compartment.key].id
    cidr              = vcn.cidr
    dns_label         = length(regexall("[a-zA-Z0-9]+", vcn.name)) > 0 ? "${substr(join("", regexall("[a-zA-Z0-9]+", vcn.name)), 0, 11)}${local.region_key}" : "${substr(vcn.name, 0, 11)}${local.region_key}"
    is_create_igw     = length(var.dmz_vcn_cidr) > 0 ? false : true
    is_attach_drg     = length(var.onprem_cidrs) > 0 || var.hub_spoke_architecture == true ? (var.dmz_for_firewall == true ? false : true) : false
    block_nat_traffic = false
    defined_tags      = null
    subnets = { for s in local.exacs_subnet_names : replace("${vcn.name}-${s}-snt", "-vcn", "") => {
      compartment_id  = null
      defined_tags    = null
      cidr            = length(vcn.subnets_cidr[s]) > 0 ? vcn.subnets_cidr[s] : cidrsubnet(vcn.cidr, 4, index(local.exacs_subnet_names, s))
      dns_label       = s
      private         = true
      dhcp_options_id = null
      security_lists  = {}
      }}
    }}

  ### Route Tables ###
  ## Client Subnet Route Tables
  clt_route_tables = { for key, subnet in module.lz_exacs_vcns.subnets : "${key}-rtable" => {
    compartment_id = subnet.compartment_id
    vcn_id         = subnet.vcn_id
    subnet_id      = subnet.id
    defined_tags   = null
    route_rules = concat([{
      is_create         = true
      destination       = local.valid_service_gateway_cidrs[0]
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = module.lz_exacs_vcns.service_gateways[subnet.vcn_id].id
      description       = "Traffic destined to ${local.valid_service_gateway_cidrs[0]} goes to Service Gateway."
      }],
      [for vcn_name, vcn in module.lz_vcn_dmz.vcns : {
        is_create         = length(var.dmz_vcn_cidr) > 0
        destination       = vcn.cidr_block
        destination_type  = "CIDR_BLOCK"
        network_entity_id = var.existing_drg_id != "" ? var.existing_drg_id : (module.lz_drg.drg != null ? module.lz_drg.drg.id : null)
        description       = "Traffic destined to ${vcn_name} VCN goes to DRG."
      }],
      [for cidr in var.onprem_cidrs : {
        is_create         = var.existing_drg_id != "" || module.lz_drg.drg.id != null
        destination       = cidr
        destination_type  = "CIDR_BLOCK"
        network_entity_id = var.existing_drg_id != "" ? var.existing_drg_id : (module.lz_drg.drg != null ? module.lz_drg.drg.id : null)
        description       = "Traffic destined to on-premises ${cidr} goes to DRG."
      }],
      [for vcn_name, vcn in local.all_lz_spoke_vcn_ids : {
        is_create         = var.hub_spoke_architecture
        destination       = vcn.cidr_block
        destination_type  = "CIDR_BLOCK"
        network_entity_id = var.existing_drg_id != "" ? var.existing_drg_id : (module.lz_drg.drg != null ? module.lz_drg.drg.id : null)
        description       = "Traffic destined to ${vcn_name} VCN goes to DRG."
        } if subnet.vcn_id != vcn.id
      ]
    )
  } if length(regexall(".*-${local.client_subnet_prefix}-*", key)) > 0 }

  ## Backup Subnet Route Tables
  bkp_route_tables = { for key, subnet in module.lz_exacs_vcns.subnets : "${key}-rtable" => {
    compartment_id = subnet.compartment_id
    vcn_id         = subnet.vcn_id
    subnet_id      = subnet.id
    defined_tags   = null
    route_rules = concat([
      {
        is_create         = true
        destination       = local.valid_service_gateway_cidrs[0]
        destination_type  = "SERVICE_CIDR_BLOCK"
        network_entity_id = module.lz_exacs_vcns.service_gateways[subnet.vcn_id].id
        description       = "Traffic destined to ${local.valid_service_gateway_cidrs[0]} goes to Service Gateway."
      }]/* ,
      [for vcn_name, vcn in module.lz_vcn_dmz.vcns : {
        is_create         = length(var.dmz_vcn_cidr) > 0 
        destination       = vcn.cidr_block
        destination_type  = "CIDR_BLOCK"
        network_entity_id = var.existing_drg_id != "" ? var.existing_drg_id : (module.lz_drg.drg != null ? module.lz_drg.drg.id : null)
        description       = "Traffic destined to ${vcn_name} VCN goes to DRG."
      }],
      [for cidr in var.onprem_cidrs : {
        is_create         = var.existing_drg_id != "" || module.lz_drg.drg.id != null 
        destination       = cidr
        destination_type  = "CIDR_BLOCK"
        network_entity_id = var.existing_drg_id != "" ? var.existing_drg_id : (module.lz_drg.drg != null ? module.lz_drg.drg.id : null)
        description       = "Traffic destined to on-premises ${cidr} CIDR range goes to DRG."
      }],
      [for vcn_name, vcn in local.all_lz_spoke_vcn_ids : {
        is_create         = var.hub_spoke_architecture
        destination       = vcn.cidr_block
        destination_type  = "CIDR_BLOCK"
        network_entity_id = var.existing_drg_id != "" ? var.existing_drg_id : (var.existing_drg_id != "" ? var.existing_drg_id : (module.lz_drg.drg != null ? module.lz_drg.drg.id : null))
        description       = "Traffic destined to ${vcn_name} VCN goes to DRG."
        } if subnet.vcn_id != vcn.id
      ] */
    )
  } if length(regexall(".*-${local.backup_subnet_prefix}-*", key)) > 0 }

  exacs_subnets_route_tables = merge(local.clt_route_tables, local.bkp_route_tables)

}

module "lz_exacs_vcns" {
  source               = "../modules/network/vcn-basic"
  compartment_id       = module.lz_compartments.compartments[local.network_compartment.key].id
  service_label        = var.service_label
  service_gateway_cidr = local.valid_service_gateway_cidrs[0]
  drg_id               = var.existing_drg_id != "" ? var.existing_drg_id : (module.lz_drg.drg != null ? module.lz_drg.drg.id : null)
  vcns                 = local.exacs_vcns
}


module "lz_exacs_route_tables" {
  depends_on           = [module.lz_exacs_vcns]
  source               = "../modules/network/vcn-routing"
  compartment_id       = module.lz_compartments.compartments[local.network_compartment.key].id
  subnets_route_tables = local.exacs_subnets_route_tables
}