/** 
 * ## CIS OCI Landing Zone Vulnerability Scanning Service (VSS) Module
 *
 * This module manages one single VSS recipe, and multiple VSS targets. 
 * The recipe is assigned to all provided targets.
 * var.vss_custom_recipes and var.vss_custom_targets, when provided, are added to Landing Zone default recipe and targets.
 */

# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.80.0"
    }
  }
}

locals {

  #-- Three variables below are to keep module backwards compatibility, as the "scan-target" suffix has been used 
  #-- as part of the key name to index the map variable for the creation of target resources.
  target_suffix = "scan-target"
  compat_vss_targets = {for k, v in var.vss_targets : "${k}-${local.target_suffix}" => v}
  compat_vss_target_names = [for t in var.vss_target_names : "${t}-${local.target_suffix}"]

  default_vss_recipe = {
    (var.vss_recipe_name) = {
      compartment_id  = var.compartment_id
      name            = var.vss_recipe_name
      port_scan_level = upper(var.vss_port_scan_level)
      # Valid values: STANDARD, LIGHT, NONE 
      # STANDARD checks the 1000 most common port numbers.
      # LIGHT checks the 100 most common port numbers.
      # NONE does not check for open ports.
      schedule_type        = upper(var.vss_scan_schedule)
      schedule_day_of_week = upper(var.vss_scan_day)
      agent_scan_level     = upper(var.vss_agent_scan_level)
      # Valid values: STANDARD, NONE
      # STANDARD enables agent-based scanning.
      # NONE disables agent-based scanning and moots all subsequent agent related attributes. 
      agent_configuration_vendor = "OCI"
      # Valid values: OCI
      agent_cis_benchmark_settings_scan_level = upper(var.vss_agent_cis_benchmark_settings_scan_level)
      # Valid values: STRICT, MEDIUM, LIGHTWEIGHT, NONE
      # STRICT: If more than 20% of the CIS benchmarks fail, then the target is assigned a risk level of Critical.
      # MEDIUM: If more than 40% of the CIS benchmarks fail, then the target is assigned a risk level of High. 
      # LIGHTWEIGHT: If more than 80% of the CIS benchmarks fail, then the target is assigned a risk level of High.
      # NONE: disables cis benchmark scanning.
      defined_tags = var.defined_tags
      freeform_tags = var.freeform_tags
    }
  }

  default_vss_targets = { for k, v in local.compat_vss_targets : k => {
    compartment_id = var.compartment_id
    name = "${v.target_compartment_name}-${local.target_suffix}"
    description = "CIS Landing Zone ${v.target_compartment_name} compartment scanning target."
    scan_recipe_name = var.vss_recipe_name
    target_compartment_id = v.target_compartment_id
    defined_tags = var.defined_tags
    freeform_tags = var.freeform_tags
  } }

  #-- Supported file scan recurrences by VSS: BI-WEEKLY, MONTHLY
  #-- If overall scan schedule is WEEKLY, file scan uses the same scan day. If overall scan sechdule is DAILY, we set file scan day to Sundays (WKST=SU).
  #-- RFC 5545
  file_scan_recurrence = upper(var.vss_scan_schedule) == "WEEKLY" ? "FREQ=WEEKLY;INTERVAL=2;WKST=${substr(upper(var.vss_scan_day),0,2)}" : "FREQ=WEEKLY;INTERVAL=2;WKST=SU"

  lz_recipe_key_map = {
    "LZ-RECIPE" : var.vss_recipe_name
  }

}

#---------------------------------------------------------------------------------------
#-- Default recipes resources.
#---------------------------------------------------------------------------------------
resource "oci_vulnerability_scanning_host_scan_recipe" "these" {
  provider = oci
  lifecycle {
      create_before_destroy = true
  }  
  for_each = local.default_vss_recipe
    compartment_id = each.value.compartment_id
    display_name = each.value.name 
    #Required
    port_settings {
      scan_level = each.value.port_scan_level
    }
    #Required
    schedule {
      #Required
      type = each.value.schedule_type
      #Optional
      day_of_week = each.value.schedule_day_of_week
    } 
    #Required
    agent_settings {
      #Required
      scan_level = each.value.agent_scan_level
      #Optional
      agent_configuration {
        vendor = each.value.agent_configuration_vendor
        cis_benchmark_settings {
          scan_level = each.value.agent_scan_level != "NONE" ? each.value.agent_cis_benchmark_settings_scan_level : "NONE"
        }
      }
    }
    #Optional
    application_settings {
      #Required
      application_scan_recurrence = local.file_scan_recurrence
      folders_to_scan {
        folder = join(";",var.vss_folders_to_scan)
        operatingsystem = "LINUX"
      }
      is_enabled = var.vss_enable_file_scan
    }
    #Optional
    defined_tags = each.value.defined_tags
    freeform_tags = each.value.freeform_tags
}

