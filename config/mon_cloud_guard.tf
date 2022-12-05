# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
#--------------------------------------------------------------------------
#-- Any of these custom variables can be overriden in a _override.tf file.
#--------------------------------------------------------------------------  
  #-- Custom target name
  custom_target_name = null
  #-- Custom names for cloned recipes
  custom_configuration_detector_recipe_name = null
  custom_activity_detector_recipe_name = null
  custom_threat_detector_recipe_name = null
  custom_responder_recipe_name = null
  #-- Custom tags
  custom_cloud_guard_target_defined_tags = null
  custom_cloud_guard_target_freeform_tags = null
}

module "lz_cloud_guard" {
  count                 = var.enable_cloud_guard ? 1 : 0
  depends_on            = [null_resource.wait_on_services_policy]
  source                = "../modules/monitoring/cloud-guard"
  providers             = { oci = oci.home }
  enable_cloud_guard    = var.enable_cloud_guard
  enable_cloned_recipes = var.enable_cloud_guard_cloned_recipes
  reporting_region      = var.cloud_guard_reporting_region != null ? var.cloud_guard_reporting_region : local.regions_map[local.home_region_key]
  tenancy_id            = var.tenancy_ocid
  compartment_id        = var.tenancy_ocid
  name_prefix           = var.service_label
  target_resource_id    = var.tenancy_ocid
  target_resource_name  = local.custom_target_name
  defined_tags          = local.cloud_guard_target_defined_tags
  freeform_tags         = local.cloud_guard_target_freeform_tags

  configuration_detector_recipe_name = local.custom_configuration_detector_recipe_name
  activity_detector_recipe_name      = local.custom_activity_detector_recipe_name
  threat_detector_recipe_name        = local.custom_threat_detector_recipe_name
  responder_recipe_name              = local.custom_responder_recipe_name
}

locals {
#--------------------------------------------------------------------------
#-- These variables are NOT meant to be overriden.
#--------------------------------------------------------------------------
  default_cloud_guard_target_defined_tags = null
  default_cloud_guard_target_freeform_tags = local.landing_zone_tags
  
  cloud_guard_target_defined_tags = local.custom_cloud_guard_target_defined_tags != null ? merge(local.custom_cloud_guard_target_defined_tags, local.default_cloud_guard_target_defined_tags)  : local.default_cloud_guard_target_defined_tags
  cloud_guard_target_freeform_tags = local.custom_cloud_guard_target_freeform_tags != null ? merge(local.custom_cloud_guard_target_freeform_tags, local.default_cloud_guard_target_freeform_tags) : local.default_cloud_guard_target_freeform_tags
}