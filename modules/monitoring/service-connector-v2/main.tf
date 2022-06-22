# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
    target_bucket_name = var.target_bucket_name != "service-connector-bucket" ? var.target_bucket_name : "${var.service_label}-${var.target_bucket_name}"

    target_stream_id = lower(var.target_kind) == "streaming" ? (length(regexall("^ocid1.streaming.oc.*$", var.target_stream)) > 0 ? var.target_stream : oci_streaming_stream.sch[0].id) : null
    target_stream_name = var.target_stream != "service-connector-stream" ? var.target_stream : "${var.service_label}-${var.target_stream}"

    policy_compartment_id = var.policy_compartment_id != null ? var.policy_compartment_id : data.oci_identity_compartment.this.compartment_id
}

resource "oci_sch_service_connector" "logging" {
    compartment_id = var.compartment_id
    display_name   = var.display_name != "service-connector" ? var.display_name : "${var.service_label}-${var.display_name}"
    defined_tags   = var.defined_tags
    freeform_tags  = var.freeform_tags
    source {
        kind = "logging"
        dynamic "log_sources" {
        for_each = var.logs_sources
            iterator = ls
            content {
                compartment_id = ls.value.compartment_id
                log_group_id = ls.value.log_group_id
                log_id       = ls.value.log_id
            }
        }
    }
    target {
        kind               = lower(var.target_kind)
        compartment_id     = var.target_compartment_id
        bucket             = lower(var.target_kind) == "objectstorage" ? local.target_bucket_name : null
        object_name_prefix = lower(var.target_kind) == "objectstorage" ? var.target_object_name_prefix : null
        namespace          = lower(var.target_kind) == "objectstorage" ? data.oci_objectstorage_namespace.this.namespace : null
        batch_rollover_size_in_mbs = lower(var.target_kind) == "objectstorage" ? var.target_object_store_batch_rollover_size_in_mbs : null
        batch_rollover_time_in_ms  = lower(var.target_kind) == "objectstorage" ? var.target_object_store_batch_rollover_time_in_ms : null

        stream_id          = lower(var.target_kind) == "streaming" ? local.target_stream_id : null
        function_id        = lower(var.target_kind) == "functions" ? var.target_function_id : null
    }
    state  = var.enable_service_connector ? "ACTIVE" : "INACTIVE"
}

resource "oci_objectstorage_bucket" "sch" {
    count          = lower(var.target_kind) == "objectstorage" ? 1 : 0
    compartment_id = var.compartment_id
    name           = local.target_bucket_name
    namespace      = data.oci_objectstorage_namespace.this.namespace 
    kms_key_id     = var.target_bucket_kms_key_id
    versioning     =  "Enabled" 
	defined_tags   = var.target_bucket_defined_tags
	freeform_tags  = var.target_bucket_freeform_tags
}

resource "oci_identity_policy" "sch_oss" {
    count          = lower(var.target_kind) == "objectstorage" ? 1 : 0
    name           = var.target_policy_name != "service-connector-target-policy" ? var.target_policy_name : "${var.service_label}-${var.target_policy_name}"
    description    = "CIS Landing Zone policy for Service Connector Hub to manage objects in the target bucket."
    compartment_id = local.policy_compartment_id
    statements     = [
                    <<EOF
                        Allow any-user to manage objects in compartment id ${var.compartment_id} where all {
                        request.principal.type='serviceconnector',
                        target.bucket.name= '${var.target_bucket_name}',
                        request.principal.compartment.id='${var.compartment_id}' }
                    EOF
                ]
    defined_tags   = var.target_stream_defined_tags
	freeform_tags  = var.target_stream_freeform_tags
}

resource "oci_streaming_stream" "sch" {
    count = lower(var.target_kind) == "streaming" ? (length(regexall("^ocid1.streaming.oc.*$", var.target_stream)) > 0 ? 0 : 1) : 0
    name = local.target_stream_name
    partitions = var.target_stream_partitions
    compartment_id = var.compartment_id
    defined_tags = null
    freeform_tags = null
    retention_in_hours = var.target_stream_retention_in_hours
}

resource "oci_identity_policy" "sch_streaming" {
    count          = lower(var.target_kind) == "streaming" ? 1 : 0
    name           = var.target_policy_name != "service-connector-target-policy" ? var.target_policy_name : "${var.service_label}-${var.target_policy_name}"
    description    = "CIS Landing Zone policy for Service Connector Hub to use the target stream."
    compartment_id = local.policy_compartment_id
    statements = [
                    <<EOF
                        Allow any-user to use stream-push in compartment id ${var.compartment_id} where all {
                        request.principal.type='serviceconnector',
                        target.stream.id='${local.target_stream_id}',
                        request.principal.compartment.id='${var.compartment_id}' }
                    EOF
                ]
    defined_tags   = var.policy_defined_tags
    freeform_tags  = var.policy_freeform_tags
}

resource "oci_identity_policy" "sch_function" {
    count          = lower(var.target_kind) == "functions" ? 1 : 0
    name           = var.target_policy_name != "service-connector-target-policy" ? var.target_policy_name : "${var.service_label}-${var.target_policy_name}"
    description    = "CIS Landing Zone policy for Service Connector Hub to use the target function."
    compartment_id = local.policy_compartment_id
    statements = [
                    <<EOF
                        Allow any-user to use fn-function in compartment id ${var.compartment_id} where all {
                        request.principal.type='serviceconnector',     
                        request.principal.compartment.id='${var.compartment_id}'}
                    EOF
                    ,
                    <<EOF2
                        Allow any-user to use fn-invocation in compartment id ${var.compartment_id} where all {
                        request.principal.type='serviceconnector',     
                        request.principal.compartment.id='${var.compartment_id}' }
                    EOF2
                ]
    defined_tags   = var.policy_defined_tags
    freeform_tags  = var.policy_freeform_tags
}