# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "lz_app_bastion" {
    source = "../modules/security/bastion"
    count = (var.bastion_create == true && var.is_vcn_onprem_connected  == false && var.hub_spoke_architecture == false) ? 1 : 0
    bastion = {
        name = local.bastion_name
        compartment_id = module.lz_compartments.compartments[local.appdev_compartment_name].id
        target_subnet_id = module.lz_vcn_spokes.subnets["${var.service_label}-0-app-subnet"].id
        client_cidr_block_allow_list = var.public_src_bastion_cidrs
        max_session_ttl_in_seconds = local.bastion_max_session_ttl_in_seconds
    }
}