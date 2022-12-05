# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  default_configuration_detector_recipe_name = "configuration-detector-recipe"
  configuration_detector_recipe_name = var.configuration_detector_recipe_name != null ? var.configuration_detector_recipe_name : "${var.name_prefix}-${local.default_configuration_detector_recipe_name}"

  default_activity_detector_recipe_name = "activity-detector-recipe"
  activity_detector_recipe_name = var.activity_detector_recipe_name != null ? var.activity_detector_recipe_name : "${var.name_prefix}-${local.default_activity_detector_recipe_name}"

  default_threat_detector_recipe_name = "threat-detector-recipe"
  threat_detector_recipe_name = var.threat_detector_recipe_name != null ? var.threat_detector_recipe_name : "${var.name_prefix}-${local.default_threat_detector_recipe_name}"

  default_responder_recipe_name = "responder-recipe"
  responder_recipe_name = var.responder_recipe_name != null ? var.responder_recipe_name : "${var.name_prefix}-${local.default_responder_recipe_name}"

  default_target_resource_name = var.tenancy_id == var.target_resource_id ? "cloud-guard-root-target" : "cloud-guard-target"
  target_resource_name = var.target_resource_name != null ? var.target_resource_name : "${var.name_prefix}-${local.default_target_resource_name}"
}

resource "oci_cloud_guard_cloud_guard_configuration" "this" {
  compartment_id        = var.tenancy_id
  reporting_region      = var.reporting_region
  status                = var.enable_cloud_guard ? "ENABLED" : "DISABLED"
  self_manage_resources = var.self_manage_resources
}

resource "oci_cloud_guard_detector_recipe" "configuration_cloned" {
  count          = var.enable_cloned_recipes && oci_cloud_guard_cloud_guard_configuration.this.status == "ENABLED" ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = local.configuration_detector_recipe_name
  description    = "CIS Landing Zone configuration detector recipe (cloned from Oracle managed recipe)"
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
  source_detector_recipe_id = data.oci_cloud_guard_detector_recipes.configuration.detector_recipe_collection[0].items[0].id
}

resource "oci_cloud_guard_detector_recipe" "activity_cloned" {
  count          = var.enable_cloned_recipes && oci_cloud_guard_cloud_guard_configuration.this.status == "ENABLED" ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = local.activity_detector_recipe_name
  description    = "CIS Landing Zone activity detector recipe (cloned from Oracle managed recipe)"
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
  source_detector_recipe_id = data.oci_cloud_guard_detector_recipes.activity.detector_recipe_collection[0].items[0].id
}

resource "oci_cloud_guard_detector_recipe" "threat_cloned" {
  count          = var.enable_cloned_recipes && oci_cloud_guard_cloud_guard_configuration.this.status == "ENABLED" ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = local.threat_detector_recipe_name
  description    = "CIS Landing Zone threat detector recipe (cloned from Oracle managed recipe)"
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
  source_detector_recipe_id = data.oci_cloud_guard_detector_recipes.threat.detector_recipe_collection[0].items[0].id
}

resource "oci_cloud_guard_responder_recipe" "responder_cloned" {
  count          = var.enable_cloned_recipes && oci_cloud_guard_cloud_guard_configuration.this.status == "ENABLED" ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = local.responder_recipe_name
  description    = "CIS Landing Zone responder recipe (cloned from Oracle managed recipe)"
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
  source_responder_recipe_id = data.oci_cloud_guard_responder_recipes.responder.responder_recipe_collection[0].items[0].id
}

resource "oci_cloud_guard_target" "this" {
  count                = oci_cloud_guard_cloud_guard_configuration.this.status == "ENABLED" ? 1 : 0
  compartment_id       = var.compartment_id
  display_name         = local.target_resource_name
  target_resource_id   = var.target_resource_id
  target_resource_type = var.target_resource_type
  defined_tags         = var.defined_tags
  freeform_tags        = var.freeform_tags
  target_detector_recipes {
    detector_recipe_id = var.enable_cloned_recipes ? oci_cloud_guard_detector_recipe.threat_cloned[0].id : data.oci_cloud_guard_detector_recipes.threat.detector_recipe_collection[0].items[0].id
  }
  target_detector_recipes {
    detector_recipe_id = var.enable_cloned_recipes ? oci_cloud_guard_detector_recipe.configuration_cloned[0].id : data.oci_cloud_guard_detector_recipes.configuration.detector_recipe_collection[0].items[0].id
  }
  target_detector_recipes {
    detector_recipe_id = var.enable_cloned_recipes ? oci_cloud_guard_detector_recipe.activity_cloned[0].id : data.oci_cloud_guard_detector_recipes.activity.detector_recipe_collection[0].items[0].id
  }
  target_responder_recipes {
    responder_recipe_id = var.enable_cloned_recipes ? oci_cloud_guard_responder_recipe.responder_cloned[0].id : data.oci_cloud_guard_responder_recipes.responder.responder_recipe_collection[0].items[0].id
  }
}
