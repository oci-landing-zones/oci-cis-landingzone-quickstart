# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### Creates Scanning recipes and targets. All Landing Zone compartments are potential targets.

locals {
  all_scan_recipes = {}
  all_scan_targets = {}

  all_vss_defined_tags = {}
  all_vss_freeform_tags = {}

  # Names
  scan_default_recipe_name = "${var.service_label}-default-scan-recipe"
  security_cmp_target_name = "${local.security_compartment.key}-scan-target"
  network_cmp_target_name  = "${local.network_compartment.key}-scan-target"
  appdev_cmp_target_name   = "${local.appdev_compartment.key}-scan-target"
  database_cmp_target_name = "${local.database_compartment.key}-scan-target"
  exainfra_cmp_target_name = "${local.exainfra_compartment.key}-scan-target"
  
  default_scan_recipes = var.vss_create == true ? {
    (local.scan_default_recipe_name) = {
      compartment_id  = local.security_compartment_id #module.lz_compartments.compartments[local.security_compartment.key].id
      port_scan_level = "STANDARD"
      # Valid values: STANDARD, LIGHT, NONE 
      # STANDARD checks the 1000 most common port numbers.
      # LIGHT checks the 100 most common port numbers.
      # NONE does not check for open ports.
      schedule_type        = upper(var.vss_scan_schedule)
      schedule_day_of_week = upper(var.vss_scan_day)
      agent_scan_level     = "STANDARD"
      # Valid values: STANDARD, NONE
      # STANDARD enables agent-based scanning.
      # NONE disables agent-based scanning and moots all subsequent agent related attributes. 
      agent_configuration_vendor = "OCI"
      # Valid values: OCI
      agent_cis_benchmark_settings_scan_level = "MEDIUM"
      # Valid values: STRICT, MEDIUM, LIGHTWEIGHT, NONE
      # STRICT: If more than 20% of the CIS benchmarks fail, then the target is assigned a risk level of Critical.
      # MEDIUM: If more than 40% of the CIS benchmarks fail, then the target is assigned a risk level of High. 
      # LIGHTWEIGHT: If more than 80% of the CIS benchmarks fail, then the target is assigned a risk level of High.
      # NONE: disables cis benchmark scanning.
      defined_tags = local.vss_defined_tags
      freeform_tags = local.vss_freeform_tags
    }
  } : {}

  default_scan_targets = var.vss_create == true ? {
    (local.security_cmp_target_name) = {
      compartment_id        = local.security_compartment_id #module.lz_compartments.compartments[local.security_compartment.key].id
      description           = "Landing Zone ${local.security_compartment.name} compartment scanning target."
      scan_recipe_name      = local.scan_default_recipe_name
      target_compartment_id = local.security_compartment_id #module.lz_compartments.compartments[local.security_compartment.key].id
      defined_tags          = local.vss_defined_tags
      freeform_tags         = local.vss_freeform_tags
    },
    (local.network_cmp_target_name) = {
      compartment_id        = local.security_compartment_id #module.lz_compartments.compartments[local.security_compartment.key].id
      description           = "Landing Zone ${local.network_compartment.name} compartment scanning target."
      scan_recipe_name      = local.scan_default_recipe_name
      target_compartment_id = local.network_compartment_id #module.lz_compartments.compartments[local.network_compartment.key].id
      defined_tags          = local.vss_defined_tags
      freeform_tags         = local.vss_freeform_tags
    },
    (local.appdev_cmp_target_name) = {
      compartment_id        = local.security_compartment_id #module.lz_compartments.compartments[local.security_compartment.key].id
      description           = "Landing Zone ${local.appdev_compartment.name} compartment scanning target."
      scan_recipe_name      = local.scan_default_recipe_name
      target_compartment_id = local.appdev_compartment_id #module.lz_compartments.compartments[local.appdev_compartment.key].id
      defined_tags          = local.vss_defined_tags
      freeform_tags         = local.vss_freeform_tags
    },
    (local.database_cmp_target_name) = {
      compartment_id        = local.security_compartment_id #module.lz_compartments.compartments[local.security_compartment.key].id
      description           = "Landing Zone ${local.database_compartment.name} compartment scanning target."
      scan_recipe_name      = local.scan_default_recipe_name
      target_compartment_id = local.database_compartment_id #module.lz_compartments.compartments[local.database_compartment.key].id
      defined_tags          = local.vss_defined_tags
      freeform_tags         = local.vss_freeform_tags
    }
  } : {}

  exainfra_scan_target = var.vss_create == true && length(data.oci_identity_compartments.exainfra.compartments) > 0 ? {
    (local.exainfra_cmp_target_name) = {
      compartment_id        = local.security_compartment_id
      description           = "Landing Zone ${local.exainfra_compartment.name} compartment scanning target."
      scan_recipe_name      = local.scan_default_recipe_name
      target_compartment_id = local.exainfra_compartment_id
      defined_tags          = local.vss_defined_tags
      freeform_tags         = local.vss_freeform_tags
    } 
  } : {}  

  scan_targets = merge(local.default_scan_targets, local.exainfra_scan_target)

  ### DON'T TOUCH THESE ###
  default_vss_defined_tags = null
  default_vss_freeform_tags = local.landing_zone_tags
  
  vss_defined_tags = length(local.all_vss_defined_tags) > 0 ? local.all_vss_defined_tags : local.default_vss_defined_tags
  vss_freeform_tags = length(local.all_vss_freeform_tags) > 0 ? merge(local.all_vss_freeform_tags, local.default_vss_freeform_tags) : local.default_vss_freeform_tags

}

module "lz_scanning" {
  source     = "../modules/security/vss"
  depends_on = [null_resource.wait_on_services_policy]
  scan_recipes = length(local.all_scan_recipes) > 0 ? local.all_scan_recipes :  local.default_scan_recipes
  scan_targets = length(local.all_scan_targets) > 0 ? local.all_scan_targets : local.scan_targets
  # VSS is a regional service. As such, we must not skip provisioning when extending Landing Zone to a new region.
}