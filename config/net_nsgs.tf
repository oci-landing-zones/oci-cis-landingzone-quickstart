# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration creates four NSGs (Network Security Groups)
### 1) NSG for bastion servers:
###   Ingress rule: port 22 from sources other than 0.0.0.0/0
###   Egress rules: a) port 22 on NSG #3 (App NSG), b) port 22 on NSG #4 (DB NSG)
### 2) NSG for load balancers:
###   Ingress rule: port 443 from any sources
###   Egress rule: port 80 on NSG #3 (App NSG)
### 3) NSG for application hosts
###   Ingress rules: a) port 22 from NSG #1 (Bastion NSG), b) port 80 from NSG #2 (LBR NSG)
###   Egress rules: a) port 443 to all regional services in OSN, b) ports 1521,1522 on NSG #4 (DB NSG)
### 4) NSG for database hosts:
###   Ingress rules: port 22 from the NSG #1 (Bastion NSG), b) ports 1521,1522 from NSG #3 (App NSG)
###   Egress rule: port 443 to all regional services in OSN.

locals {
  bastions_nsgs = { for k, v in module.lz_spoke_vcns.vcns : "${k}-bastion-nsg" => {
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
  }}

  lbr_nsgs = { for k, v in module.lz_spoke_vcns.vcns : "${k}-lbr-nsg" => {
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
  }}

  app_nsgs = { for k, v in module.lz_spoke_vcns.vcns : "${k}-app-nsg" => {
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
  }} 

  db_nsgs = { for k, v in module.lz_spoke_vcns.vcns : "${k}-db-nsg" => {
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
  }}
}

module "lz_nsgs" {
  depends_on = [module.lz_spoke_vcns]
  source = "../modules/network/security"
  compartment_id = module.cis_compartments.compartments[local.network_compartment_name].id
  nsgs = merge(local.bastion_nsgs, local.lbr_nsgs, local.app_nsgs, local.db_nsgs)  
}

module "lz_nsgs_hub" {
  depends_on = [module.cis_dmz_vcn]
  count          = var.hub_spoke_architecture == true ? 1 : 0
  source         = "../modules/network/security"
  compartment_id = module.cis_compartments.compartments[local.network_compartment_name].id
  nsgs = {
    (local.dmz_bastion_nsg_name) : {
      vcn_id = module.cis_dmz_vcn[0].vcn.id
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
      egress_rules : merge({ for k, v in module.lz_spoke_vcns.vcns : "ssh-hub-to-${k}-egress-rule" => { ## Egress rules to spoke VCNs
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
        }},
        dmz-services-egress-rule : { ## Egress rule to DMZ services within the Hub VCN
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
        }
        osn-services-egress-rule : { ## Egress rule to OSN services
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
        })
      }
    },
    (local.dmz_services_nsg_name) : {
      vcn_id = module.cis_dmz_vcn[0].vcn.id
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
      egress_rules : merge({ for k, v in module.lz_spoke_vcns.vcns : "http-hub-to-${k}-egress-rule" => { ## Egress rules to spoke VCNs
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
        }},
        osn-services-egress-rule : { ## Egress rule to OSN services
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
        })
    }
}