# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  # # Subnet Names used can be changed first subnet will be Public if var.no_internet_access is false
  # spoke_subnet_names = ["web", "app", "db"]
  # # Subnet Names used can be changed first subnet will be Public if var.no_internet_access is false
  # dmz_subnet_names = ["outdoor","indoor","mgmt","ha", "diag"]

  vcns_map = { for v in var.vcn_cidrs : "vcn${index(var.vcn_cidrs, v)}" => {
    name = length(var.vcn_names) > 0 ? (length(regexall("[a-zA-Z0-9-]+", var.vcn_names[index(var.vcn_cidrs, v)])) > 0 ? join("", regexall("[a-zA-Z0-9-]+", var.vcn_names[index(var.vcn_cidrs, v)])) : var.vcn_names[index(var.vcn_cidrs, v)]) : "${var.service_label}-${index(var.vcn_cidrs, v)}-vcn"
    cidr = v
    }
  }

  ### VCNs ###
  vcns = { for key, vcn in local.vcns_map : vcn.name => {
    compartment_id    = module.lz_compartments.compartments[local.network_compartment.key].id
    cidr              = vcn.cidr
    dns_label         = length(regexall("[a-zA-Z0-9]+", vcn.name)) > 0 ? "${substr(join("", regexall("[a-zA-Z0-9]+", vcn.name)), 0, 11)}${local.region_key}" : "${substr(vcn.name, 0, 11)}${local.region_key}"
    is_create_igw     = length(var.dmz_vcn_cidr) > 0 ? false : (! var.no_internet_access == true ? true : false)
    is_attach_drg     = var.is_vcn_onprem_connected == true || var.hub_spoke_architecture == true ? (var.dmz_for_firewall == true ? false : true) : false
    block_nat_traffic = false
    defined_tags      = null
    subnets = { for s in local.spoke_subnet_names : replace("${vcn.name}-${s}-subnet", "-vcn", "") => {
      compartment_id  = null
      name            = replace("${vcn.name}-${s}-subnet", "-vcn", "")
      defined_tags    = null
      cidr            = cidrsubnet(vcn.cidr, 4, index(local.spoke_subnet_names, s))
      dns_label       = s
      private         = length(var.dmz_vcn_cidr) > 0 || var.no_internet_access ? true : (index(local.spoke_subnet_names, s) == 0 ? false : true)
      dhcp_options_id = null
      security_lists = { "security-list" : {
        compartment_id : null
        is_create : true
        ingress_rules : [{
          is_create : s == "app" && length(var.onprem_cidrs) == 0 && var.hub_spoke_architecture == false
          protocol : "6"
          stateless : false
          description : "Allows SSH connections from hosts in ${vcn.cidr} CIDR range."
          src : vcn.cidr
          src_type : "CIDR_BLOCK"
          icmp_type : null
          icmp_code : null
          src_port_min : null 
          src_port_max : null
          dst_port_min : "22"
          dst_port_max : "22"
        }]
        egress_rules : [{
          is_create : s == "app" && length(var.onprem_cidrs) == 0 && var.hub_spoke_architecture == false
          protocol : "6"
          stateless : false
          description : "Allows SSH connections to hosts in ${vcn.cidr} CIDR range."
          dst : vcn.cidr
          dst_type : "CIDR_BLOCK"
          icmp_type : null
          icmp_code : null
          src_port_min : null 
          src_port_max : null
          dst_port_min : "22"
          dst_port_max : "22"
        }]
        defined_tags  = null
        freeform_tags = null
        }
      }
      }
    }
    }
  }


  # All VCNs
  all_lz_spoke_vcns = local.vcns

  # Output from VCNs
  all_lz_spoke_vcn_ids = module.lz_vcn_spokes.vcns
  all_lz_spoke_subnets = module.lz_vcn_spokes.subnets

  ### Route Tables ###
  ## Web Subnet Route Tables
  web_route_tables = { for key, subnet in local.all_lz_spoke_subnets : replace("${key}-rtable", "vcn-", "") => {
    compartment_id = subnet.compartment_id
    vcn_id         = subnet.vcn_id
    subnet_id      = subnet.id
    defined_tags   = null
    route_rules = concat([{
      is_create         = length(var.dmz_vcn_cidr) > 0 || var.no_internet_access ? true : false
      destination       = local.valid_service_gateway_cidrs[0]
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = module.lz_vcn_spokes.service_gateways[subnet.vcn_id].id
      description       = "Traffic destined to ${local.valid_service_gateway_cidrs[0]} goes to Service Gateway."
      },
      {
        is_create         = length(var.dmz_vcn_cidr) == 0 && ! var.no_internet_access ? true : false
        destination       = local.valid_service_gateway_cidrs[1]
        destination_type  = "SERVICE_CIDR_BLOCK"
        network_entity_id = module.lz_vcn_spokes.service_gateways[subnet.vcn_id].id
        description       = "Traffic destined to ${local.valid_service_gateway_cidrs[1]} goes to Service Gateway."
      },
      {
        is_create         = length(var.dmz_vcn_cidr) > 0
        destination       = local.anywhere
        destination_type  = "CIDR_BLOCK"
        network_entity_id = var.existing_drg_id != "" ? var.existing_drg_id : (module.lz_drg.drg != null ? module.lz_drg.drg.id : null)
        description       = "Traffic destined to ${local.anywhere} goes to Internet Gateway."
      },
      {
        is_create         = length(var.dmz_vcn_cidr) == 0 && ! var.no_internet_access ? true : false
        destination       = local.anywhere
        destination_type  = "CIDR_BLOCK"
        network_entity_id = length(var.dmz_vcn_cidr) == 0 && ! var.no_internet_access ? module.lz_vcn_spokes.internet_gateways[subnet.vcn_id].id : null
        description       = "Traffic destined to ${local.anywhere} goes to Internet Gateway."

      }
      ],
      [for vcn_name, vcn in local.all_lz_spoke_vcn_ids : {
        is_create         = var.hub_spoke_architecture && length(var.dmz_vcn_cidr) == 0
        destination       = vcn.cidr_block
        destination_type  = "CIDR_BLOCK"
        network_entity_id = var.existing_drg_id != "" ? var.existing_drg_id : (module.lz_drg.drg != null ? module.lz_drg.drg.id : null)
        description       = "Traffic destined to ${vcn_name} VCN goes to DRG."
        } if subnet.vcn_id != vcn.id
      ],
      [for cidr in var.onprem_cidrs : {
        is_create         = length(var.dmz_vcn_cidr) == 0
        destination       = cidr
        destination_type  = "CIDR_BLOCK"
        network_entity_id = var.existing_drg_id != "" ? var.existing_drg_id : (module.lz_drg.drg != null ? module.lz_drg.drg.id : null)
        description       = "Traffic destined to on-premises ${cidr} CIDR range goes to DRG."
        }
      ]
    )
  } if length(regexall(".*-${local.spoke_subnet_names[0]}-*", key)) > 0 }

  ## App Subnet Route Tables
  app_route_tables = { for key, subnet in local.all_lz_spoke_subnets : replace("${key}-rtable", "vcn-", "") => {
    compartment_id = subnet.compartment_id
    vcn_id         = subnet.vcn_id
    subnet_id      = subnet.id
    defined_tags   = null
    route_rules = concat([{
      is_create         = true
      destination       = local.valid_service_gateway_cidrs[0]
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = module.lz_vcn_spokes.service_gateways[subnet.vcn_id].id
      description       = "Traffic destined to ${local.valid_service_gateway_cidrs[0]} goes to Service Gateway."
      },
      {
        is_create         = length(var.dmz_vcn_cidr) > 0
        destination       = local.anywhere
        destination_type  = "CIDR_BLOCK"
        network_entity_id = var.existing_drg_id != "" ? var.existing_drg_id : (module.lz_drg.drg != null ? module.lz_drg.drg.id : null)
        description       = "Traffic destined to ${local.anywhere} goes to DRG."
      },
      {
        is_create         = length(var.dmz_vcn_cidr) == 0 && ! var.no_internet_access ? true : false
        destination       = local.anywhere
        destination_type  = "CIDR_BLOCK"
        network_entity_id = length(var.dmz_vcn_cidr) == 0 && ! var.no_internet_access ? module.lz_vcn_spokes.nat_gateways[subnet.vcn_id].id : null
        description       = "Traffic destined to ${local.anywhere} goes to NAT Gateway."

      }
      ],
      [for vcn_name, vcn in local.all_lz_spoke_vcn_ids : {
        is_create         = var.hub_spoke_architecture && length(var.dmz_vcn_cidr) == 0
        destination       = vcn.cidr_block
        destination_type  = "CIDR_BLOCK"
        network_entity_id = var.existing_drg_id != "" ? var.existing_drg_id : (module.lz_drg.drg != null ? module.lz_drg.drg.id : null)
        description       = "Traffic destined to ${vcn_name} VCN goes to DRG."
        } if subnet.vcn_id != vcn.id
      ],
      [for cidr in var.onprem_cidrs : {
        is_create         = length(var.dmz_vcn_cidr) == 0
        destination       = cidr
        destination_type  = "CIDR_BLOCK"
        network_entity_id = var.existing_drg_id != "" ? var.existing_drg_id : (module.lz_drg.drg != null ? module.lz_drg.drg.id : null)
        description       = "Traffic destined to on-premises ${cidr} CIDR range goes to DRG."
        }
      ],
      [for cidr in var.exacs_vcn_cidrs : {
        is_create         = var.hub_spoke_architecture && length(var.dmz_vcn_cidr) == 0
        destination       = cidr
        destination_type  = "CIDR_BLOCK"
        network_entity_id = var.existing_drg_id != "" ? var.existing_drg_id : (module.lz_drg.drg != null ? module.lz_drg.drg.id : null)
        description       = "Traffic destined to Exadata ${cidr} CIDR range goes to DRG."
        }
      ]
    )
  } if length(regexall(".*-${local.spoke_subnet_names[1]}-*", key)) > 0 }

  ## Database Subnet Route Tables
  db_route_tables = { for key, subnet in local.all_lz_spoke_subnets : replace("${key}-rtable", "vcn-", "") => {
    compartment_id = subnet.compartment_id
    vcn_id         = subnet.vcn_id
    subnet_id      = subnet.id
    defined_tags   = null
    route_rules = concat([{
      is_create         = true
      destination       = local.valid_service_gateway_cidrs[0]
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = module.lz_vcn_spokes.service_gateways[subnet.vcn_id].id
      description       = "Traffic destined to ${local.valid_service_gateway_cidrs[0]} goes to Service Gateway."
      },
      {
        is_create         = length(var.dmz_vcn_cidr) > 0
        destination       = local.anywhere
        destination_type  = "CIDR_BLOCK"
        network_entity_id = var.existing_drg_id != "" ? var.existing_drg_id : (module.lz_drg.drg != null ? module.lz_drg.drg.id : null)
        description       = "Traffic destined to ${local.anywhere} goes to DRG."
      }
      ],
      [for vcn_name, vcn in local.all_lz_spoke_vcn_ids : {
        is_create         = var.hub_spoke_architecture && length(var.dmz_vcn_cidr) == 0
        destination       = vcn.cidr_block
        destination_type  = "CIDR_BLOCK"
        network_entity_id = var.existing_drg_id != "" ? var.existing_drg_id : (module.lz_drg.drg != null ? module.lz_drg.drg.id : null)
        description       = "Traffic destined to ${vcn_name} VCN goes to DRG."
        } if subnet.vcn_id != vcn.id
      ],
      [for cidr in var.onprem_cidrs : {
        is_create         = length(var.dmz_vcn_cidr) == 0
        destination       = cidr
        destination_type  = "CIDR_BLOCK"
        network_entity_id = var.existing_drg_id != "" ? var.existing_drg_id : (module.lz_drg.drg != null ? module.lz_drg.drg.id : null)
        description       = "Traffic destined to on-premises ${cidr} CIDR range goes to DRG."
        }
    ])
  } if length(regexall(".*-${local.spoke_subnet_names[2]}-*", key)) > 0 }

  lz_subnets_route_tables = merge(local.web_route_tables, local.app_route_tables, local.db_route_tables)

}

module "lz_vcn_spokes" {
  source               = "../modules/network/vcn-basic"
  depends_on           = [null_resource.slow_down_vcn]
  compartment_id       = module.lz_compartments.compartments[local.network_compartment.key].id
  service_label        = var.service_label
  service_gateway_cidr = local.valid_service_gateway_cidrs[0]
  drg_id               = var.existing_drg_id != "" ? var.existing_drg_id : (module.lz_drg.drg != null ? module.lz_drg.drg.id : null)
  vcns                 = local.all_lz_spoke_vcns
}

module "lz_route_tables_spokes" {
  depends_on           = [module.lz_vcn_spokes]
  source               = "../modules/network/vcn-routing"
  compartment_id       = module.lz_compartments.compartments[local.network_compartment.key].id
  subnets_route_tables = local.lz_subnets_route_tables
}

resource "null_resource" "slow_down_vcn" {
  depends_on = [module.lz_compartments]
  provisioner "local-exec" {
    command = "sleep ${local.delay_in_secs}" # Wait for compartments to be available.
  }
}