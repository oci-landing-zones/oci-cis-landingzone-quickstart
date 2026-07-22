# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_logging_log_group" "this" {
  count          = var.enable_function_logging ? 1 : 0
  compartment_id = local.function_compartment_ocid
  display_name   = "${local.function_name}-function-log-group"
  description    = "Function log group"
}

resource "oci_logging_log" "this" {
  depends_on   = [oci_functions_function.this]
  count        = var.enable_function_logging ? 1 : 0
  display_name = "${local.function_name}-function-log"
  log_group_id = oci_logging_log_group.this[0].id
  log_type     = "SERVICE"
  configuration {
    source {
      category    = "invoke"
      resource    = oci_functions_application.this.id
      service     = "functions"
      source_type = "OCISERVICE"
    }
    compartment_id = local.function_compartment_ocid
  }
  is_enabled         = true
  retention_duration = 30
}
