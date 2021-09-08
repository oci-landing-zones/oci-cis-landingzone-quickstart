# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration creates NSGs (Network Security Groups) for Exadata Cloud Service networking.

locals {
  exacs_bastions_nsgs = { for k, v in module.lz_exacs_vcns.vcns : "${k}-bastion-nsg" => {
    vcn_id : v.id,
    ingress_rules : merge(/* {
      ssh-dmz-ingress-rule : {
        is_create : true, #length(var.dmz_vcn_cidr) > 0,
        description : "Allows SSH connections from hosts in DMZ VCN.",
        stateless : false,
        protocol : "6",
        src : length(var.dmz_vcn_cidr) > 0 ? module.lz_vcn_dmz.vcns[local.dmz_vcn_name.name].cidr_block : null,
        src_type : "CIDR_BLOCK",
        dst_port_min : 22,
        dst_port_max : 22,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      }}, */ 
      { for cidr in var.onprem_src_ssh_cidrs : "ssh-onprem-ingress-rule-${index(var.onprem_src_ssh_cidrs, cidr)}" => {
        is_create : length(var.dmz_vcn_cidr) == 0,
        description : "Allows SSH connections from on-premises ${cidr} CIDR range.",
        stateless : false,
        protocol : "6",
        src : cidr,
        src_type : "CIDR_BLOCK",
        dst_port_min : 22,
        dst_port_max : 22,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      }},
      { for cidr in var.public_src_bastion_cidrs : "ssh-public-ingress-rule-${index(var.public_src_bastion_cidrs, cidr)}" => {
        is_create : true, #length(var.dmz_vcn_cidr) == 0 && local.is_exacs_internet_connected,
        description : "Allows SSH connections from ${cidr} CIDR range.",
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
      }}
    ),
    egress_rules : {
      clt-egress_rule : {
        is_create : true, #length(var.dmz_vcn_cidr) == 0,
        description : "Allows SSH connections to hosts in ${k}-clt-nsg NSG.",
        stateless : false,
        protocol : "6",
        dst      = "${k}-clt-nsg",
        dst_type = "NSG_NAME",
        dst_port_min : 22,
        dst_port_max : 22,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      },
      app-egress_rule : {
        is_create : true, #length(var.dmz_vcn_cidr) == 0,
        description : "Allows SSH connections to hosts in ${k}-app-nsg NSG.",
        stateless : false,
        protocol : "6",
        dst      = "${k}-app-nsg",
        dst_type = "NSG_NAME",
        dst_port_min : 22,
        dst_port_max : 22,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      },
      osn-services-egress-rule : {
        is_create : true, #length(var.dmz_vcn_cidr) == 0,
        description : "Allows access to ${local.valid_service_gateway_cidrs[0]}.",
        stateless : false,
        protocol : "6",
        dst      = local.valid_service_gateway_cidrs[0],
        dst_type = "SERVICE_CIDR_BLOCK",
        dst_port_min : 443,
        dst_port_max : 443,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      }
    }
  } if local.is_exacs_internet_connected == true && length(var.dmz_vcn_cidr) == 0 }

  exacs_lbr_nsgs = { for k, v in module.lz_exacs_vcns.vcns : "${k}-lbr-nsg" => {
    vcn_id : v.id,
    ingress_rules : merge({
      /* ssh-ingress-rule : {
        is_create : length(var.dmz_vcn_cidr) == 0, #&& var.deploy_app_tier_to_exacs_vcns == true,
        description : "Allows SSH connections from hosts in ${k}-bastion-nsg NSG.",
        stateless : false,
        protocol : "6",
        src : "${k}-bastion-nsg",
        src_type : "NSG_NAME",
        dst_port_min : 22,
        dst_port_max : 22,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      }, */
      dmz-http-ingress-rule : {
        is_create : length(var.dmz_vcn_cidr) > 0,
        description : "Allows HTTPS connections from hosts in DMZ VCN.",
        stateless : false,
        protocol : "6",
        src : length(var.dmz_vcn_cidr) > 0 ? module.lz_vcn_dmz.vcns[local.dmz_vcn_name.name].cidr_block : null,
        src_type : "CIDR_BLOCK",
        dst_port_min : 443,
        dst_port_max : 443,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      }},
      { for cidr in var.onprem_cidrs : "http-onprem-ingress-rule-${index(var.onprem_cidrs, cidr)}" => {
        is_create : true, #length(var.dmz_vcn_cidr) == 0 && length(var.onprem_cidrs) > 0,
        description : "Allows HTTPS connections from on-premises ${cidr} CIDR range.",
        stateless : false,
        protocol : "6",
        src : cidr,
        src_type : "CIDR_BLOCK",
        dst_port_min : 443,
        dst_port_max : 443,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      }},
      { for cidr in var.public_src_lbr_cidrs : "http-public-ingress-rule-${index(var.public_src_lbr_cidrs, cidr)}" => {
        is_create : local.is_exacs_internet_connected == true,
        description : "Allows HTTPS connections from ${cidr} CIDR range.",
        stateless : false,
        protocol : "6",
        src : cidr,
        src_type : "CIDR_BLOCK",
        dst_port_min : 443,
        dst_port_max : 443,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      }}
    ),
    egress_rules : {
      sqlnet-clt-nsg-egress_rule : {
        is_create : true,
        description : "Allows SQLNet connections to ${k}-clt-nsg NSG.",
        stateless : false,
        protocol : "6",
        dst      = "${k}-clt-nsg",
        dst_type = "NSG_NAME",
        dst_port_min : 1521,
        dst_port_max : 1522,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      },
      osn-services-egress-rule : {
        is_create : true,
        description : "Allows access to ${local.valid_service_gateway_cidrs[0]}.",
        stateless : false,
        protocol : "6",
        dst      = local.valid_service_gateway_cidrs[0],
        dst_type = "SERVICE_CIDR_BLOCK",
        dst_port_min : 443,
        dst_port_max : 443,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      }
    }
  } if var.deploy_app_tier_to_exacs_vcns == true }

  exacs_app_nsgs = { for k, v in module.lz_exacs_vcns.vcns : "${k}-app-nsg" => {
    vcn_id : v.id,
    ingress_rules : merge({
      ssh-bastion-nsg-ingress-rule : {
        is_create : local.is_exacs_internet_connected == true && length(var.dmz_vcn_cidr) == 0,
        description : "Allows SSH connections from hosts in ${k}-bastion-nsg NSG.",
        stateless : false,
        protocol : "6",
        src : "${k}-bastion-nsg",
        src_type : "NSG_NAME",
        dst_port_min : 22,
        dst_port_max : 22,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      },
      ssh-dmz-vcn-ingress-rule : {
        is_create : length(var.dmz_vcn_cidr) > 0,
        description : "Allows SSH connections from hosts in DMZ VCN.",
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
      lbr-nsg-ingress-rule : {
        is_create : true,
        description : "Allows HTTP connections from hosts in ${k}-lbr-nsg NSG.",
        stateless : false,
        protocol : "6",
        src : "${k}-lbr-nsg",
        src_type : "NSG_NAME",
        dst_port_min : 80,
        dst_port_max : 80,
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
      }
    }),
    egress_rules : {
      sqlnet-clt-nsg-egress-rule : {
        is_create : true,
        description : "Allows SQLNet connections to hosts in ${k}-clt-nsg NSG.",
        stateless : false,
        protocol : "6",
        dst      = "${k}-clt-nsg",
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
  } if var.deploy_app_tier_to_exacs_vcns == true }

  exacs_clt_nsgs = { for k, v in module.lz_exacs_vcns.vcns : "${k}-clt-nsg" => {
    vcn_id : v.id,
    ingress_rules : merge({
      ssh-bastion-nsg-ingress-rule : {
        is_create : var.deploy_app_tier_to_exacs_vcns == true && length(var.dmz_vcn_cidr) == 0,
        description : "Allows for SSH connections from hosts in ${k}-bastion-nsg NSG.",
        stateless : false,
        protocol : "6",
        src : "${k}-bastion-nsg",
        src_type : "NSG_NAME",
        dst_port_min : 22,
        dst_port_max : 22,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      },
      sqlnet-app-nsg-ingress-rule : {
        is_create : var.deploy_app_tier_to_exacs_vcns == true,
        description : "Allows for SQLNet connections from hosts in ${k}-app-nsg NSG.",
        stateless : false,
        protocol : "6",
        src : "${k}-app-nsg",
        src_type : "NSG_NAME",
        dst_port_min : 1521,
        dst_port_max : 1522,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      },
      ons-app-nsg-ingress-rule : {
        is_create : var.deploy_app_tier_to_exacs_vcns == true,
        description : "Allows Oracle Notification Services (ONS) communication from hosts in ${k}-app-nsg NSG for Fast Application Notifications (FAN).",
        stateless : false,
        protocol : "6",
        src : "${k}-app-nsg",
        src_type : "NSG_NAME",
        dst_port_min : 6200,
        dst_port_max : 6200,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      },
      ssh-dmz-vcn-ingress-rule : {
        is_create : length(var.dmz_vcn_cidr) > 0,
        description : "Allows for SSH connections from hosts in DMZ VCN.",
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
        description : "Allows for SQLNet connections from hosts in DMZ VCN.",
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
        src : "${k}-clt-nsg", #module.lz_exacs_vcns.subnets[replace(k,"-vcn","-${local.client_subnet_prefix}-snt")].cidr_block,
        src_type : "NSG_NAME",
        dst_port_min : 22,
        dst_port_max : 22,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      }},
      { for c in var.onprem_src_ssh_cidrs : "ssh-on-prem-ingress-rule-${index(var.onprem_src_ssh_cidrs,c)}" => {
        is_create : length(var.dmz_vcn_cidr) == 0,# && length(var.onprem_cidrs) > 0,
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
        is_create : true #length(var.dmz_vcn_cidr) == 0, var.is_vcn_onprem_connected && length(var.dmz_vcn_cidr) == 0 && length(var.onprem_cidrs) > 0,
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
      { for k,v in module.lz_vcn_spokes.vcns : "sqlnet-spoke-${k}-ingress-rule" => {
        is_create : var.hub_spoke_architecture == true, #&& length(var.dmz_vcn_cidr) == 0,
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
        is_create : var.hub_spoke_architecture == true, #&& length(var.dmz_vcn_cidr) == 0,
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
        dst      = "${k}-clt-nsg" #module.lz_exacs_vcns.subnets[replace(k,"-vcn","-${local.client_subnet_prefix}-snt")].cidr_block,
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
}

module "lz_exacs_nsgs" {
  depends_on     = [module.lz_exacs_vcns]
  source         = "../modules/network/security"
  compartment_id = module.lz_compartments.compartments[local.network_compartment_name].id
  nsgs           = merge(local.exacs_bastions_nsgs, local.exacs_lbr_nsgs, local.exacs_app_nsgs, local.exacs_clt_nsgs, local.exacs_bkp_nsgs)
}