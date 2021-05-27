# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_sch_service_connector" "this" {
    compartment_id = var.service_connector.compartment_id
    display_name   = var.service_connector.service_connector_display_name
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
        kind            = lower(var.service_connector.target.target_kind)
        compartment_id     = var.service_connector.target.compartment_id
        bucket             = var.service_connector.target.target_kind == "objectstorage" ? var.service_connector.target.object_store_details.bucket_name : null
        object_name_prefix = var.service_connector.target.target_kind == "objectstorage" ? var.service_connector.target.object_store_details.object_name_prefix : null
        namespace =  var.service_connector.target.target_kind == "objectstorage" ? var.service_connector.target.object_store_details.namespace : null
        stream_id          = var.service_connector.target.target_kind == "streaming" ? var.service_connector.target.stream_id : null
        function_id        = var.service_connector.target.target_kind == "functions" ? var.service_connector.target.function_id : null
    }
    state  = upper(var.service_connector.service_connector_state)
}