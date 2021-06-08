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

module "cis_nsgs" {
  source                 = "../modules/network/security"
  default_compartment_id = module.cis_compartments.compartments[local.network_compartment_name].id
  vcn_id                 = module.cis_vcn.vcn.id
  nsgs = {
    (local.bastion_nsg_name) : {
      ingress_rules : {
        ingress-rule-src-public-bastion-cidr : {
          is_create : (!tobool(var.is_vcn_onprem_connected) && !var.hub_spoke_architecture),
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
        ingress-rule-src-onprem-cidr : {
          is_create : (tobool(var.is_vcn_onprem_connected) && !var.hub_spoke_architecture),
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
        ingress-rule-src-hub-bastion-cidr : {
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
        egress-rule-dst-app_nsg : {
          is_create : !var.hub_spoke_architecture,
          description : "SSH egress rule for ${local.app_nsg_name}.",
          stateless : false,
          protocol : "6",
          dst      = local.app_nsg_name,
          dst_type = "NSG_NAME",
          dst_port_min : 22,
          dst_port_max : 22,
          src_port_min : null,
          src_port_max : null,
          icmp_type : null,
          icmp_code : null
        },
        egress-rule-dst-db-nsg : {
          is_create : !var.hub_spoke_architecture,
          description : "SSH egress rule for ${local.db_nsg_name}.",
          stateless : false,
          protocol : "6",
          dst      = local.db_nsg_name,
          dst_type = "NSG_NAME",
          dst_port_min : 22,
          dst_port_max : 22,
          src_port_min : null,
          src_port_max : null,
          icmp_type : null,
          icmp_code : null
        },
        egress-rule-dst-osn-services : {
          is_create : !var.hub_spoke_architecture,
          description : "OSN egress rule for ${local.valid_service_gateway_cidrs[0]}.",
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
    },
    (local.lbr_nsg_name) : {
      ingress_rules : {
        ingress-rule-src-public-lbr-cidr : {
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
        ingress-rule-src-onprem-cidr : {
          is_create : tobool(var.is_vcn_onprem_connected),
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
        ingress-rule-src-hub-services-cidr : {
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
        egress-rule-dst-app-nsg : {
          is_create : true,
          description : "HTTP egress rule for ${local.app_nsg_name}.",
          stateless : false,
          protocol : "6",
          dst      = local.app_nsg_name,
          dst_type = "NSG_NAME",
          dst_port_min : 80,
          dst_port_max : 80,
          src_port_min : null,
          src_port_max : null,
          icmp_type : null,
          icmp_code : null
        },
        egress-rule-dst-osn-services : {
          is_create : true,
          description : "OSN egress rule for ${local.valid_service_gateway_cidrs[0]}.",
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
    },
    (local.app_nsg_name) : {
      ingress_rules : {
        ingress-rule-src-bastion_nsg : {
          is_create : !var.hub_spoke_architecture,
          description : "SSH ingress rule for ${local.bastion_nsg_name}.",
          stateless : false,
          protocol : "6",
          src : local.bastion_nsg_name,
          src_type : "NSG_NAME",
          dst_port_min : 22,
          dst_port_max : 22,
          src_port_min : null,
          src_port_max : null,
          icmp_type : null,
          icmp_code : null
        },
        ingress-rule-src-lbr-nsg : {
          is_create : true,
          description : "HTTP ingress rule for ${local.lbr_nsg_name}.",
          stateless : false,
          protocol : "6",
          src : local.lbr_nsg_name,
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
        egress-rule-dst-db-nsg : {
          is_create : true,
          description : "Database egress rule for ${local.db_nsg_name}.",
          stateless : false,
          protocol : "6",
          dst      = local.db_nsg_name,
          dst_type = "NSG_NAME",
          src_port_min : null,
          src_port_max : null,
          dst_port_min : 1521,
          dst_port_max : 1522,
          icmp_code : null,
          icmp_type : null
        },
        egress-rule-dst-osn-services : {
          is_create : true,
          description : "OSN egress rule for ${local.valid_service_gateway_cidrs[0]}.",
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
    },
    (local.db_nsg_name) : {
      ingress_rules : {
        ingress-rule-src-bastion-nsg : {
          is_create : !var.hub_spoke_architecture,
          description : "SSH ingress rule for ${local.bastion_nsg_name}.",
          stateless : false,
          protocol : "6",
          src : local.bastion_nsg_name,
          src_type : "NSG_NAME",
          src_port_min : null,
          src_port_max : null,
          dst_port_min : 22,
          dst_port_max : 22,
          icmp_code : null,
          icmp_type : null

        },
        ingress-rule-src-app-nsg : {
          is_create : true,
          description : "Database ingress rule for ${local.app_nsg_name}.",
          stateless : false,
          protocol : "6",
          src : local.app_nsg_name,
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
        egress-rule-dst-osn-services : {
          is_create : true,
          description : "OSN egress rule for ${local.valid_service_gateway_cidrs[0]}.",
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
    }
  }
}

module "cis_nsgs_hub" {
  depends_on = [
    module.cis_vcn
  ]
  count                  = var.hub_spoke_architecture == true ? 1 : 0
  source                 = "../modules/network/security"
  default_compartment_id = module.cis_compartments.compartments[local.network_compartment_name].id
  vcn_id                 = module.cis_dmz_vcn[0].vcn.id
  nsgs = {
    (local.dmz_bastion_nsg_name) : {
      ingress_rules : {
        ingress-rule-src-public-bastion-cidr : {
          is_create : (!var.no_internet_access && !tobool(var.is_vcn_onprem_connected)),
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
        ingress-rule-src-onprem-cidr : {
          is_create : tobool(var.is_vcn_onprem_connected),
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
      egress_rules : {
        egress-rule-dst-hub-vcn-cidr : {
          is_create : true,
          description : "SSH egress rule for ${local.dmz_vcn_display_name}.",
          protocol : "6",
          stateless : false,
          dst      = var.dmz_vcn_cidr,
          dst_type = "CIDR_BLOCK",
          dst_port_min : 22,
          dst_port_max : 22,
          src_port_min : null,
          src_port_max : null,
          icmp_type : null,
          icmp_code : null
        },
        egress-rule-dst-spoke1-cidr : {
          is_create : true,
          description : "SSH egress rule for Spoke 1 ${local.vcn_display_name}.",
          protocol : "6",
          stateless : false,
          dst      = var.vcn_cidr,
          dst_type = "CIDR_BLOCK",
          dst_port_min : 22,
          dst_port_max : 22,
          src_port_min : null,
          src_port_max : null,
          icmp_type : null,
          icmp_code : null
        },
        egress-rule-dst-spoke2-cidr : {
          is_create : true,
          description : "SSH egress rule for Spoke 2 ${local.spoke2_vcn_display_name}.",
          protocol : "6",
          stateless : false,
          dst      = var.spoke2_vcn_cidr,
          dst_type = "CIDR_BLOCK",
          dst_port_min : 22,
          dst_port_max : 22,
          src_port_min : null,
          src_port_max : null,
          icmp_type : null,
          icmp_code : null
        },
        egress-rule-dst-osn-services : {
          is_create : true,
          description : "OSN egress rule for ${local.valid_service_gateway_cidrs[0]}.",
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
        }

      }
    },
    (local.dmz_services_nsg_name) : {
      ingress_rules : {
        ingress-rule-src-public-lbr-cidr : {
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
        ingress-rule-src-onprem-cidr : {
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
        ingress-rule-src-bastion-nsg : {
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
      egress_rules : {
        egress-rule-dst-spoke1 : {
          is_create : true,
          description : "HTTP egress rule for Spoke 1 ${local.vcn_display_name}.",
          protocol : "6",
          stateless : false,
          dst      = var.vcn_cidr,
          dst_type = "CIDR_BLOCK",
          dst_port_min : 80,
          dst_port_max : 80,
          src_port_min : null,
          src_port_max : null,
          icmp_type : null,
          icmp_code : null
        },
        egress-rule-dst-spoke2 : {
          is_create : true,
          description : "HTTP egress rule for Spoke 2 ${local.spoke2_vcn_display_name}.",
          protocol : "6",
          stateless : false,
          dst      = var.spoke2_vcn_cidr,
          dst_type = "CIDR_BLOCK",
          dst_port_min : 80,
          dst_port_max : 80,
          src_port_min : null,
          src_port_max : null,
          icmp_type : null,
          icmp_code : null
        },
        egress-rule-dst-osn-services : {
          is_create : true,
          description : "OSN egress rule for ${local.valid_service_gateway_cidrs[0]}.",
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
        }
      }

    }
  }
}

module "cis_nsgs_spoke2" {
  count                  = var.hub_spoke_architecture == true ? 1 : 0
  source                 = "../modules/network/security"
  default_compartment_id = module.cis_compartments.compartments[local.network_compartment_name].id
  vcn_id                 = module.cis_spoke2_vcn[0].vcn.id
  nsgs = {
    (local.spoke2_bastion_nsg_name) : {
      ingress_rules : {
        ingress-rule-src-bastion-hub-cidr : {
          is_create : true,
          description : "SSH ingress rule for ${local.dmz_bastion_subnet_name}.",
          stateless : false,
          protocol : "6",
          src : var.dmz_bastion_subnet_cidr,
          src_type : "CIDR_BLOCK",
          src_port_min : null,
          src_port_max : null,
          dst_port_min : 22,
          dst_port_max : 22,
          icmp_code : null,
          icmp_type : null
        }
      },
      egress_rules : {}
    },
    (local.spoke2_lbr_nsg_name) : {
      ingress_rules : {
        ingress-rule-src-onprem-cidr : {
          is_create : tobool(var.is_vcn_onprem_connected),
          description : "HTTPS traffic ingress rule for on-premises CIDR ${var.onprem_cidr}.",
          stateless : false,
          protocol : "6",
          src : var.onprem_cidr,
          src_type : "CIDR_BLOCK",
          src_port_min : null,
          src_port_max : null,
          dst_port_min : 443,
          dst_port_max : 443,
          icmp_code : null,
          icmp_type : null
        },
        ingress-rule-src-services-hub-cidr : {
          is_create : true,
          description : "HTTPS traffic ingress rule for ${local.dmz_services_subnet_name}.",
          stateless : false,
          protocol : "6",
          src : var.dmz_services_subnet_cidr,
          src_type : "CIDR_BLOCK",
          src_port_min : null,
          src_port_max : null,
          dst_port_min : 443,
          dst_port_max : 443,
          icmp_code : null,
          icmp_type : null
        }
      },
      egress_rules : {
        egress-rule-dst-app-nsg : {
          is_create : true,
          description : "HTTP egress rule for ${local.spoke2_app_nsg_name}.",
          stateless : false,
          protocol : "6",
          dst      = local.spoke2_app_nsg_name,
          dst_type = "NSG_NAME",
          src_port_min : null,
          src_port_max : null,
          dst_port_min : 80,
          dst_port_max : 80,
          icmp_code : null,
          icmp_type : null
        },
      egress-rule-dst-osn-services : {
          is_create : true,
          description : "OSN egress rule for ${local.valid_service_gateway_cidrs[0]}.",
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
    },
    (local.spoke2_app_nsg_name) : {
      ingress_rules : {
        ingress-rule-src-lbr-nsg : {
          is_create : true,
          description : "HTTP ingress rule from ${local.spoke2_lbr_nsg_name}.",
          stateless : false,
          protocol : "6",
          src : local.spoke2_lbr_nsg_name,
          src_type : "NSG_NAME",
          src_port_min : null,
          src_port_max : null,
          dst_port_min : 80,
          dst_port_max : 80,
          icmp_code : null,
          icmp_type : null
        }
      },
      egress_rules : {
        egress-rule-dst-db-nsg : {
          is_create : true,
          description : "Database egress rule for ${local.spoke2_db_nsg_name}.",
          stateless : false,
          protocol : "6",
          dst      = local.spoke2_db_nsg_name,
          dst_type = "NSG_NAME",
          src_port_min : null,
          src_port_max : null,
          dst_port_min : 1521,
          dst_port_max : 1522,
          icmp_code : null,
          icmp_type : null
        },
        egress-rule-dst-osn-services : {
          is_create : true,
          description : "OSN egress rule for ${local.valid_service_gateway_cidrs[0]}.",
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
    },
    (local.spoke2_db_nsg_name) : {
      ingress_rules : {
        ingress-rule-src-app-nsg : {
          is_create : true,
          description : "Database ingress rule for ${local.spoke2_app_nsg_name}.",
          stateless : false,
          protocol : "6",
          src : local.spoke2_app_nsg_name,
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
        egress-rule-dst-osn-services : {
          is_create : true,
          description : "OSN egress rule for ${local.valid_service_gateway_cidrs[0]}.",
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
    }
  }

}