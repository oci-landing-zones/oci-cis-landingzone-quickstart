# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

resource "oci_logging_log_group" "this" {
  compartment_id = var.compartment_id
  display_name   = var.log_group_display_name
  description    = var.log_group_description
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
}

resource "oci_logging_log" "these" {
  for_each = var.target_resources 
    display_name = each.value.log_display_name
    log_group_id = oci_logging_log_group.this.id
    log_type     = each.value.log_type
    configuration {
      source {
        category    = each.value.log_config_source_category
        resource    = each.value.log_config_source_resource
        service     = each.value.log_config_source_service
        source_type = each.value.log_config_source_source_type
      }
      compartment_id = each.value.log_config_compartment
    }
    is_enabled         = each.value.log_is_enabled
    retention_duration = each.value.log_retention_duration
    defined_tags       = each.value.defined_tags
    freeform_tags      = each.value.freeform_tags
}