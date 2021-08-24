# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration creates NSGs (Network Security Groups) for Exadata Cloud Service networking.

locals {
  exacs_bastions_nsgs = { for k, v in module.lz_exacs_vcns.vcns : "${k}-bastion-nsg" => {
    vcn_id : v.id,
    ingress_rules : merge({
      ssh-dmz-ingress-rule : {
        is_create : length(var.dmz_vcn_cidr) > 0,
        description : "SSH ingress rule for bastions in DMZ network",
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
      }}, 
      { for cidr in var.onprem_cidrs : "ssh-onprem-ingress-rule-${index(var.onprem_cidrs, cidr)}" => {
        is_create : (var.is_vcn_onprem_connected && length(var.dmz_vcn_cidr) == 0 && length(var.onprem_cidrs) > 0),
        description : "SSH ingress rule for on-premises CIDR ${cidr}.",
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
        is_create : !var.is_vcn_onprem_connected && length(var.dmz_vcn_cidr) == 0 && !var.no_internet_access && length(var.public_src_bastion_cidrs) > 0,
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
      }}
    ),
    egress_rules : {
      clt-egress_rule : {
        is_create : length(var.dmz_vcn_cidr) == 0,
        description : "SSH egress rule to ${k}-clt-nsg.",
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
      bkp-egress_rule : {
        is_create : length(var.dmz_vcn_cidr) == 0,
        description : "SSH egress rule to ${k}-bkp-nsg.",
        stateless : false,
        protocol : "6",
        dst      = "${k}-bkp-nsg",
        dst_type = "NSG_NAME",
        dst_port_min : 22,
        dst_port_max : 22,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      },
      osn-services-egress-rule : {
        is_create : length(var.dmz_vcn_cidr) == 0,
        description : "OSN egress rule to ${local.valid_service_gateway_cidrs[0]}.",
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
  } if var.deploy_app_layer_to_exacs_vcns == true }

  exacs_lbr_nsgs = { for k, v in module.lz_exacs_vcns.vcns : "${k}-lbr-nsg" => {
    vcn_id : v.id,
    ingress_rules : merge({
      ssh-ingress-rule : {
        is_create : length(var.dmz_vcn_cidr) == 0 && var.deploy_app_layer_to_exacs_vcns == true,
        description : "SSH ingress rule for ${k}-bastion-nsg.",
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
      dmz-services-ingress-rule : {
        is_create : length(var.dmz_vcn_cidr) > 0,
        description : "HTTPS ingress rule for DMZ services.",
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
        is_create : var.is_vcn_onprem_connected && length(var.dmz_vcn_cidr) == 0 && length(var.onprem_cidrs) > 0,
        description : "HTTPS ingress rule for on-premises CIDR ${cidr}.",
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
        is_create : !var.no_internet_access && length(var.dmz_vcn_cidr) == 0 && length(var.public_src_lbr_cidrs) > 0,
        description : "HTTPS ingress rule for ${cidr}.",
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
      clt-egress_rule : {
        is_create : true,
        description : "DB igress rule to ${k}-clt-nsg.",
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
        description : "OSN egress rule to ${local.valid_service_gateway_cidrs[0]}.",
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
  } if var.deploy_app_layer_to_exacs_vcns == true }

  exacs_app_nsgs = { for k, v in module.lz_exacs_vcns.vcns : "${k}-app-nsg" => {
    vcn_id : v.id,
    ingress_rules : {
      ssh-ingress-rule : {
        is_create : length(var.dmz_vcn_cidr) == 0,
        description : "SSH ingress rule for ${k}-bastion-nsg.",
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
      http-ingress-rule : {
        is_create : true,
        description : "HTTP ingress rule for ${k}-lbr-nsg.",
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
      }
    },
    egress_rules : {
      db-egress-rule : {
        is_create : true,
        description : "Egress rule to ${k}-clt-nsg for app to database access.",
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
      osn-services-egress-rule : {
        is_create : true,
        description : "Egress rule to ${local.valid_service_gateway_cidrs[0]}.",
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
  } if var.deploy_app_layer_to_exacs_vcns == true }

  exacs_clt_nsgs = { for k, v in module.lz_exacs_vcns.vcns : "${k}-clt-nsg" => {
    vcn_id : v.id,
    ingress_rules : merge({
      ssh-exacs-app-layer-ingress-rule : {
        is_create : var.deploy_app_layer_to_exacs_vcns == true && var.dmz_vcn_cidr == "",
        description : "SSH ingress rule for ${k}-bastion-nsg.",
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
      http-exacs-app-layer-ingress-rule : {
        is_create : var.deploy_app_layer_to_exacs_vcns == true,
        description : "HTTP ingress rule for ${k}-app-nsg.",
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
      ssh-dmz-vcn-ingress-rule : {
        is_create : length(var.dmz_vcn_cidr) > 0,
        description : "SSH ingress rule for DMZ VCN",
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
      db-dmz_vcn-ingress-rule : {
        is_create : length(var.dmz_vcn_cidr) > 0,
        description : "DB ingress rule for DMZ VCN.",
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
      ons-ingress-ingress-rule : {
        is_create : true,
        description : "Enables the Oracle Notification Services (ONS) to communicate about Fast Application Notification (FAN) events within the Exadata client subnet.",
        stateless : false,
        protocol : "6",
        src : module.lz_exacs_vcns.subnets[replace(k,"-vcn","-${local.client_subnet_prefix}-snt")].cidr_block,
        src_type : "CIDR_BLOCK",
        dst_port_min : 6200,
        dst_port_max : 6200,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      },
	    db-client-subnet-ingress-rule : {
        is_create : true,
        description : "Enable client connections initiated from Exadata client subnet to the database and Oracle Data Guard",
        stateless : false,
        protocol : "6",
        src : module.lz_exacs_vcns.subnets[replace(k,"-vcn","-${local.client_subnet_prefix}-snt")].cidr_block,
        src_type : "CIDR_BLOCK",
        dst_port_min : 1521,
        dst_port_max : 1522,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      },
	    ssh-client-subnet-ingress-rule : {
        is_create : true,
        description : "SSH ingress rule for connections initiated from Exadata client subnet.",
        stateless : false,
        protocol : "6",
        src : module.lz_exacs_vcns.subnets[replace(k,"-vcn","-${local.client_subnet_prefix}-snt")].cidr_block,
        src_type : "CIDR_BLOCK",
        dst_port_min : 22,
        dst_port_max : 22,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      }},
      { for c in var.onprem_cidrs : "ssh-on-prem-ingress-rule-${index(var.onprem_cidrs,c)}" => {
        is_create : var.is_vcn_onprem_connected && length(var.dmz_vcn_cidr) == 0 && length(var.onprem_cidrs) > 0,
        description : "SSH ingress rule for on-premises CIDR ${c}.",
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
      { for c in var.onprem_cidrs : "db-on-prem-ingress-rule-${index(var.onprem_cidrs,c)}" => {
        is_create : true #var.is_vcn_onprem_connected && length(var.dmz_vcn_cidr) == 0 && length(var.onprem_cidrs) > 0,
        description : "SSH ingress rule for on-premises CIDR ${c}.",
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
      { for k,v in module.lz_vcn_spokes.vcns : "db-spoke-${k}-ingress-rule" => {
        is_create : length(var.dmz_vcn_cidr) == 0 && var.hub_spoke_architecture == true,
        description : "SSH ingress rule for VCN ${k} CIDR ${v.cidr_block}.",
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

    ),
    egress_rules : {
      ssh-client-subnet-egress-rule : {
        is_create : true,
        description : "SSH egress rule to Exadata client subnet.",
        stateless : false,
        protocol : "6",
        dst      = module.lz_exacs_vcns.subnets[replace(k,"-vcn","-${local.client_subnet_prefix}-snt")].cidr_block,
        dst_type = "CIDR_BLOCK",
        src_port_min : null,
        src_port_max : null,
        dst_port_min : 22,
        dst_port_max : 22,
        icmp_code : null,
        icmp_type : null
      }, 
      osn-services-egress-rule : {
        is_create : true,
        description : "Egress rule to ${local.valid_service_gateway_cidrs[0]}.",
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
        description : "Egress rule to ${local.valid_service_gateway_cidrs[1]}.",
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