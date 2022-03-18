# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  all_drg_defined_tags = {}
  all_drg_freeform_tags = {}

  ### DON'T TOUCH THESE ###
  default_drg_defined_tags = null
  default_drg_freeform_tags = local.landing_zone_tags
  
  drg_defined_tags = length(local.all_drg_defined_tags) > 0 ? local.all_drg_defined_tags : local.default_drg_defined_tags
  drg_freeform_tags = length(local.all_drg_freeform_tags) > 0 ? merge(local.all_drg_freeform_tags, local.default_drg_freeform_tags) : local.default_drg_freeform_tags

}

module "lz_drg" {
  source         = "../modules/network/drg"
  depends_on     = [ null_resource.wait_on_compartments ]
  compartment_id = local.network_compartment_id #module.lz_compartments.compartments[local.network_compartment.key].id
  service_label  = var.service_label
  is_create_drg  = (var.is_vcn_onprem_connected == true || var.hub_spoke_architecture) && var.existing_drg_id == ""
  defined_tags   = local.drg_defined_tags
  freeform_tags  = local.drg_freeform_tags
}