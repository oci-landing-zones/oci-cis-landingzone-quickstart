# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "enable_cloud_guard" {
  type        = bool
  description = "Whether Cloud Guard is to be enabled."
}

variable "tenancy_id" {
  type = string
  description = "The tenancy ocid, where Cloud Service is enabled."
}

variable "reporting_region" {
  type        = string
  description = "Cloud Guard reporting region."
}

variable "compartment_id" {
  type        = string
  description = "The compartment ocid where the Cloud Guard target and the cloned recipes are created."
}

variable "target_resource_id" {
  description = "Resource ocid that Cloud Guard monitors. If a compartment ocid is provided, Cloud Guard monitors the compartment and all its subcompartments."
  type        = string
}

variable "name_prefix" {
  description = "A string used as a prefix in the auto-generated resource names."
  type        = string
}

variable "self_manage_resources" {
  type        = bool
  description = "Whether Oracle managed resources are created by customers."
  default     = false
}

variable "target_resource_name" {
  description = "Cloud Guard target name. A provided value overrides the auto-generated name."
  type        = string
  default     = null
}

variable "target_resource_type" {
  description = "Resource types that Cloud Guard is able to monitor."
  type        = string
  default     = "COMPARTMENT"
  validation {
    condition = contains(["COMPARTMENT","FACLOUD"], var.target_resource_type)
    error_message = "Invalid target_resource_type. Valid values are COMPARTMENT or FACLOUD."
  }
}

variable "enable_cloned_recipes" {
  description = "Whether cloned recipes are created and attached to the designated target. Existing managed targets that use the Oracle-managed recipes will have all open problems moved to 'resolved' state. For more details, see https://docs.oracle.com/en-us/iaas/cloud-guard/using/problems-page.htm#problems-page__sect_prob_lifecycle."
  type = bool
  default = false
}

variable "configuration_detector_recipe_name" {
  description = "The cloned configuration detector recipe name. A provided value overrides the auto-generated name."
  type        = string
  default     = null
}

variable "activity_detector_recipe_name" {
  description = "The cloned activity detector recipe name. A provided value overrides the auto-generated name."
  type        = string
  default     = null
}

variable "threat_detector_recipe_name" {
  description = "The cloned threat detector recipe name. A provided value overrides the auto-generated name."
  type        = string
  default     = null
}

variable "responder_recipe_name" {
  description = "The cloned responder recipe name. A provided value overrides the auto-generated name."
  type        = string
  default     = null
}

variable "defined_tags" {
  type        = map(string)
  description = "Map of key-value pairs of defined tags for Cloud Guard managed resources."
  default     = null
}

variable "freeform_tags" {
  type        = map(string)
  description = "Map of key-value pairs of freeform tags for Cloud Guard managed resources."
  default     = null
}
