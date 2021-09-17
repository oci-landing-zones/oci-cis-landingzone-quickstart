# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "lz_app_bastion" {
    source = "../modules/security/bastion"
    bastions = {for subnet in module.lz_vcn_spokes.subnets : subnet.display_name => {
      name = "${replace(subnet.display_name,"/[^a-zA-Z0-9]/","")}Bastion"
      compartment_id = module.lz_compartments.compartments[local.security_compartment.key].id
      target_subnet_id = subnet.id
      client_cidr_block_allow_list = var.public_src_bastion_cidrs
      max_session_ttl_in_seconds = local.bastion_max_session_ttl_in_seconds
    } if (var.bastion_create == true && length(var.onprem_cidrs) == 0 && var.hub_spoke_architecture == false && length(regexall(".*-app-*", subnet.display_name)) > 0)}
}
