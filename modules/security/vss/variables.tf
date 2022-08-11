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

variable "name_prefix" {
  description = "A prefix used when naming resources created by this module."
  type = string
  default = null
}

variable "vss_create" {
  description = "Whether or not VSS resources (recipes, targets and policies) are to be created."
  type = bool
  default = true
}

variable "vss_recipe_name" {
  description = "The recipe name. Use it to override the default one, that is either <name-prefix>-default-scan-recipe or default-scan-recipe."
  type = string
  default = null
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

variable "vss_policy_name" {
  description = "The VSS policy name. Use it to override the default policy name, which is either <name-prefix>-vss-policy or vss-policy."
  type = string
  default = null
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