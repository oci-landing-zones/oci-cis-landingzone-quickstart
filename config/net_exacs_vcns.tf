# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  all_exacs_vcns_defined_tags = {}
  all_exacs_vcns_freeform_tags = {}

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

  exacs_vcns = { for key, vcn in local.exacs_vcns_map : vcn.name => {
    compartment_id    = local.network_compartment_id #module.lz_compartments.compartments[local.network_compartment.key].id
    cidr              = vcn.cidr
    dns_label         = length(regexall("[a-zA-Z0-9]+", vcn.name)) > 0 ? "${substr(join("", regexall("[a-zA-Z0-9]+", vcn.name)), 0, 11)}${local.region_key}" : "${substr(vcn.name, 0, 11)}${local.region_key}"
    is_create_igw     = false 
    is_attach_drg     = var.is_vcn_onprem_connected == true || var.hub_spoke_architecture == true ? (var.dmz_for_firewall == true ? false : true) : false
    block_nat_traffic = false
    defined_tags      = local.exacs_vncs_defined_tags
    freeform_tags     = local.exacs_vncs_freeform_tags
    subnets = { for s in local.exacs_subnet_names : replace("${vcn.name}-${s}-snt", "-vcn", "") => {
      compartment_id  = null
      name            = replace("${vcn.name}-${s}-snt", "-vcn", "")
      defined_tags    = local.exacs_vncs_defined_tags
      freeform_tags   = local.exacs_vncs_freeform_tags
      cidr            = length(vcn.subnets_cidr[s]) > 0 ? vcn.subnets_cidr[s] : cidrsubnet(vcn.cidr, 4, index(local.exacs_subnet_names, s))
      dns_label       = s
      private         = true
      dhcp_options_id = null
      security_lists  = {"security-list" = {
        is_create = true
        compartment_id = null
        ingress_rules = [{
          is_create = (s == local.client_subnet_prefix)
          protocol = "6"
          stateless = false
          description = "Allows SSH connections from hosts in Exadata client subnet."
          src = length(vcn.subnets_cidr[s]) > 0 ? vcn.subnets_cidr[s] : cidrsubnet(vcn.cidr, 4, index(local.exacs_subnet_names, s))
          icmp_type = null
          icmp_code = null
          src_port_min = null
          src_port_max = null
          src_type = "CIDR_BLOCK"
          dst_port_min = "22" 
          dst_port_max = "22"
        }]
        egress_rules = [{
          is_create = (s == local.client_subnet_prefix)
          protocol = "6"
          stateless = false
          description = "Allows SSH connections to hosts in Exadata client subnet."
          dst = length(vcn.subnets_cidr[s]) > 0 ? vcn.subnets_cidr[s] : cidrsubnet(vcn.cidr, 4, index(local.exacs_subnet_names, s))
          dst_type = "CIDR_BLOCK"
          icmp_type = null
          icmp_code = null
          src_port_min = null 
          src_port_max = null
          dst_port_min = "22"
          dst_port_max = "22"
        },
        {
          is_create = (s == local.client_subnet_prefix && length(var.onprem_cidrs) == 0 && var.hub_spoke_architecture == false)
          protocol = "6"
          stateless = false
          description = "Allows SSH connections to hosts in ${vcn.cidr} CIDR range."
          dst = vcn.cidr
          dst_type = "CIDR_BLOCK"
          icmp_type = null
          icmp_code = null
          src_port_min = null 
          src_port_max = null
          dst_port_min = "22"
          dst_port_max = "22"
        },
        {
          is_create = true
          protocol = "1"
          stateless = false
          description = "Allows the initiation of ICMP connections to hosts in ${vcn.cidr} CIDR range."
          dst = vcn.cidr
          dst_type = "CIDR_BLOCK"
          icmp_type = "3"
          icmp_code = null
          src_port_min = null 
          src_port_max = null
          dst_port_min = null
          dst_port_max = null
        }]
        defined_tags = local.exacs_vncs_defined_tags
        freeform_tags = local.exacs_vncs_freeform_tags
      }}
    }}
  }}

  ### Route Tables ###
  ## Client Subnet Route Tables
  clt_route_tables = { for key, subnet in module.lz_exacs_vcns.subnets : "${key}-rtable" => {
    compartment_id = subnet.compartment_id
    vcn_id         = subnet.vcn_id
    subnet_id      = subnet.id
    defined_tags   = local.exacs_vncs_defined_tags
    freeform_tags  = local.exacs_vncs_freeform_tags
    route_rules = concat([{
      is_create         = true
      destination       = local.valid_service_gateway_cidrs[0]
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = module.lz_exacs_vcns.service_gateways[subnet.vcn_id].id
      description       = "Traffic destined to ${local.valid_service_gateway_cidrs[0]} goes to Service Gateway."
      },
      {
      is_create         = length(var.dmz_vcn_cidr) > 0
      destination       = local.anywhere
      destination_type  = "CIDR_BLOCK"
      network_entity_id = var.existing_drg_id != "" ? var.existing_drg_id : (module.lz_drg.drg != null ? module.lz_drg.drg.id : null)
      description       = "Traffic destined to ${local.anywhere} goes to DRG."
      }],
      [for cidr in var.onprem_cidrs : {
        is_create         = length(var.dmz_vcn_cidr) == 0 && var.is_vcn_onprem_connected
        destination       = cidr
        destination_type  = "CIDR_BLOCK"
        network_entity_id = var.existing_drg_id != "" ? var.existing_drg_id : (module.lz_drg.drg != null ? module.lz_drg.drg.id : null)
        description       = "Traffic destined to on-premises ${cidr} goes to DRG."
      }],
      [for vcn_name, vcn in local.all_lz_spoke_vcn_ids : {
        is_create         = var.hub_spoke_architecture && length(var.dmz_vcn_cidr) == 0
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
    defined_tags   = local.exacs_vncs_defined_tags
    freeform_tags  = local.exacs_vncs_freeform_tags
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

  ### DON'T TOUCH THESE ###
  default_exacs_vcns_defined_tags = null
  default_exacs_vcns_freeform_tags = local.landing_zone_tags

  exacs_vncs_defined_tags = length(local.all_exacs_vcns_defined_tags) > 0 ? local.all_exacs_vcns_defined_tags : local.default_exacs_vcns_defined_tags
  exacs_vncs_freeform_tags = length(local.all_exacs_vcns_freeform_tags) > 0 ? merge(local.all_exacs_vcns_freeform_tags, local.default_exacs_vcns_freeform_tags) : local.default_exacs_vcns_freeform_tags


}

module "lz_exacs_vcns" {
  source               = "../modules/network/vcn-basic"
  compartment_id       = local.network_compartment_id #module.lz_compartments.compartments[local.network_compartment.key].id
  service_label        = var.service_label
  service_gateway_cidr = local.valid_service_gateway_cidrs[0]
  drg_id               = var.existing_drg_id != "" ? var.existing_drg_id : (module.lz_drg.drg != null ? module.lz_drg.drg.id : null)
  vcns                 = local.exacs_vcns
}


module "lz_exacs_route_tables" {
  depends_on           = [module.lz_exacs_vcns]
  source               = "../modules/network/vcn-routing"
  compartment_id       = local.network_compartment_id #module.lz_compartments.compartments[local.network_compartment.key].id
  subnets_route_tables = local.exacs_subnets_route_tables
}