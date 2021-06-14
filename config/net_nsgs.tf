# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration creates Landing Zone NSGs (Network Security Groups)

locals {
  bastions_nsgs = { for k, v in module.lz_vcns.vcns : "${k}-bastion-nsg" => {
    vcn_id : v.id,
    ingress_rules : {
      ssh-public-ingress-rule : {
        is_create : (!var.is_vcn_onprem_connected && !var.hub_spoke_architecture),
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
        is_create : (var.is_vcn_onprem_connected && !var.hub_spoke_architecture),
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
      ssh-hub-ingress-rule : {
        is_create : var.hub_spoke_architecture,
        description : "SSH ingress rule for ${local.dmz_bastion_subnet_name}.",
        stateless : false,
        protocol : "6",
        src : var.dmz_bastion_subnet_cidr,
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
        is_create : !var.hub_spoke_architecture,
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
        is_create : !var.hub_spoke_architecture,
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
      osn-services-egress-rule : {
        is_create : !var.hub_spoke_architecture,
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

  lbr_nsgs = { for k, v in module.lz_vcns.vcns : "${k}-lbr-nsg" => {
    vcn_id : v.id,
    ingress_rules : {
      http-public-ingress-rule : {
        is_create : !var.no_internet_access && !var.hub_spoke_architecture,
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
        is_create : var.is_vcn_onprem_connected,
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
      hub-services-ingress-rule : {
        is_create : var.hub_spoke_architecture,
        description : "HTTPS ingress rule for ${local.dmz_services_subnet_name}.",
        stateless : false,
        protocol : "6",
        src : var.dmz_services_subnet_cidr,
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

  app_nsgs = { for k, v in module.lz_vcns.vcns : "${k}-app-nsg" => {
    vcn_id : v.id,
    ingress_rules : {
      ssh-ingress-rule : {
        is_create : !var.hub_spoke_architecture,
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

  db_nsgs = { for k, v in module.lz_vcns.vcns : "${k}-db-nsg" => {
    vcn_id = v.id
    ingress_rules : {
      ssh-ingress-rule : {
        is_create : !var.hub_spoke_architecture,
        description : "SSH ingress rule for ${k}-bastion-nsg.",
        stateless : false,
        protocol : "6",
        src : "${k}-bastion-nsg",
        src_type : "NSG_NAME",
        src_port_min : null,
        src_port_max : null,
        dst_port_min : 22,
        dst_port_max : 22,
        icmp_code : null,
        icmp_type : null
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

module "lz_nsgs" {
  depends_on = [module.lz_vcns]
  source = "../modules/network/security"
  compartment_id = module.cis_compartments.compartments[local.network_compartment_name].id
  nsgs = merge(local.bastion_nsgs, local.lbr_nsgs, local.app_nsgs, local.db_nsgs)  
}

locals {
  dmz_bastion_to_spokes_nsg_egress_rules = { for k, v in module.lz_vcns.vcns : "${service-label}-ssh-dmz-to-${k}-egress-rule" => { ## SSH egress rules to spoke VCNs
    is_create : true,
    description : "SSH egress rule to ${k}.",
    protocol : "6",
    stateless : false,
    dst      = v.cidr_block,
    dst_type = "CIDR_BLOCK",
    dst_port_min : 22,
    dst_port_max : 22,
    src_port_min : null,
    src_port_max : null,
    icmp_type : null,
    icmp_code : null
    } if length(regexall(".*spoke*", k)) > 0 }

  dmz_http_to_spokes_nsg_egress_rules = { for k, v in module.lz_vcns.vcns : "${service-label}-http-dmz-to-${k}-egress-rule" => { ## Http egress rules to spoke VCNs
        is_create : true,
        description : "HTTP egress rule to ${k}.",
        protocol : "6",
        stateless : false,
        dst      = v.cidr_block,
        dst_type = "CIDR_BLOCK",
        dst_port_min : 80,
        dst_port_max : 80,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
        } if length(regexall(".*spoke*", k)) > 0 }  
}

module "lz_nsgs_dmz" {
  depends_on = [module.lz_vcns]
  count          = var.hub_spoke_architecture == true ? 1 : 0
  source         = "../modules/network/security"
  compartment_id = module.cis_compartments.compartments[local.network_compartment_name].id
  nsgs = {
    (local.dmz_bastion_nsg_name) : {
      vcn_id = module.lz_vcns.vcns[local.dmz_vcn_name].id
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
      egress_rules : merge(local.dmz_bastion_to_spokes_nsg_egress_rules,
        {dmz-services-egress-rule : {
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
        }},
        {osn-services-egress-rule : {
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
        }})
    },
    (local.dmz_services_nsg_name) : {
      vcn_id = module.lz_vcns.vcns[local.dmz_vcn_name].id
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
          description : " SSH ingress rule from ${local.dmz_bastion_nsg_name}.",
          protocol : "6",
          stateless : false,
          src : local.dmz_bastion_nsg_name,
          src_type : "NSG_NAME",
          dst_port_min : 22,
          dst_port_max : 22,
          src_port_min : null,
          src_port_max : null,
          icmp_type : null,
          icmp_code : null
        }
      },
      egress_rules : merge(local.dmz_http_to_spokes_nsg_egress_rules,
        {osn-services-egress-rule : {
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
        }})
    }
  }  
}