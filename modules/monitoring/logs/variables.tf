# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartment_id" {
  type        = string
  default     = ""
}

variable "log_group_display_name" {
  type        = string
  default     = ""
}

variable "log_group_description" {
  type        = string
  default     = ""
}

variable "defined_tags" {
  type        = map(string)
  description = "Map of key-value pairs of defined tags. (Optional)"
  default     = null
}

variable "freeform_tags" {
  type        = map(string)
  description = "Map of key-value pairs of freeform tags. (Optional)"
  default     = null
}

variable "target_resources" {
    type = map(object({
        log_display_name              = string
        log_type                      = string
        log_config_source_resource    = string
        log_config_source_category    = string
        log_config_source_service     = string
        log_config_source_source_type = string
        log_config_compartment        = string
        log_is_enabled                = bool
        log_retention_duration        = number
        defined_tags                  = map(string)
        freeform_tags                 = map(string)
    }))
}
