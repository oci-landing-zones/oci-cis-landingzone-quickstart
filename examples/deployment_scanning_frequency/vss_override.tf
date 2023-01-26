locals {
  #-------------------------------------------------------------------------------------
  #-- VSS overrides samples
  #-------------------------------------------------------------------------------------

  #-- VSS sample custom recipe
  custom_vss_recipes = {
    ("CUSTOM-RECIPE-1") = { # The key can be any string, but once defined it should not be changed.
      compartment_id       = local.security_compartment_id 
      name                 = "lz-custom-scan-recipe"
      port_scan_level      = "STANDARD"
      schedule_type        = "DAILY"
      schedule_day_of_week = "SATURDAY"
      agent_scan_level     = "STANDARD"
      agent_configuration_vendor = "OCI"
      agent_cis_benchmark_settings_scan_level = "STRICT"
      enable_file_scan = true
      file_scan_recurrence = "FREQ=MONTHLY;WKST=SU" #RFC 5545 - This sets the recurrence to once a month on the first Sunday after setting creation.
      folders_to_scan = ["/"]
      folders_to_scan_os = "LINUX"
      defined_tags = null
      freeform_tags = null
    }
  }

  #-- VSS sample custom targets
  custom_vss_targets = {
    ("LZ-ENCLOSING-CMP-TARGET") = { # The key can be any string, but once defined it should not be changed.
      compartment_id        = local.security_compartment_id
      name                  = "lz-enclosing-compartment-scan-target"
      description           = "CIS Landing Zone enclosing compartment target."
      recipe_key            = "CUSTOM-RECIPE-1" #-- This target uses the recipe indexed by CUSTOM_RECIPE-1 in all_scan_recipes above.
      target_compartment_id = local.enclosing_compartment_id
      defined_tags          = null
      freeform_tags         = null
    },
    ("ROOT-CMP-TARGET") = { # The key can be any string, but once defined it should not be changed.
      compartment_id        = local.security_compartment_id
      name                  = "lz-root-compartment-scan-target" 
      description           = "CIS Landing Zone Root compartment target."
      recipe_key            = "LZ-RECIPE" #-- This target uses Landing Zone default recipe. CIS Landing Zone VSS module recognizes the "LZ-RECIPE" string as its default recipe.
      target_compartment_id = var.tenancy_ocid
      defined_tags          = null
      freeform_tags         = null
    }
  }
} 
