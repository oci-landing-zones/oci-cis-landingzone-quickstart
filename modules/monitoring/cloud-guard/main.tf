# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# CloudGuard enabling and disabling is a tenant-level operation 

data "oci_cloud_guard_detector_recipes" "compartment_detector_recipes" {
    depends_on = [ oci_cloud_guard_cloud_guard_configuration.this]
      #Required
      compartment_id = "ocid1.tenancy.oc1..aaaaaaaabkqehju37orqb2rs6qqtte4p4elzyfjtjkjdq5bkihntaegh2taa"
  }

resource "oci_cloud_guard_cloud_guard_configuration" "this" {
  #Required
  compartment_id        = var.compartment_id
  reporting_region      = var.reporting_region
  status                = var.status
  self_manage_resources = var.self_manage_resources
}

resource "oci_cloud_guard_target" "this" {
  depends_on = [ oci_cloud_guard_cloud_guard_configuration.this]
  compartment_id       = var.compartment_id
  display_name         = var.default_target.name
  target_resource_id   = var.default_target.id
  target_resource_type = var.default_target.type
    target_detector_recipes {
        detector_recipe_id = data.oci_cloud_guard_detector_recipes.compartment_detector_recipes.detector_recipe_collection[0].items[0].id
    }
    target_detector_recipes {
        detector_recipe_id = data.oci_cloud_guard_detector_recipes.compartment_detector_recipes.detector_recipe_collection[0].items[1].id
    }
}

