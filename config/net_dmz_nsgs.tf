# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration creates Landing Zone NSGs (Network Security Groups) for the DMZ VCN

locals {
  all_dmz_nsgs_defined_tags = {}
  all_dmz_nsgs_freeform_tags = {}
  
  dmz_bastions_nsg_name   = length(var.dmz_vcn_cidr) > 0 ? "${local.dmz_vcn_name.name}-bastion-nsg" : null
  dmz_services_nsg_name   = length(var.dmz_vcn_cidr) > 0 ? "${local.dmz_vcn_name.name}-services-nsg" : null
  dmz_public_dst_nsg_name = length(var.dmz_vcn_cidr) > 0 ? "${local.dmz_vcn_name.name}-public-dst-nsg" : null

  ssh_dmz_to_spokes_nsg_egress_rules = length(var.dmz_vcn_cidr) > 0 ? { for k, v in module.lz_vcn_spokes.vcns : "${k}-dmz-ssh-egress-rule" => {
    is_create : true,
    description : "Allows SSH connections to hosts in ${k} VCN (${v.cidr_block} CIDR range).",
    protocol : "6",
    stateless : false,
    dst : v.cidr_block,
    dst_type : "CIDR_BLOCK",
    dst_port_min : 22,
    dst_port_max : 22,
    src_port_min : null,
    src_port_max : null,
    icmp_type : null,
    icmp_code : null
  } } : {}

  ssh_dmz_to_exacs_nsg_egress_rules = length(var.dmz_vcn_cidr) > 0 && length(var.exacs_vcn_cidrs) > 0 ? { for k, v in module.lz_exacs_vcns.vcns : "ssh-exacs-${k}-egress-rule" => {
    is_create : true,
    description : "Allows SSH connections to hosts in Exadata ${k} VCN (${v.cidr_block} CIDR range).",
    protocol : "6",
    stateless : false,
    dst : v.cidr_block,
    dst_type : "CIDR_BLOCK",
    dst_port_min : 22,
    dst_port_max : 22,
    src_port_min : null,
    src_port_max : null,
    icmp_type : null,
    icmp_code : null
  } } : {}

  ons_dmz_to_exacs_nsg_egress_rules = length(var.dmz_vcn_cidr) > 0 && length(var.exacs_vcn_cidrs) > 0 ? { for k, v in module.lz_exacs_vcns.vcns : "ons-exacs-${k}-egress-rule" => {
    is_create : true,
    description : "Allows Oracle Notification Services (ONS) communication to hosts in Exadata ${k} VCN (${v.cidr_block} CIDR range) for Fast Application Notifications (FAN).",
    protocol : "6",
    stateless : false,
    dst : v.cidr_block,
    dst_type : "CIDR_BLOCK",
    dst_port_min : 6200,
    dst_port_max : 6200,
    src_port_min : null,
    src_port_max : null,
    icmp_type : null,
    icmp_code : null
  } } : {}

  sqlnet_dmz_to_exacs_nsg_egress_rules = length(var.dmz_vcn_cidr) > 0 && length(var.exacs_vcn_cidrs) > 0 ? { for k, v in module.lz_exacs_vcns.vcns : "sqlnet-exacs-${k}-egress-rule" => {
    is_create : true,
    description : "Allows SQLNet connections to hosts in Exadata ${k} VCN (${v.cidr_block} CIDR range).",
    protocol : "6",
    stateless : false,
    dst : v.cidr_block,
    dst_type : "CIDR_BLOCK",
    dst_port_min : 1521,
    dst_port_max : 1522,
    src_port_min : null,
    src_port_max : null,
    icmp_type : null,
    icmp_code : null
  } } : {}

  http_dmz_to_spokes_nsg_egress_rules = length(var.dmz_vcn_cidr) > 0 ? { for k, v in module.lz_vcn_spokes.vcns : "${k}-dmz-http-egress-rule" => {
    is_create : true,
    description : "Allows HTTP connections to ${k} VCN (${v.cidr_block} CIDR range).",
    protocol : "6",
    stateless : false,
    dst : v.cidr_block,
    dst_type : "CIDR_BLOCK",
    dst_port_min : 80,
    dst_port_max : 80,
    src_port_min : null,
    src_port_max : null,
    icmp_type : null,
    icmp_code : null
  } } : {}

  public_dst_cidrs_nsg = length(var.public_dst_cidrs) > 0 && length(var.dmz_vcn_cidr) > 0 ? { (local.dmz_public_dst_nsg_name) : {
    vcn_id = module.lz_vcn_dmz.vcns[local.dmz_vcn_name.name].id
    defined_tags = local.dmz_nsgs_defined_tags
    freeform_tags = local.dmz_nsgs_freeform_tags
    ingress_rules : {},
    egress_rules : { for cidr in var.public_dst_cidrs : "https-public-dst-egress-rule-${index(var.public_dst_cidrs, cidr)}" => {
      is_create : length(var.public_dst_cidrs) > 0 && !var.no_internet_access && length(var.dmz_vcn_cidr) > 0,
      description : "Allows HTTPS connections to hosts in ${cidr} CIDR range.",
      stateless : false,
      protocol : "6",
      dst      = cidr,
      dst_type = "CIDR_BLOCK",
      src_port_min : null,
      src_port_max : null,
      dst_port_min : 443,
      dst_port_max : 443,
      icmp_code : null,
      icmp_type : null
    } }
  } } : {}

  ### DON'T TOUCH THESE ###
  default_dmz_nsgs_defined_tags = null
  default_dmz_nsgs_freeform_tags = local.landing_zone_tags
  
  dmz_nsgs_defined_tags = length(local.all_dmz_nsgs_defined_tags) > 0 ? local.all_dmz_nsgs_defined_tags : local.default_dmz_nsgs_defined_tags
  dmz_nsgs_freeform_tags = length(local.all_dmz_nsgs_freeform_tags) > 0 ? merge(local.all_dmz_nsgs_freeform_tags, local.default_dmz_nsgs_freeform_tags) : local.default_dmz_nsgs_freeform_tags
  
}

