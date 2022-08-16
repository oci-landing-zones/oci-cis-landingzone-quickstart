# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  all_security_zones_defined_tags  = {}
  all_security_zones_freeform_tags = {}

  managed_enclosing_target_sz_compartment  = length(module.lz_top_compartment) > 0 ? { "${local.enclosing_compartment.key}-security-zone" = { "sz_compartment_name" : module.lz_top_compartment[0].compartments[local.enclosing_compartment.key].name, "sz_compartment_id" : module.lz_top_compartment[0].compartments[local.enclosing_compartment.key].id } } : {}
  existing_enclosing_target_sz_compartment = var.existing_enclosing_compartment_ocid != null ? { "${local.enclosing_compartment.key}-security-zone" = { "sz_compartment_name" : data.oci_identity_compartment.enclosing_compartment.name, "sz_compartment_id" : var.existing_enclosing_compartment_ocid } } : {}
  managed_compartments_sz_compartments     = { for k, v in module.lz_compartments.compartments : "${k}-security-zone" => { "sz_comparment_id" : v.id, "sz_compartment_name" : v.name } }
  security_zone_target_compartments        = length(local.managed_enclosing_target_sz_compartment) > 0 ? local.managed_enclosing_target_sz_compartment : (length(local.existing_enclosing_target_sz_compartment) > 0 ? local.existing_enclosing_target_sz_compartment : local.managed_compartments_sz_compartments)
}

data "oci_identity_compartment" "enclosing_compartment" {
  id = var.existing_enclosing_compartment_ocid != null ? var.existing_enclosing_compartment_ocid : var.tenancy_ocid
}
module "lz_security_zones" {
  count                  = var.create_security_zone ? 1 : 0
  source                 = "../modules/security/security-zones"
  providers              = { oci = oci.home }
  cis_level              = var.cis_level
  security_policies      = var.sz_security_policies
  sz_target_compartments = local.security_zone_target_compartments

}

locals {

  ### DON'T TOUCH THESE ###
  default_security_zones_defined_tags  = null
  default_security_zones_freeform_tags = local.landing_zone_tags

  security_zones_defined_tags  = length(local.all_security_zones_defined_tags) > 0 ? local.all_security_zones_defined_tags : local.default_security_zones_defined_tags
  security_zones_freeform_tags = length(local.all_security_zones_freeform_tags) > 0 ? merge(local.all_security_zones_freeform_tags, local.default_security_zones_freeform_tags) : local.default_security_zones_freeform_tags
}