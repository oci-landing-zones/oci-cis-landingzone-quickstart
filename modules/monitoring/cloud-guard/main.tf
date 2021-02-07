# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# CloudGuard enabling and disabling is a tenant-level operation 
resource "oci_cloud_guard_cloud_guard_configuration" "this" {
  #Required
  compartment_id   = var.compartment_id
  reporting_region = var.reporting_region
  status           = var.status

  #Optional
  self_manage_resources = var.self_manage_resources
}
