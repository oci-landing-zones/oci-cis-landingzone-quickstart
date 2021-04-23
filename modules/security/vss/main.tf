resource "oci_vulnerability_scanning_host_scan_recipe" "these" {
  lifecycle {
      create_before_destroy = true
  }  
  for_each = var.scan_recipes
    compartment_id = each.value.compartment_id
    display_name = each.key 
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
}

resource "oci_vulnerability_scanning_host_scan_target" "these" {
  for_each = var.scan_targets
    compartment_id        = each.value.compartment_id
    display_name          = each.key
    description           = each.value.description
    host_scan_recipe_id   = oci_vulnerability_scanning_host_scan_recipe.these[each.value.scan_recipe_name].id
    target_compartment_id = each.value.target_compartment_id
    defined_tags = each.value.defined_tags
    
    
 }