# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### Creates Scanning recipes and targets. All Landing Zone compartments are potential targets.
module "lz_scanning" {
  source     = "../modules/security/vss"
  depends_on = [null_resource.slow_down_vss]
  scan_recipes = var.vss_create == true ? {
    (local.scan_default_recipe_name) = {
      compartment_id  = module.lz_compartments.compartments[local.security_compartment.key].id
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
      defined_tags = null
    }
  } : {}
  scan_targets = var.vss_create == true ? {
    (local.security_cmp_target_name) = {
      compartment_id        = module.lz_compartments.compartments[local.security_compartment.key].id
      description           = "Landing Zone ${local.security_compartment.name} compartment scanning target."
      scan_recipe_name      = local.scan_default_recipe_name
      target_compartment_id = module.lz_compartments.compartments[local.security_compartment.key].id
      defined_tags          = null
    },
    (local.network_cmp_target_name) = {
      compartment_id        = module.lz_compartments.compartments[local.security_compartment.key].id
      description           = "Landing Zone ${local.network_compartment.name} compartment scanning target."
      scan_recipe_name      = local.scan_default_recipe_name
      target_compartment_id = module.lz_compartments.compartments[local.network_compartment.key].id
      defined_tags          = null
    },
    (local.appdev_cmp_target_name) = {
      compartment_id        = module.lz_compartments.compartments[local.security_compartment.key].id
      description           = "Landing Zone ${local.appdev_compartment.name} compartment scanning target."
      scan_recipe_name      = local.scan_default_recipe_name
      target_compartment_id = module.lz_compartments.compartments[local.appdev_compartment.key].id
      defined_tags          = null
    },
    (local.database_cmp_target_name) = {
      compartment_id        = module.lz_compartments.compartments[local.security_compartment.key].id
      description           = "Landing Zone ${local.database_compartment.name} compartment scanning target."
      scan_recipe_name      = local.scan_default_recipe_name
      target_compartment_id = module.lz_compartments.compartments[local.database_compartment.key].id
      defined_tags          = null
    }
  } : {}
}

resource "null_resource" "slow_down_vss" {
  depends_on = [module.lz_services_policy]
  provisioner "local-exec" {
    command = "sleep ${local.delay_in_secs}" # Wait 30 seconds for policies to be available.
  }
}