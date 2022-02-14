# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration creates NSGs (Network Security Groups) for Exadata Cloud Service networking.

locals {
  all_exacs_nsgs_defined_tags = {}
  all_exacs_nsgs_freeform_tags = {}
  
  exacs_clt_nsgs = { for k, v in module.lz_exacs_vcns.vcns : "${k}-clt-nsg" => {
    vcn_id : v.id,
    defined_tags = local.exacs_nsgs_defined_tags
    freeform_tags = local.exacs_nsgs_freeform_tags
    ingress_rules : merge({
      ssh-dmz-vcn-ingress-rule : {
        is_create : length(var.dmz_vcn_cidr) > 0,
        description : "Allows SSH connections from hosts in DMZ VCN (${var.dmz_vcn_cidr} CIDR range).",
        stateless : false,
        protocol : "6",
        src : var.dmz_vcn_cidr,
        src_type : "CIDR_BLOCK",
        dst_port_min : 22,
        dst_port_max : 22,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      },
      sqlnet-dmz_vcn-ingress-rule : {
        is_create : length(var.dmz_vcn_cidr) > 0,
        description : "Allows SQLNet connections from hosts in DMZ VCN (${var.dmz_vcn_cidr} CIDR range).",
        stateless : false,
        protocol : "6",
        src : var.dmz_vcn_cidr,
        src_type : "CIDR_BLOCK",
        dst_port_min : 1521,
        dst_port_max : 1522,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      },
      ons-dmz_vcn-ingress-rule : {
        is_create : length(var.dmz_vcn_cidr) > 0,
        description : "Allows Oracle Notification Services (ONS) communication from hosts in DMZ VCN for Fast Application Notifications (FAN).",
        stateless : false,
        protocol : "6",
        src : var.dmz_vcn_cidr,
        src_type : "CIDR_BLOCK",
        dst_port_min : 6200,
        dst_port_max : 6200,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      },
      ons-clt-nsg-ingress-rule : {
        is_create : true,
        description : "Allows Oracle Notification Services (ONS) communication from hosts in ${k}-clt-nsg NSG for Fast Application Notifications (FAN).",
        stateless : false,
        protocol : "6",
        src : "${k}-clt-nsg", 
        src_type : "NSG_NAME",
        dst_port_min : 6200,
        dst_port_max : 6200,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      },
	    sqlnet-clt-nsg-ingress-rule : {
        is_create : true,
        description : "Allows SQLNet connections from hosts in ${k}-clt-nsg NSG.",
        stateless : false,
        protocol : "6",
        src : "${k}-clt-nsg",
        src_type : "NSG_NAME",
        dst_port_min : 1521,
        dst_port_max : 1522,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      },
	    ssh-clt-nsg-ingress-rule : {
        is_create : true,
        description : "Allows SSH connections from hosts in ${k}-clt-nsg NSG.",
        stateless : false,
        protocol : "6",
        src : "${k}-clt-nsg", 
        src_type : "NSG_NAME",
        dst_port_min : 22,
        dst_port_max : 22,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      }},
      { for c in var.onprem_src_ssh_cidrs : "ssh-on-prem-ingress-rule-${index(var.onprem_src_ssh_cidrs,c)}" => {
        is_create : length(var.dmz_vcn_cidr) == 0,
        description : "Allows SSH connections from on-premises hosts included in ${c} CIDR range.",
        stateless : false,
        protocol : "6",
        src : c,
        src_type : "CIDR_BLOCK",
        dst_port_min : 22,
        dst_port_max : 22,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      }},
      { for c in var.onprem_cidrs : "sqlnet-on-prem-ingress-rule-${index(var.onprem_cidrs,c)}" => {
        is_create : true 
        description : "Allows SQLNet connections from on-premises hosts included in ${c} CIDR range.",
        stateless : false,
        protocol : "6",
        src : c,
        src_type : "CIDR_BLOCK",
        dst_port_min : 1521,
        dst_port_max : 1522,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      }},
      { for c in var.onprem_cidrs : "ons-on-prem-ingress-rule-${index(var.onprem_cidrs,c)}" => {
        is_create : true 
        description : "Allows Oracle Notification Services (ONS) communication from on-premises hosts included in ${c} CIDR range for Fast Application Notifications (FAN).",
        stateless : false,
        protocol : "6",
        src : c,
        src_type : "CIDR_BLOCK",
        dst_port_min : 6200,
        dst_port_max : 6200,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      }},
      { for k,v in module.lz_vcn_spokes.vcns : "sqlnet-spoke-${k}-ingress-rule" => {
        is_create : var.hub_spoke_architecture == true,
        description : "Allows SQLNet connections from hosts in VCN ${k} (${v.cidr_block} CIDR range).",
        stateless : false,
        protocol : "6",
        src : v.cidr_block,
        src_type : "CIDR_BLOCK",
        dst_port_min : 1521,
        dst_port_max : 1522,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      }},
      { for k,v in module.lz_vcn_spokes.vcns : "ons-spoke-${k}-ingress-rule" => {
        is_create : var.hub_spoke_architecture == true,
        description : "Allows Oracle Notification Services (ONS) communication from hosts in VCN ${k} (${v.cidr_block} CIDR range) for Fast Application Notifications (FAN).",
        stateless : false,
        protocol : "6",
        src : v.cidr_block,
        src_type : "CIDR_BLOCK",
        dst_port_min : 6200,
        dst_port_max : 6200,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      }}
    ),
    egress_rules : {
      ssh-clt-nsg-egress-rule : {
        is_create : true,
        description : "Allows SSH connections to hosts in ${k}-clt-nsg NSG.",
        stateless : false,
        protocol : "6",
        dst      = "${k}-clt-nsg",
        dst_type = "NSG_NAME",
        src_port_min : null,
        src_port_max : null,
        dst_port_min : 22,
        dst_port_max : 22,
        icmp_code : null,
        icmp_type : null
      },
      sqlnet-clt-nsg-egress-rule : {
        is_create : true,
        description : "Allows SQLNet connections to hosts in ${k}-clt-nsg NSG.",
        stateless : false,
        protocol : "6",
        dst      = "${k}-clt-nsg"
        dst_type = "NSG_NAME",
        src_port_min : null,
        src_port_max : null,
        dst_port_min : 1521,
        dst_port_max : 1522,
        icmp_code : null,
        icmp_type : null
      },
      ons-clt-nsg-egress-rule : {
        is_create : true,
        description : "Allows Oracle Notification Services (ONS) communication to hosts in ${k}-clt-nsg NSG for Fast Application Notifications (FAN).",
        stateless : false,
        protocol : "6",
        dst      = "${k}-clt-nsg"
        dst_type = "NSG_NAME",
        src_port_min : null,
        src_port_max : null,
        dst_port_min : 6200,
        dst_port_max : 6200,
        icmp_code : null,
        icmp_type : null
      }, 
      osn-services-egress-rule : {
        is_create : true,
        description : "Allows HTTPS connections to ${local.valid_service_gateway_cidrs[0]}.",
        stateless : false,
        protocol : "6",
        dst      = local.valid_service_gateway_cidrs[0],
        dst_type = "SERVICE_CIDR_BLOCK",
        src_port_min : null,
        src_port_max : null,
        dst_port_min : 443,
        dst_port_max : 443,
        icmp_code : null,
        icmp_type : null
      }
    }
  }}

  exacs_bkp_nsgs = { for k, v in module.lz_exacs_vcns.vcns : "${k}-bkp-nsg" => {
    vcn_id = v.id
    defined_tags = local.exacs_nsgs_defined_tags
    freeform_tags = local.exacs_nsgs_freeform_tags
    ingress_rules : {},
    egress_rules : {
      osn-services-egress-rule : {
        is_create : true,
        description : "Allows HTTPS connections to ${local.valid_service_gateway_cidrs[1]}.",
        stateless : false,
        protocol : "6",
        dst      = local.valid_service_gateway_cidrs[1],
        dst_type = "SERVICE_CIDR_BLOCK",
        src_port_min : null,
        src_port_max : null,
        dst_port_min : 443,
        dst_port_max : 443,
        icmp_code : null,
        icmp_type : null
      }
    }
  }}

  ### DON'T TOUCH THESE ###
  default_exacs_nsgs_defined_tags = null
  default_exacs_nsgs_freeform_tags = local.landing_zone_tags
  
  exacs_nsgs_defined_tags = length(local.all_exacs_nsgs_defined_tags) > 0 ? local.all_exacs_nsgs_defined_tags : local.default_exacs_nsgs_defined_tags
  exacs_nsgs_freeform_tags = length(local.all_exacs_nsgs_freeform_tags) > 0 ? merge(local.all_exacs_nsgs_freeform_tags, local.default_exacs_nsgs_freeform_tags) : local.default_exacs_nsgs_freeform_tags

}

module "lz_exacs_nsgs" {
  depends_on     = [module.lz_exacs_vcns]
  source         = "../modules/network/security"
  compartment_id = local.network_compartment_id #module.lz_compartments.compartments[local.network_compartment.key].id
  nsgs           = merge(local.exacs_clt_nsgs, local.exacs_bkp_nsgs)
}