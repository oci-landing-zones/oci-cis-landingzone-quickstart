# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

resource "oci_sch_service_connector" "this" {
    compartment_id = var.service_connector.compartment_id
    display_name   = var.service_connector.service_connector_display_name
    defined_tags   = var.service_connector.defined_tags
    freeform_tags  = var.service_connector.freeform_tags
    source {
        kind = var.service_connector.service_connector_source_kind
        dynamic "log_sources" {
            for_each = var.service_connector.log_sources
            iterator = ls
            content {
                compartment_id = ls.value.compartment_id
                log_group_id = ls.value.log_group_id
                log_id       = ls.value.log_id
            }
        }
    }
    target {
        kind               = lower(var.service_connector.target.target_kind)
        compartment_id     = var.service_connector.target.compartment_id
        bucket             = lower(var.service_connector.target.target_kind) == "objectstorage" ? var.service_connector.target.object_store_details.bucket_name : null
        object_name_prefix = lower(var.service_connector.target.target_kind) == "objectstorage" ? var.service_connector.target.object_store_details.object_name_prefix : null
        namespace          =  lower(var.service_connector.target.target_kind) == "objectstorage" ? var.service_connector.target.object_store_details.namespace : null
        batch_rollover_size_in_mbs = lower(var.service_connector.target.target_kind) == "objectstorage" ? var.service_connector.target.object_store_details.batch_rollover_size_in_mbs : null
        batch_rollover_time_in_ms  = lower(var.service_connector.target.target_kind) == "objectstorage" ? var.service_connector.target.object_store_details.batch_rollover_time_in_ms : null
        stream_id          = lower(var.service_connector.target.target_kind) == "streaming" ? var.service_connector.target.stream_id : null
        function_id        = lower(var.service_connector.target.target_kind) == "functions" ? var.service_connector.target.function_id : null
    }
    state  = upper(var.service_connector.service_connector_state)
}
