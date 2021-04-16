variable "scan_recipes" {
  type = map(object({
    compartment_id                                = string,
    agent_scan_level                              = string,
    agent_configuration_vendor                    = string,
    agent_cis_benchmark_settings_scan_level       = string,
    port_scan_level                               = string,
    schedule_type                                 = string,
    schedule_day_of_week                          = string,
    defined_tags                                  = map(string)
  }))
}

variable "scan_targets" {
  type = map(object({
    compartment_id        = string,
    description           = string,
    scan_recipe_name      = string,
    target_compartment_id = string,
    defined_tags          = map(string)
  }))
}