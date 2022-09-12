# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### Creates scanning recipes and targets. All Landing Zone compartments are targets.

locals {
#------------------------------------------------------------------------------------------------------
#-- Any of these local vars before can be overriden in a _override.tf file
#------------------------------------------------------------------------------------------------------
  custom_vss_recipes = {}
  custom_vss_targets = {}
  custom_vss_defined_tags = null
  custom_vss_freeform_tags = null
  custom_vss_recipe_name = null
  custom_vss_policy_name = null
}

module "lz_scanning" {
  source     = "../modules/security/vss"
  providers  = {
    oci = oci
    oci.home = oci.home
  }
  count      = var.vss_create ? 1 : 0
  tenancy_id = var.tenancy_ocid
  compartment_id = local.security_compartment_id
  manage_iam_policies = !var.extend_landing_zone_to_new_region

  vss_scan_schedule = var.vss_scan_schedule
  vss_scan_day      = var.vss_scan_day
  vss_port_scan_level  = var.vss_port_scan_level
  vss_agent_scan_level = var.vss_agent_scan_level
  vss_agent_cis_benchmark_settings_scan_level = var.vss_agent_cis_benchmark_settings_scan_level
  vss_enable_file_scan = var.vss_enable_file_scan
  vss_folders_to_scan  = var.vss_folders_to_scan

  vss_targets       = {for k, v in module.lz_compartments.compartments : k => {"target_compartment_id" : v.id, "target_compartment_name" : v.name}}
  vss_target_names  = keys(module.lz_compartments.compartments)
  vss_recipe_name   = local.vss_recipe_name
  vss_policy_name   = local.vss_policy_name

  defined_tags  = local.vss_defined_tags
  freeform_tags = local.vss_freeform_tags

  vss_custom_recipes = local.custom_vss_recipes
  vss_custom_targets = local.custom_vss_targets

  #-- VSS is a regional service. As such, we must not skip provisioning when extending Landing Zone to a new region.
}

locals {
  ### DON'T TOUCH THESE ###
  default_vss_defined_tags = null
  default_vss_freeform_tags = local.landing_zone_tags
  
  vss_defined_tags =  local.custom_vss_defined_tags != null ? merge(local.custom_vss_defined_tags, local.default_vss_defined_tags) : local.default_vss_defined_tags
  vss_freeform_tags = local.custom_vss_freeform_tags != null ? merge(local.custom_vss_freeform_tags, local.default_vss_freeform_tags) : local.default_vss_freeform_tags

  vss_recipe_name = local.custom_vss_recipe_name != null ? local.custom_vss_recipe_name : "${var.service_label}-default-scan-recipe"
  vss_policy_name = local.custom_vss_policy_name != null ? local.custom_vss_policy_name : "${var.service_label}-scan-policy" 
  ###
}