module "lz_nsgs_dmz" {
  depends_on     = [module.lz_vcn_dmz]
  count          = length(var.dmz_vcn_cidr) > 0 && var.hub_spoke_architecture ? 1 : 0
  source         = "../modules/network/security"
  compartment_id = local.network_compartment_id #module.lz_compartments.compartments[local.network_compartment.key].id
  nsgs = merge(local.public_dst_cidrs_nsg, {
    (local.dmz_bastions_nsg_name) : {
      vcn_id = module.lz_vcn_dmz.vcns[local.dmz_vcn_name.name].id
      defined_tags = local.dmz_nsgs_defined_tags
      freeform_tags = local.dmz_nsgs_freeform_tags
      ingress_rules : merge(
        { for cidr in var.public_src_bastion_cidrs : "ssh-public-ingress-rule-${index(var.public_src_bastion_cidrs, cidr)}" => {
          is_create : (!var.no_internet_access && length(var.onprem_cidrs) == 0 && length(var.public_src_bastion_cidrs) > 0),
          description : "Allows SSH connections from hosts in ${cidr} CIDR range.",
          protocol : "6",
          stateless : false,
          src : cidr,
          src_type : "CIDR_BLOCK",
          dst_port_min : 22,
          dst_port_max : 22,
          src_port_min : null,
          src_port_max : null,
          icmp_type : null,
          icmp_code : null
        } },
        { for cidr in var.onprem_src_ssh_cidrs : "ssh-onprem-ingress-rule-${index(var.onprem_src_ssh_cidrs, cidr)}" => {
          is_create : length(var.onprem_src_ssh_cidrs) > 0,
          description : "Allows SSH connections from hosts in on-premises ${cidr} CIDR range.",
          protocol : "6",
          stateless : false,
          src : cidr,
          src_type : "CIDR_BLOCK",
          dst_port_min : 22,
          dst_port_max : 22,
          src_port_min : null,
          src_port_max : null,
          icmp_type : null,
          icmp_code : null

          }
      },
      { for cidr in var.onprem_src_ssh_cidrs : "rdp-onprem-ingress-rule-${index(var.onprem_src_ssh_cidrs, cidr)}" => {
          is_create : length(var.onprem_src_ssh_cidrs) > 0,
          description : "Allows RDP connections from hosts in on-premises ${cidr} CIDR range.",
          protocol : "6",
          stateless : false,
          src : cidr,
          src_type : "CIDR_BLOCK",
          dst_port_min : 3389,
          dst_port_max : 3389,
          src_port_min : null,
          src_port_max : null,
          icmp_type : null,
          icmp_code : null

          }
      }
      ),
      egress_rules : merge(local.ssh_dmz_to_spokes_nsg_egress_rules, local.ssh_dmz_to_exacs_nsg_egress_rules,
        { dmz-services-egress-rule : {
          is_create : true,
          description : "Allows SSH connections to hosts in ${local.dmz_services_nsg_name} NSG.",
          protocol : "6",
          stateless : false,
          dst      = local.dmz_services_nsg_name,
          dst_type = "NSG_NAME",
          dst_port_min : 22,
          dst_port_max : 22,
          src_port_min : null,
          src_port_max : null,
          icmp_type : null,
          icmp_code : null
        } },
        { osn-services-egress-rule : {
          is_create : true,
          description : "Allows HTTPS connections to hosts in ${local.valid_service_gateway_cidrs[0]}.",
          protocol : "6",
          stateless : false,
          dst      = local.valid_service_gateway_cidrs[0],
          dst_type = "SERVICE_CIDR_BLOCK",
          dst_port_min : 443,
          dst_port_max : 443,
          src_port_min : null,
          src_port_max : null,
          icmp_type : null,
          icmp_code : null
      } })
    },
    (local.dmz_services_nsg_name) : {
      vcn_id = module.lz_vcn_dmz.vcns[local.dmz_vcn_name.name].id
      defined_tags = local.dmz_nsgs_defined_tags
      freeform_tags = local.dmz_nsgs_freeform_tags
      ingress_rules : merge({
        ssh-ingress-rule : {
          is_create : true,
          description : "Allows SSH connections from hosts in ${local.dmz_bastions_nsg_name} NSG.",
          protocol : "6",
          stateless : false,
          src : local.dmz_bastions_nsg_name,
          src_type : "NSG_NAME",
          dst_port_min : 22,
          dst_port_max : 22,
          src_port_min : null,
          src_port_max : null,
          icmp_type : null,
          icmp_code : null
        }
        }, { for cidr in var.onprem_cidrs : "http-onprem-ingress-rule-${index(var.onprem_cidrs, cidr)}" => {
          is_create : length(var.onprem_cidrs) > 0,
          description : "Allows HTTPS connections from hosts in on-premises ${cidr} CIDR range.",
          protocol : "6",
          stateless : false,
          src : cidr,
          src_type : "CIDR_BLOCK",
          dst_port_min : 443,
          dst_port_max : 443,
          src_port_min : null,
          src_port_max : null,
          icmp_type : null,
          icmp_code : null
        }
        },
        { for cidr in var.public_src_lbr_cidrs : "http-public-ingress-rule--${index(var.public_src_lbr_cidrs, cidr)}" => {
          is_create : !var.no_internet_access && length(var.public_src_lbr_cidrs) > 0,
          description : "Allows HTTPS connections from hosts in ${cidr} CIDR range.",
          protocol : "6",
          stateless : false,
          src : cidr,
          src_type : "CIDR_BLOCK",
          dst_port_min : 443,
          dst_port_max : 443,
          src_port_min : null,
          src_port_max : null,
          icmp_type : null,
          icmp_code : null
          }
      }),
      egress_rules : merge(local.http_dmz_to_spokes_nsg_egress_rules, local.ons_dmz_to_exacs_nsg_egress_rules, local.sqlnet_dmz_to_exacs_nsg_egress_rules,
        { osn-services-egress-rule : {
          is_create : true,
          description : "Allows HTTPS connections to ${local.valid_service_gateway_cidrs[0]}.",
          protocol : "6",
          stateless : false,
          dst      = local.valid_service_gateway_cidrs[0],
          dst_type = "SERVICE_CIDR_BLOCK",
          dst_port_min : 443,
          dst_port_max : 443,
          src_port_min : null,
          src_port_max : null,
          icmp_type : null,
          icmp_code : null
      } })
  } })
}