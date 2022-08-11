# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

locals {

  #-- Three variables below are to keep module backwards compatibility, as the "scan-target" suffix has been used 
  #-- as part of the key name to index the map variable for the creation of target resources.
  target_suffix = "scan-target"
  compat_scan_targets = {for k, v in var.vss_targets : "${k}-${local.target_suffix}" => v}
  compat_scan_target_names = [for t in var.vss_target_names : "${t}-${local.target_suffix}"]

  default_recipe_name = "default-scan-recipe"
  recipe_name = var.vss_recipe_name != null ? var.vss_recipe_name : (var.name_prefix != null ? "${var.name_prefix}-${local.default_recipe_name}" : local.default_recipe_name)

  scan_recipes = {
    (local.recipe_name) = {
      compartment_id  = var.compartment_id
      name            = local.recipe_name
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
      defined_tags = var.defined_tags
      freeform_tags = var.freeform_tags
    }
  }

  scan_targets = { for k, v in local.compat_scan_targets : k => {
    compartment_id = var.compartment_id
    name = "${v.target_compartment_name}-${local.target_suffix}"
    description = "CIS Landing Zone ${v.target_compartment_name} compartment scanning target."
    scan_recipe_name = local.recipe_name
    target_compartment_id = v.target_compartment_id
    defined_tags = var.defined_tags
    freeform_tags = var.freeform_tags
  } }

  #-- VSS policy variables
  default_policy_name = "vss-policy"
  policy_name = var.vss_policy_name != null ? var.vss_policy_name : (var.name_prefix != null ? "${var.name_prefix}-${local.default_policy_name}" : local.default_policy_name)
  vss_grants = [
    "allow service vulnerability-scanning-service to manage instances in tenancy",
    "allow service vulnerability-scanning-service to read compartments in tenancy",
    "allow service vulnerability-scanning-service to read repos in tenancy",
    "allow service vulnerability-scanning-service to read vnics in tenancy",
    "allow service vulnerability-scanning-service to read vnic-attachments in tenancy"
  ]

  #-- Map used to retrieve the actual index for Landing Zone default recipe. 
  #-- Used when overriding VSS targets.
  lz_recipe_key_map = {
    "LZ-RECIPE" : local.recipe_name
  }

}

#---------------------------------------------------------------------------------------
#-- Default recipes resources.
#---------------------------------------------------------------------------------------
resource "oci_vulnerability_scanning_host_scan_recipe" "these" {
  lifecycle {
      create_before_destroy = true
  }  
  for_each = var.vss_create ? local.scan_recipes : {}
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
                scan_level = each.value.agent_cis_benchmark_settings_scan_level
            }
        }
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
  for_each = var.vss_create ? (length(var.vss_custom_targets) == 0 ? toset(local.compat_scan_target_names) : toset([])) : toset([])
    compartment_id        = local.scan_targets[each.key].compartment_id
    display_name          = local.scan_targets[each.key].name
    description           = local.scan_targets[each.key].description
    host_scan_recipe_id   = oci_vulnerability_scanning_host_scan_recipe.these[local.recipe_name].id
    target_compartment_id = local.scan_targets[each.key].target_compartment_id
    defined_tags          = local.scan_targets[each.key].defined_tags
    freeform_tags         = local.scan_targets[each.key].freeform_tags
 }

  #----------------------------------------------------------------------------
  #-- VSS policy resource.
  #----------------------------------------------------------------------------
  resource "oci_identity_policy" "vss" {
    count = var.vss_create ? 1 : 0
      name           = local.policy_name
      description    = "CIS Landing Zone policy for VSS (Vulnerability Scanning Service)."
      compartment_id = var.tenancy_id
      statements     = local.vss_grants
      defined_tags   = var.defined_tags
      freeform_tags  = var.freeform_tags
}

 #-----------------------------------------------------------------------------
 #-- Custom recipes resources. They don't override the default recipe, 
 #-- as the default recipe can be referenced in custom targets.
 #----------------------------------------------------------------------------- 
 resource "oci_vulnerability_scanning_host_scan_recipe" "custom" {
  lifecycle {
      create_before_destroy = true
  }  
  for_each = var.vss_create ? var.vss_custom_recipes : {}
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
                scan_level = each.value.agent_cis_benchmark_settings_scan_level
            }
        }
    }
    #Optional
    defined_tags = each.value.defined_tags
    freeform_tags = each.value.freeform_tags
}

 #-----------------------------------------------------------------------------
 #-- Custom targets resources, overriding the default targets.
 #-----------------------------------------------------------------------------
 resource "oci_vulnerability_scanning_host_scan_target" "custom" {
  for_each = var.vss_create ? var.vss_custom_targets : {}
    compartment_id        = each.value.compartment_id
    display_name          = each.value.name
    description           = each.value.description
    host_scan_recipe_id   = upper(substr(each.value.recipe_key,0,3)) == "LZ-" ? oci_vulnerability_scanning_host_scan_recipe.these[local.lz_recipe_key_map[upper(each.value.recipe_key)]].id : oci_vulnerability_scanning_host_scan_recipe.custom[each.value.recipe_key].id
    target_compartment_id = each.value.target_compartment_id
    defined_tags          = each.value.defined_tags
    freeform_tags         = each.value.freeform_tags
 }  