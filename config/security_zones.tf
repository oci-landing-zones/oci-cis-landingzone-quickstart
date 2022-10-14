# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  all_security_zones_defined_tags  = {}
  all_security_zones_freeform_tags = {}

  managed_enclosing_target_sz_compartment  = length(module.lz_top_compartment) > 0 ? { "${local.enclosing_compartment.key}-security-zone" = { "sz_compartment_name" : module.lz_top_compartment[0].compartments[local.enclosing_compartment.key].name, "sz_compartment_id" : module.lz_top_compartment[0].compartments[local.enclosing_compartment.key].id } } : {}
  existing_enclosing_target_sz_compartment = local.enclosing_compartment_id != var.tenancy_ocid ? { "${local.enclosing_compartment.key}-security-zone" = { "sz_compartment_name" : local.enclosing_compartment.name, "sz_compartment_id" : local.enclosing_compartment_id } } : {}
  managed_compartments_sz_compartments     = { for k, v in module.lz_compartments.compartments : "${k}-security-zone" => { "sz_compartment_name" : v.name, "sz_compartment_id" : v.id } }
  auto_security_zone_target_compartments   = length(local.managed_enclosing_target_sz_compartment) > 0 ? local.managed_enclosing_target_sz_compartment : (length(local.existing_enclosing_target_sz_compartment) > 0 ? local.existing_enclosing_target_sz_compartment : local.managed_compartments_sz_compartments)
  custom_security_zone_target_compartments = {}
  security_zone_target_compartments = local.custom_security_zone_target_compartments == {} ? local.auto_security_zone_target_compartments : local.custom_security_zone_target_compartments

}

module "lz_security_zones" {
  depends_on = [
    module.lz_compartments
  ]
  source                 = "../modules/security/security-zones"
  providers              = { oci = oci.home }
  count                  = var.enable_security_zones ? 1 : 0
  compartment_id         = var.tenancy_ocid
  cis_level              = var.cis_level
  security_policies      = var.sz_security_policies
  sz_target_compartments = local.security_zone_target_compartments
  defined_tags           = local.security_zones_defined_tags
  freeform_tags          = local.security_zones_freeform_tags

}

locals {

  ### DON'T TOUCH THESE ###
  default_security_zones_defined_tags  = null
  default_security_zones_freeform_tags = local.landing_zone_tags

  security_zones_defined_tags  = length(local.all_security_zones_defined_tags) > 0 ? local.all_security_zones_defined_tags : local.default_security_zones_defined_tags
  security_zones_freeform_tags = length(local.all_security_zones_freeform_tags) > 0 ? merge(local.all_security_zones_freeform_tags, local.default_security_zones_freeform_tags) : local.default_security_zones_freeform_tags
}