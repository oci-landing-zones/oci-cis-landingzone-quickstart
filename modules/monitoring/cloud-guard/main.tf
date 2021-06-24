# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# CloudGuard enabling and disabling is a tenant-level operation 

data "oci_cloud_guard_detector_recipes" "compartment_detector_recipes" {
  depends_on = [ oci_cloud_guard_cloud_guard_configuration.this ]
  compartment_id = var.compartment_id
}

data "oci_cloud_guard_responder_recipes" "compartment_responder_recipes" {
  depends_on = [ oci_cloud_guard_cloud_guard_configuration.this ]
  compartment_id = var.compartment_id
}

resource "oci_cloud_guard_cloud_guard_configuration" "this" {
  #Required
  compartment_id        = var.compartment_id
  reporting_region      = var.reporting_region
  status                = var.status
  self_manage_resources = var.self_manage_resources
}

resource "oci_cloud_guard_target" "this" {
  depends_on = [ oci_cloud_guard_cloud_guard_configuration.this ]
  count = oci_cloud_guard_cloud_guard_configuration.this.status == "ENABLED" ? 1 : 0
  compartment_id       = var.compartment_id
  display_name         = var.default_target.name
  target_resource_id   = var.default_target.id
  target_resource_type = var.default_target.type
  dynamic "target_detector_recipes" {
    for_each = length(data.oci_cloud_guard_detector_recipes.compartment_detector_recipes.detector_recipe_collection) > 0 ? data.oci_cloud_guard_detector_recipes.compartment_detector_recipes.detector_recipe_collection[0].items : []
    iterator = recipe
    content {
      detector_recipe_id = recipe.value["id"]
    }  
  }
  dynamic "target_responder_recipes" {
    for_each = length(data.oci_cloud_guard_responder_recipes.compartment_responder_recipes.responder_recipe_collection) > 0 ? data.oci_cloud_guard_responder_recipes.compartment_responder_recipes.responder_recipe_collection[0].items : []
    iterator = recipe
    content {
      responder_recipe_id = recipe.value["id"]
    }  
  }
}

