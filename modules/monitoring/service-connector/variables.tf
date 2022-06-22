# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "service_connector" {
    description = "Details of the Service Connector to be created"
    type = object ({
        compartment_id  = string,
	defined_tags = map(string),
	freeform_tags = map(string),
        service_connector_display_name = string,
        service_connector_source_kind  = string,
        service_connector_state = string,
        log_sources = list(object({
            compartment_id = string,
            log_group_id   = string,
            log_id         = string
        })),
        target = object({
            target_kind             = string,
            compartment_id             = string,
            object_store_details = object({
                namespace = string,
                bucket_name = string,
                object_name_prefix = string,
                batch_rollover_size_in_mbs = number,
                batch_rollover_time_in_ms  = number
            }),
            stream_id = string,
            function_id = string
        })
    })
}
