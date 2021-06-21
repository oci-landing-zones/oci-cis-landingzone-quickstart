# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration creates Landing Zone NSGs (Network Security Groups)

locals {
  bastions_nsgs = { for k, v in module.lz_vcn_spokes.vcns : "${k}-bastion-nsg" => {
    vcn_id : v.id,
    ingress_rules : {
      ssh-public-ingress-rule : {
        is_create : !var.is_vcn_onprem_connected && var.dmz_vcn_cidr == null && !var.no_internet_access,
        description : "SSH ingress rule for ${var.public_src_bastion_cidr}.",
        protocol : "6",
        stateless : false,
        src : var.public_src_bastion_cidr,
        src_type : "CIDR_BLOCK",
        dst_port_min : 22,
        dst_port_max : 22,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      },
      ssh-onprem-ingress-rule : {
        is_create : (var.is_vcn_onprem_connected && var.dmz_vcn_cidr == null),
        description : "SSH ingress rule for on-premises CIDR ${var.onprem_cidr}.",
        stateless : false,
        protocol : "6",
        src : var.onprem_cidr,
        src_type : "CIDR_BLOCK",
        dst_port_min : 22,
        dst_port_max : 22,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      },
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
    },
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
  } if length(regexall(".*spoke*", k)) > 0 }

  lbr_nsgs = { for k, v in module.lz_vcn_spokes.vcns : "${k}-lbr-nsg" => {
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
      http-public-ingress-rule : {
        is_create : !var.no_internet_access && var.dmz_vcn_cidr == null,
        description : "HTTPS ingress rule for ${var.public_src_lbr_cidr}.",
        stateless : false,
        protocol : "6",
        src : var.public_src_lbr_cidr,
        src_type : "CIDR_BLOCK",
        dst_port_min : 443,
        dst_port_max : 443,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      },
      http-onprem-ingress-rule : {
        is_create : var.is_vcn_onprem_connected && var.dmz_vcn_cidr == null,
        description : "HTTPS ingress rule for on-premises CIDR ${var.onprem_cidr}.",
        stateless : false,
        protocol : "6",
        src : var.onprem_cidr,
        src_type : "CIDR_BLOCK",
        dst_port_min : 443,
        dst_port_max : 443,
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
    },
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
  } if length(regexall(".*spoke*", k)) > 0 }

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
  } if length(regexall(".*spoke*", k)) > 0 }

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
  } if length(regexall(".*spoke*", k)) > 0 }
}

module "lz_nsgs_spokes" {
  depends_on     = [module.lz_vcn_spokes]
  source         = "../modules/network/security"
  compartment_id = module.lz_compartments.compartments[local.network_compartment_name].id
  nsgs           = merge(local.bastions_nsgs, local.lbr_nsgs, local.app_nsgs, local.db_nsgs)
}

locals {
  dmz_bastions_nsg_name = var.dmz_vcn_cidr != null ? "${local.dmz_vcn_name.name}-bastion-nsg" : null
  dmz_services_nsg_name = var.dmz_vcn_cidr != null ? "${local.dmz_vcn_name.name}-services-nsg" : null
  ssh_dmz_to_spokes_nsg_egress_rules = var.dmz_vcn_cidr != null ? { for k, v in module.lz_vcn_dmz.vcns : "${k}-dmz-ssh-egress-rule" => {
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
  } if length(regexall(".*spoke*", k)) > 0 } : {}

  http_dmz_to_spokes_nsg_egress_rules = var.dmz_vcn_cidr != null ? { for k, v in module.lz_vcn_dmz.vcns : "${k}-dmz-http-egress-rule" => {
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
  } if length(regexall(".*spoke*", k)) > 0 } : {}
}

module "lz_nsgs_dmz" {
  depends_on     = [module.lz_vcn_dmz]
  count          = var.dmz_vcn_cidr != null ? 1 : 0
  source         = "../modules/network/security"
  compartment_id = module.lz_compartments.compartments[local.network_compartment_name].id
  nsgs = {
    (local.dmz_bastions_nsg_name) : {
      vcn_id = module.lz_vcn_dmz.vcns[local.dmz_vcn_name.name].id
      ingress_rules : {
        ssh-public-ingress-rule : {
          is_create : (!var.no_internet_access && !var.is_vcn_onprem_connected),
          description : "SSH ingress rule for ${var.public_src_bastion_cidr}.",
          protocol : "6",
          stateless : false,
          src : var.public_src_bastion_cidr,
          src_type : "CIDR_BLOCK",
          dst_port_min : 22,
          dst_port_max : 22,
          src_port_min : null,
          src_port_max : null,
          icmp_type : null,
          icmp_code : null
        },
        ssh-onprem-ingress-rule : {
          is_create : var.is_vcn_onprem_connected,
          description : "SSH ingress rule for on-premises CIDR ${var.onprem_cidr}.",
          protocol : "6",
          stateless : false,
          src : var.onprem_cidr,
          src_type : "CIDR_BLOCK",
          dst_port_min : 22,
          dst_port_max : 22,
          src_port_min : null,
          src_port_max : null,
          icmp_type : null,
          icmp_code : null
        }
      },
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
      ingress_rules : {
        http-public-ingress-rule : {
          is_create : !var.no_internet_access,
          description : "HTTPS ingress rule for ${var.public_src_lbr_cidr}.",
          protocol : "6",
          stateless : false,
          src : var.public_src_lbr_cidr,
          src_type : "CIDR_BLOCK",
          dst_port_min : 443,
          dst_port_max : 443,
          src_port_min : null,
          src_port_max : null,
          icmp_type : null,
          icmp_code : null
        },
        http-onprem-ingress-rule : {
          is_create : tobool(var.is_vcn_onprem_connected),
          description : "HTTPS ingress rule for on-premises CIDR ${var.onprem_cidr}.",
          protocol : "6",
          stateless : false,
          src : var.onprem_cidr,
          src_type : "CIDR_BLOCK",
          dst_port_min : 443,
          dst_port_max : 443,
          src_port_min : null,
          src_port_max : null,
          icmp_type : null,
          icmp_code : null
        },
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
      },
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
    }
  }
}