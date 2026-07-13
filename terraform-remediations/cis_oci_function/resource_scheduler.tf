# Copyright (c) 2025, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_resource_scheduler_schedule" "cis_reports" {
  count = var.enable_resource_scheduler ? 1 : 0

  depends_on = [
    oci_functions_function.this,
    oci_identity_policy.this
  ]

  action             = "START_RESOURCE"
  compartment_id     = local.function_compartment_ocid
  recurrence_details = local.resource_scheduler_recurrence_details
  recurrence_type    = var.resource_scheduler_recurrence_type
  display_name       = var.resource_scheduler_display_name
  description        = var.resource_scheduler_description
  state              = var.resource_scheduler_state
  time_starts        = local.resource_scheduler_time_starts
  time_ends          = local.resource_scheduler_time_ends

  resources {
    id = oci_functions_function.this.id
  }
}
