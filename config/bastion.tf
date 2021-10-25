# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  spoke_bastion = {for subnet in module.lz_vcn_spokes.subnets : subnet.display_name => {
      name = "${replace(subnet.display_name,"/[^a-zA-Z0-9]/","")}Bastion"
      compartment_id = module.lz_compartments.compartments[local.security_compartment.key].id
      target_subnet_id = subnet.id
      client_cidr_block_allow_list = var.public_src_bastion_cidrs
      max_session_ttl_in_seconds = local.bastion_max_session_ttl_in_seconds
    } if (length(var.public_src_bastion_cidrs) > 0) && length(var.vcn_cidrs) == 1 && !var.is_vcn_onprem_connected && var.hub_spoke_architecture == false && (length(regexall(".*${local.spoke_subnet_names[1]}*", subnet.display_name)) > 0)}
  
  exacs_bastion = {for subnet in module.lz_exacs_vcns.subnets : subnet.display_name => {
      name = "${replace(subnet.display_name,"/[^a-zA-Z0-9]/","")}Bastion"
      compartment_id = module.lz_compartments.compartments[local.security_compartment.key].id
      target_subnet_id = subnet.id
      client_cidr_block_allow_list = var.public_src_bastion_cidrs
      max_session_ttl_in_seconds = local.bastion_max_session_ttl_in_seconds
    } if (length(var.public_src_bastion_cidrs) > 0) && length(var.exacs_vcn_cidrs) == 1 && !var.is_vcn_onprem_connected && var.hub_spoke_architecture == false && (length(regexall(".*${local.client_subnet_prefix}*", subnet.display_name)) > 0)}
  
  all_bastions = merge(local.exacs_bastion,local.spoke_bastion)
  
}

module "lz_app_bastion" {
    source = "../modules/security/bastion"
    bastions = local.all_bastions
}
