# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration creates Landing Zone NSGs (Network Security Groups) for the DMZ VCN

locals {
  dmz_bastions_nsg_name = var.dmz_vcn_cidr != null ? "${local.dmz_vcn_name.name}-bastion-nsg" : null
  dmz_services_nsg_name = var.dmz_vcn_cidr != null ? "${local.dmz_vcn_name.name}-services-nsg" : null
  dmz_public_dst_nsg_name = var.dmz_vcn_cidr != null ? "${local.dmz_vcn_name.name}-public-dst-nsg" : null

  ssh_dmz_to_spokes_nsg_egress_rules = var.dmz_vcn_cidr != null ? { for k, v in module.lz_vcn_spokes.vcns : "${k}-dmz-ssh-egress-rule" => {
    is_create : true,
    description : "SSH egress rule to ${k}.",
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
  }} : {}

  http_dmz_to_spokes_nsg_egress_rules = var.dmz_vcn_cidr != null ? { for k, v in module.lz_vcn_spokes.vcns : "${k}-dmz-http-egress-rule" => {
    is_create : true,
    description : "HTTP egress rule to ${k}.",
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
  }} : {}
  
  public_dst_cidrs_nsg = length(var.public_dst_cidrs) > 0 &&  var.dmz_vcn_cidr != null ? {(local.dmz_public_dst_nsg_name) : {
      vcn_id = module.lz_vcn_dmz.vcns[local.dmz_vcn_name.name].id
      ingress_rules : {},
      egress_rules : { for cidr in var.public_dst_cidrs : "https-public-dst-egress-rule-${index(var.public_dst_cidrs, cidr)}" => {
      is_create : length(var.public_dst_cidrs) > 0 && !var.no_internet_access && var.dmz_vcn_cidr != null,
      description : "Egress HTTPS rule to ${cidr}.",
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
    }} : {} 

}

module "lz_nsgs_dmz" {
  depends_on     = [module.lz_vcn_dmz]
  count          = var.dmz_vcn_cidr != null && var.hub_spoke_architecture  ? 1 : 0
  source         = "../modules/network/security"
  compartment_id = module.lz_compartments.compartments[local.network_compartment_name].id
  nsgs = merge(local.public_dst_cidrs_nsg,{
    (local.dmz_bastions_nsg_name) : {
      vcn_id = module.lz_vcn_dmz.vcns[local.dmz_vcn_name.name].id
      ingress_rules : merge(
        { for cidr in var.public_src_bastion_cidrs : "ssh-public-ingress-rule-${index(var.public_src_bastion_cidrs, cidr)}" => {
          is_create : (!var.no_internet_access && !var.is_vcn_onprem_connected && length(var.public_src_bastion_cidrs) > 0),
          description : "SSH ingress rule for ${cidr}.",
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
        { for cidr in var.onprem_cidrs : "ssh-onprem-ingress-rule-${index(var.onprem_cidrs, cidr)}" => {
          is_create : var.is_vcn_onprem_connected && length(var.onprem_cidrs) > 0,
          description : "SSH ingress rule for on-premises CIDR ${cidr}.",
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
      }),
      egress_rules : merge(local.ssh_dmz_to_spokes_nsg_egress_rules,
        { dmz-services-egress-rule : {
          is_create : true,
          description : "SSH egress rule to ${local.dmz_services_nsg_name}.",
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
          description : "OSN egress rule to ${local.valid_service_gateway_cidrs[0]}.",
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
      ingress_rules : merge({
        ssh-ingress-rule : {
          is_create : true,
          description : " SSH ingress rule from ${local.dmz_bastions_nsg_name}.",
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
          is_create : tobool(var.is_vcn_onprem_connected) && length(var.onprem_cidrs) > 0,
          description : "HTTPS ingress rule for on-premises CIDR ${cidr}.",
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
          description : "HTTPS ingress rule for ${cidr}.",
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
      egress_rules : merge(local.http_dmz_to_spokes_nsg_egress_rules,
        { osn-services-egress-rule : {
          is_create : true,
          description : "OSN egress rule to ${local.valid_service_gateway_cidrs[0]}.",
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
    }})
}