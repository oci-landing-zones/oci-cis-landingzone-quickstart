# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### Creates Scanning recipes and targets. All Landing Zone compartments are potential targets.
module "cis_scanning" {
    source       = "../modules/security/vss"
    scan_recipes = var.vss_create == true ? {
        (local.scan_default_recipe_name) = {
            compartment_id = module.cis_compartments.compartments[local.security_compartment_name].id
            port_scan_level = "STANDARD" 
            # Valid values: STANDARD, LIGHT, NONE 
            # STANDARD checks the 1000 most common port numbers.
            # LIGHT checks the 100 most common port numbers.
            # NONE does not check for open ports.
            schedule_type = upper(var.vss_scan_schedule)
            schedule_day_of_week = upper(var.vss_scan_day)
            agent_scan_level = "STANDARD"
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
            compartment_id = module.cis_compartments.compartments[local.security_compartment_name].id 
            description = "${local.security_compartment_name} compartment Scanning target."
            scan_recipe_name = local.scan_default_recipe_name
            target_compartment_id = module.cis_compartments.compartments[local.security_compartment_name].id
            defined_tags = null
        },
        (local.network_cmp_target_name) = {
            compartment_id = module.cis_compartments.compartments[local.security_compartment_name].id 
            description = "${local.network_compartment_name} compartment Scanning target."
            scan_recipe_name = local.scan_default_recipe_name
            target_compartment_id = module.cis_compartments.compartments[local.network_compartment_name].id
            defined_tags = null
        },
        (local.appdev_cmp_target_name) = {
            compartment_id = module.cis_compartments.compartments[local.security_compartment_name].id 
            description = "${local.appdev_compartment_name} compartment Scanning target."
            scan_recipe_name = local.scan_default_recipe_name
            target_compartment_id = module.cis_compartments.compartments[local.appdev_compartment_name].id
            defined_tags = null
        },
        (local.database_cmp_target_name) = {
            compartment_id = module.cis_compartments.compartments[local.security_compartment_name].id 
            description = "${local.database_compartment_name} compartment Scanning target."
            scan_recipe_name = local.scan_default_recipe_name
            target_compartment_id = module.cis_compartments.compartments[local.database_compartment_name].id
            defined_tags = null
        }
    } : {}
}