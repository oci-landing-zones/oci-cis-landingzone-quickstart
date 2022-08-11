# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### Creates scanning recipes and targets. All Landing Zone compartments are targets.

locals {
  all_scan_recipes = {}
  all_scan_targets = {}
  all_vss_defined_tags = null
  all_vss_freeform_tags = null
  vss_custom_recipe_name = null
  vss_custom_policy_name = null
}

module "lz_scanning" {
  source     = "../modules/security/vss"
  depends_on = [null_resource.wait_on_services_policy]
  tenancy_id = var.tenancy_ocid
  compartment_id = local.security_compartment_id
  name_prefix = var.service_label
  vss_create = var.vss_create
  vss_scan_schedule = var.vss_scan_schedule
  vss_scan_day = var.vss_scan_day
  vss_targets = {for k, v in module.lz_compartments.compartments : k => {"target_compartment_id" : v.id, "target_compartment_name" : v.name}}
  vss_target_names = keys(module.lz_compartments.compartments)
  vss_recipe_name = local.vss_custom_recipe_name
  vss_policy_name = local.vss_custom_policy_name
  defined_tags  = local.all_vss_defined_tags
  freeform_tags = local.all_vss_freeform_tags != null ? merge(local.all_vss_freeform_tags, local.landing_zone_tags) : local.landing_zone_tags

  #-- Custom recipes and targets that override Landing Zone's defaults.
  vss_custom_recipes = local.all_scan_recipes
  vss_custom_targets = local.all_scan_targets
  
  #-- VSS is a regional service. As such, we must not skip provisioning when extending Landing Zone to a new region.
}