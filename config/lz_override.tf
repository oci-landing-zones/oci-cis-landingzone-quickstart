locals {
  #-------------------------------------------------------------------------------------
  #-- VSS overrides samples
  #-------------------------------------------------------------------------------------

  #-- VSS sample recipes
  all_scan_recipes = {
    ("CUSTOM-RECIPE-1") = {
      compartment_id       = local.security_compartment_id 
      name                 = "custom-recipe-1"
      port_scan_level      = "STANDARD"
      schedule_type        = "DAILY"
      schedule_day_of_week = "SATURDAY"
      agent_scan_level     = "STANDARD"
      agent_configuration_vendor = "OCI"
      agent_cis_benchmark_settings_scan_level = "STRICT"
      defined_tags = {}
      freeform_tags = {}
    }
  }

  #-- VSS sample targets
  all_scan_targets = {
    ("CUSTOM-TARGET-1") = {
      compartment_id        = local.security_compartment_id
      name                  = "vss-custom-target-1"
      description           = "Custom scanning target 1."
      recipe_key            = "CUSTOM-RECIPE-1" #-- This target uses the recipe indexed by CUSTOM_RECIPE-1 in all_scan_recipes above.
      target_compartment_id = local.enclosing_compartment_id
      defined_tags          = {}
      freeform_tags         = {}
    },
    ("CUSTOM-TARGET-2") = {
      compartment_id        = local.security_compartment_id
      name                  = "vss-custom-target-2" 
      description           = "Custom scanning target 2."
      recipe_key            = "LZ-RECIPE" #-- This target uses Landing Zone default recipe. CIS Landing Zone VSS module recognizes the "LZ-RECIPE" string as its default recipe.
      target_compartment_id = local.network_compartment_id
      defined_tags          = {}
      freeform_tags         = {}
    },
  }
}  