# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_id" {
  description = "The tenancy ocid."
  type = string
}

variable "compartment_id" {
  description = "The compartment ocid where VSS recipes and targets are created."
  type = string
}

variable "vss_recipe_name" {
  description = "The recipe name. Use it to override the default one, that is either <name-prefix>-default-scan-recipe or default-scan-recipe."
  type = string
  default = "lz-scan-recipe"
}

variable "vss_scan_schedule" {
  description = "The scan schedule for the VSS recipe, if enabled. Valid values are WEEKLY or DAILY (case insensitive)."
  type = string
  default     = "WEEKLY"
  validation {
    condition     = contains(["WEEKLY", "DAILY"], upper(var.vss_scan_schedule))
    error_message = "Validation failed for vss_scan_schedule: valid values are WEEKLY or DAILY (case insensitive)."
  }
}

variable "vss_scan_day" {
  description = "The week day for the VSS recipe, if enabled. Only applies if vss_scan_schedule is WEEKLY (case insensitive)."
  type        = string
  default     = "SUNDAY"
  validation {
    condition     = contains(["SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"], upper(var.vss_scan_day))
    error_message = "Validation failed for vss_scan_day: valid values are SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY (case insensitive)."
  }
}

variable "vss_port_scan_level" {
  description = "Valid values: STANDARD, LIGHT, NONE. STANDARD checks the 1000 most common port numbers, LIGHT checks the 100 most common port numbers, NONE does not check for open ports."
  type = string
  default = "STANDARD"
  validation {
    condition     = contains(["STANDARD", "LIGHT", "NONE"], upper(var.vss_port_scan_level))
    error_message = "Validation failed for vss_port_scan_level: valid values are STANDARD, LIGHT, NONE (case insensitive)."
  }
}

variable "vss_agent_scan_level" {
  description = "Valid values: STANDARD, NONE. STANDARD enables agent-based scanning. NONE disables agent-based scanning and moots any agent related attributes."
  type = string
  default = "STANDARD"
  validation {
    condition     = contains(["STANDARD", "NONE"], upper(var.vss_agent_scan_level))
    error_message = "Validation failed for vss_agent_scan_level: valid values are STANDARD, NONE (case insensitive)."
  }
}

variable "vss_agent_cis_benchmark_settings_scan_level" {
  description = "Valid values: STRICT, MEDIUM, LIGHTWEIGHT, NONE. STRICT: If more than 20% of the CIS benchmarks fail, then the target is assigned a risk level of Critical. MEDIUM: If more than 40% of the CIS benchmarks fail, then the target is assigned a risk level of High. LIGHTWEIGHT: If more than 80% of the CIS benchmarks fail, then the target is assigned a risk level of High. NONE: disables cis benchmark scanning."
  type = string
  default = "MEDIUM"
  validation {
    condition     = contains(["STRICT", "MEDIUM", "LIGHTWEIGHT", "NONE"], upper(var.vss_agent_cis_benchmark_settings_scan_level))
    error_message = "Validation failed for vss_agent_cis_benchmark_settings_scan_level: valid values are STRICT, MEDIUM, LIGHTWEIGHT, NONE (case insensitive)."
  }
}

variable "vss_target_names" {
  description = "A list with the VSS target names."
  type = list(string)
}

variable "vss_targets" {
  description = "The VSS targets. The map indexes MUST match the values in vss_target_names."
  type = map(object({
    target_compartment_id = string
    target_compartment_name = string
  }))
}

variable "defined_tags" {
  description = "Any defined tags to apply on the VSS resources." 
  type = map(string)
  default = null
}

variable "freeform_tags" {
  description = "Any freeform tags to apply on the VSS resources."
  type = map(string)
  default = null
}

variable "vss_enable_file_scan" {
  description = "Whether file scanning is enabled."
  type = bool
  default = false
}

variable "vss_folders_to_scan" {
  description = "A list of folders to scan. Only applies if vss_enable_folder_scan is true."
  type = list(string)
  default = []
}

variable "vss_custom_recipes" {
  description = "VSS custom recipes. Use it to override the default recipe."
  type = map(object({
    compartment_id                          = string,
    name                                    = string,
    agent_scan_level                        = string,
    agent_configuration_vendor              = string,
    agent_cis_benchmark_settings_scan_level = string,
    port_scan_level                         = string,
    schedule_type                           = string,
    schedule_day_of_week                    = string,
    enable_file_scan                        = bool,
    file_scan_recurrence                    = string,
    folders_to_scan                         = list(string),
    folders_to_scan_os                      = string,
    defined_tags                            = map(string),
    freeform_tags                           = map(string)
  }))
  default = {}
}

variable "vss_custom_targets" {
  description = "VSS custom targets. Use it to override the default targets. For recipe_key, pass the corresponding key in vss_custom_recipes."
  type = map(object({
    compartment_id        = string,
    name                  = string,
    description           = string,
    recipe_key            = string,
    target_compartment_id = string,
    defined_tags          = map(string),
    freeform_tags         = map(string)
  }))
  default = {}
}

