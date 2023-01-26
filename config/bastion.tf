# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  all_bastion_defined_tags = {}
  all_bastion_freeform_tags = {}

  spoke_bastion = {for subnet in module.lz_vcn_spokes.subnets : subnet.display_name => {
      name = "${var.service_label}${upper(local.region_key)}${replace(subnet.display_name,"/[^a-zA-Z0-9]/","")}Bastion"
      compartment_id = local.security_compartment_id
      target_subnet_id = subnet.id
      client_cidr_block_allow_list = var.public_src_bastion_cidrs
      max_session_ttl_in_seconds = local.bastion_max_session_ttl_in_seconds
      defined_tags = local.bastion_defined_tags
      freeform_tags = local.bastion_freeform_tags
    } if  length(var.public_src_bastion_cidrs) > 0 && 
          length(var.vcn_cidrs) == 1 && 
          !var.is_vcn_onprem_connected && 
          !var.hub_spoke_architecture && 
          subnet.prohibit_public_ip_on_vnic == true && 
          contains(slice(split("-",subnet.display_name),1,length(split("-",subnet.display_name))-1), (length(local.spoke_subnet_names) > 1 ? local.spoke_subnet_names[1] : local.spoke_subnet_names[0]))
  }
  
  exacs_bastion = {for subnet in module.lz_exacs_vcns.subnets : subnet.display_name => {
      name = "${var.service_label}${upper(local.region_key)}${replace(subnet.display_name,"/[^a-zA-Z0-9]/","")}Bastion"
      compartment_id = local.security_compartment_id
      target_subnet_id = subnet.id
      client_cidr_block_allow_list = var.public_src_bastion_cidrs
      max_session_ttl_in_seconds = local.bastion_max_session_ttl_in_seconds
      defined_tags = local.bastion_defined_tags
      freeform_tags = local.bastion_freeform_tags
    } if  length(var.public_src_bastion_cidrs) > 0 && 
          length(var.exacs_vcn_cidrs) == 1 && 
          !var.is_vcn_onprem_connected && 
          !var.hub_spoke_architecture && 
          contains(slice(split("-",subnet.display_name),1,length(split("-",subnet.display_name))-1), local.client_subnet_prefix)}
  
  all_bastions = merge(local.exacs_bastion,local.spoke_bastion)

  ### DON'T TOUCH THESE ###
  default_bastion_defined_tags = null
  default_bastion_freeform_tags = local.landing_zone_tags

  bastion_defined_tags = length(local.all_bastion_defined_tags) > 0 ? local.all_bastion_defined_tags : local.default_bastion_defined_tags
  bastion_freeform_tags = length(local.all_bastion_freeform_tags) > 0 ? merge(local.all_bastion_freeform_tags, local.default_bastion_freeform_tags) : local.default_bastion_freeform_tags
  
}

module "lz_app_bastion" {
    source = "../modules/security/bastion"
    bastions = local.all_bastions
}
