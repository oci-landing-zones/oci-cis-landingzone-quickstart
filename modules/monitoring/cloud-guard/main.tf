# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# CloudGuard enabling and disabling is a tenant-level operation 
resource "oci_cloud_guard_cloud_guard_configuration" "this" {
  #Required
  compartment_id        = var.compartment_id
  reporting_region      = var.reporting_region
  status                = var.status
  self_manage_resources = var.self_manage_resources
}

resource "oci_cloud_guard_target" "this" {
  compartment_id       = var.compartment_id
  display_name         = var.default_target_name
  target_resource_id   = var.compartment_id
  target_resource_type = "COMPARTMENT"
}