#---------------------------------------------------------------------------------------
#-- Default targets resources.
#-- We could have looped through local.scan_targets directly, but terraform plan
#-- errors out with the following message:
#-- "local.scan_targets is a map of object, known only after apply
#-- The "for_each" value depends on resource attributes that cannot be determined
#-- until apply, so Terraform cannot predict how many instances will be created.
#-- To work around this, use the -target argument to first apply only the
#-- resources that the for_each depends on."
#-- This happens because compartment ids that are managed by terraform are part of
#-- local.scan_targets and these values are not know until apply. Terraform needs
#-- to know these values during the plan phase.
#-- Hence the approach of looping through a list of target names (var.scan_target_names) 
#-- that MUST contain the same keys used by local.scan_targets. 
#-- Internal issue reference: 181.
#---------------------------------------------------------------------------------------
resource "oci_vulnerability_scanning_host_scan_target" "these" {
  provider = oci
  for_each = toset(local.compat_vss_target_names)
    compartment_id        = local.default_vss_targets[each.key].compartment_id
    display_name          = local.default_vss_targets[each.key].name
    description           = local.default_vss_targets[each.key].description
    host_scan_recipe_id   = oci_vulnerability_scanning_host_scan_recipe.these[var.vss_recipe_name].id
    target_compartment_id = local.default_vss_targets[each.key].target_compartment_id
    defined_tags          = local.default_vss_targets[each.key].defined_tags
    freeform_tags         = local.default_vss_targets[each.key].freeform_tags
 }

#-----------------------------------------------------------------------------
#-- Custom recipes resources
#----------------------------------------------------------------------------- 
resource "oci_vulnerability_scanning_host_scan_recipe" "custom" {
  provider = oci
  lifecycle {
    create_before_destroy = true
  }  
  for_each = var.vss_custom_recipes
    compartment_id = each.value.compartment_id
    display_name = each.value.name
    port_settings {
      scan_level = each.value.port_scan_level
    }
    schedule {
      type = each.value.schedule_type
      day_of_week = each.value.schedule_day_of_week
    } 
    agent_settings {
      scan_level = each.value.agent_scan_level
      agent_configuration {
        vendor = each.value.agent_configuration_vendor
        cis_benchmark_settings {
          scan_level = each.value.agent_cis_benchmark_settings_scan_level
        }
      }
    }
    application_settings {
      application_scan_recurrence = each.value.file_scan_recurrence
      folders_to_scan {
        folder = join(";",each.value.folders_to_scan)
        operatingsystem = each.value.folders_to_scan_os
      }
      is_enabled = each.value.enable_file_scan
    }
    defined_tags = each.value.defined_tags
    freeform_tags = each.value.freeform_tags
}

#-----------------------------------------------------------------------------
#-- Custom targets resources.
#-----------------------------------------------------------------------------
resource "oci_vulnerability_scanning_host_scan_target" "custom" {
  provider = oci
  for_each = var.vss_custom_targets
    compartment_id        = each.value.compartment_id
    display_name          = each.value.name
    description           = each.value.description
    host_scan_recipe_id   = upper(each.value.recipe_key) == "LZ-RECIPE" ? oci_vulnerability_scanning_host_scan_recipe.these[local.lz_recipe_key_map[upper(each.value.recipe_key)]].id : oci_vulnerability_scanning_host_scan_recipe.custom[each.value.recipe_key].id
    target_compartment_id = each.value.target_compartment_id
    defined_tags          = each.value.defined_tags
    freeform_tags         = each.value.freeform_tags
}

