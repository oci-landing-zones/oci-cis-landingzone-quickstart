# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration creates Landing Zone NSGs (Network Security Groups)

locals {
  bastions_nsgs = { for k, v in module.lz_vcn_spokes.vcns : "${k}-bastion-nsg" => {
    vcn_id : v.id,
    ingress_rules : merge({
      ssh-dmz-ingress-rule : {
        is_create : var.dmz_vcn_cidr != null,
        description : "SSH ingress rule for bastions in DMZ network",
        stateless : false,
        protocol : "6",
        src : var.dmz_vcn_cidr != null ? module.lz_vcn_dmz.vcns[local.dmz_vcn_name.name].cidr_block : null,
        src_type : "CIDR_BLOCK",
        dst_port_min : 22,
        dst_port_max : 22,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      }
      }, { for cidr in var.onprem_cidrs : "ssh-onprem-ingress-rule-${index(var.onprem_cidrs, cidr)}" => {
        is_create : (var.is_vcn_onprem_connected && var.dmz_vcn_cidr == null && length(var.onprem_cidrs) > 0),
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
      }
      },
      { for cidr in var.public_src_bastion_cidrs : "ssh-public-ingress-rule-${index(var.public_src_bastion_cidrs, cidr)}" => {
        is_create : !var.is_vcn_onprem_connected && var.dmz_vcn_cidr == null && !var.no_internet_access && length(var.public_src_bastion_cidrs) > 0,
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
        }

    }),
    egress_rules : {
      app-egress_rule : {
        is_create : var.dmz_vcn_cidr == null,
        description : "SSH egress rule to ${k}-app-nsg.",
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
      db-egress_rule : {
        is_create : var.dmz_vcn_cidr == null,
        description : "SSH egress rule to ${k}-db-nsg.",
        stateless : false,
        protocol : "6",
        dst      = "${k}-db-nsg",
        dst_type = "NSG_NAME",
        dst_port_min : 22,
        dst_port_max : 22,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      },
      lbr-egress_rule : {
        is_create : var.dmz_vcn_cidr == null,
        description : "SSH egress rule to ${k}-db-nsg.",
        stateless : false,
        protocol : "6",
        dst      = "${k}-lbr-nsg",
        dst_type = "NSG_NAME",
        dst_port_min : 22,
        dst_port_max : 22,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      },
      osn-services-egress-rule : {
        is_create : var.dmz_vcn_cidr == null,
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
  } }

  lbr_nsgs = { for k, v in module.lz_vcn_spokes.vcns : "${k}-lbr-nsg" => {
    vcn_id : v.id,
    ingress_rules : merge({
      ssh-ingress-rule : {
        is_create : var.dmz_vcn_cidr == null,
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
        is_create : var.dmz_vcn_cidr != null,
        description : "HTTPS ingress rule for DMZ services.",
        stateless : false,
        protocol : "6",
        src : var.dmz_vcn_cidr != null ? module.lz_vcn_dmz.vcns[local.dmz_vcn_name.name].cidr_block : null,
        src_type : "CIDR_BLOCK",
        dst_port_min : 443,
        dst_port_max : 443,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      }
      }, { for cidr in var.onprem_cidrs : "http-onprem-ingress-rule-${index(var.onprem_cidrs, cidr)}" => {
        is_create : var.is_vcn_onprem_connected && var.dmz_vcn_cidr == null && length(var.onprem_cidrs) > 0,
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
      }
      },
      { for cidr in var.public_src_lbr_cidrs : "http-public-ingress-rule-${index(var.public_src_lbr_cidrs, cidr)}" => {
        is_create : !var.no_internet_access && var.dmz_vcn_cidr == null && length(var.public_src_lbr_cidrs) > 0,
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
        }

    }),
    egress_rules : {
      app-egress_rule : {
        is_create : true,
        description : "HTTP egress rule to ${k}-app-nsg.",
        stateless : false,
        protocol : "6",
        dst      = "${k}-app-nsg",
        dst_type = "NSG_NAME",
        dst_port_min : 80,
        dst_port_max : 80,
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
  } }

  app_nsgs = { for k, v in module.lz_vcn_spokes.vcns : "${k}-app-nsg" => {
    vcn_id : v.id,
    ingress_rules : {
      ssh-ingress-rule : {
        is_create : var.dmz_vcn_cidr == null,
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
        description : "Egress rule to ${k}-db-nsg for app to database access.",
        stateless : false,
        protocol : "6",
        dst      = "${k}-db-nsg",
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
  } }

  db_nsgs = { for k, v in module.lz_vcn_spokes.vcns : "${k}-db-nsg" => {
    vcn_id = v.id
    ingress_rules : {
      ssh-ingress-rule : {
        is_create : var.dmz_vcn_cidr == null,
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
      app-ingress-rule : {
        is_create : true,
        description : "Ingress rule for ${k}-app-nsg.",
        stateless : false,
        protocol : "6",
        src : "${k}-app-nsg",
        src_type : "NSG_NAME",
        src_port_min : null,
        src_port_max : null,
        dst_port_min : 1521,
        dst_port_max : 1522,
        icmp_code : null,
        icmp_type : null
      }
    },
    egress_rules : {
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
  } }

  public_dst_nsgs = length(var.public_dst_cidrs) > 0 && !var.no_internet_access && var.dmz_vcn_cidr == null ? { for k, v in module.lz_vcn_spokes.vcns : "${k}-public-dst-nsg" => {
    vcn_id = v.id
    ingress_rules : {},
    egress_rules : merge({ for cidr in var.public_dst_cidrs : "https-public-dst-egress-rule-${index(var.public_dst_cidrs, cidr)}" => {
      is_create : var.public_dst_cidrs != null && !var.no_internet_access && var.dmz_vcn_cidr == null,
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
    } }, {})

    }
  } : {}
}

module "lz_nsgs_spokes" {
  depends_on     = [module.lz_vcn_spokes]
  source         = "../modules/network/security"
  compartment_id = module.lz_compartments.compartments[local.network_compartment_name].id
  nsgs           = merge(local.bastions_nsgs, local.lbr_nsgs, local.app_nsgs, local.db_nsgs, local.public_dst_nsgs)
}