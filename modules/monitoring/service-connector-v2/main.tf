/**
 * ## CIS Landing Zone Service Connector Hub (SCH) Module.
 *
 * This module manages OCI SCH resources per CIS OCI Benchmark. 
 * It manages a single Service Connector for all log sources provided in log_sources variable and a designated target provided in target_kind variable.
 * If target_kind is 'objectstorage', an Object Storage bucket is created. The bucket is encrypted with either an Oracle managed key or customer managed key.
 * For target_kind is 'objectstorage', if cis_level = 1 and var.target_bucket_kms_key_id is not provided, the bucket is encrypted with an Oracle managed key.
 * If cis_level = 2 and var.target_bucket_kms_key_id is not provided, the module produces an error. Write logs are enabled for the bucket only if cis_level = 2.
 * If target kind is 'streaming, a Stream is either created or used, depending on what is provided in the target_stream variable. If a name is provided,
 * a stream is created. If an OCID is provided, the stream is used.
 * If target_kind is 'functions', a function OCID must be provided in target_function_id variable.
 * If target_kind is 'logginganalytics', aa log group for Logging Analytics service is created, named by target_log_group_name variable. Logging Analytics service is enabled if not already.
 * The target resource is created in the compartment provided in compartment_id variable.
 * An IAM policy is created to allow the Service Connector Hub service to push data to the chosen target. 
 */

# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.80.0"
      configuration_aliases = [ oci, oci.home ]
    }
  }
}

data "oci_objectstorage_namespace" "this" {
  provider = oci
  compartment_id = var.tenancy_id
}

data "oci_identity_compartment" "this" {
  provider = oci.home  
  id = var.compartment_id
}

data "oci_streaming_stream" "existing_stream" {
  provider = oci
  count = lower(var.target_kind) == "streaming" && length(regexall("^ocid1.stream.oc.*$", var.target_stream)) > 0 ? 1 : 0
  stream_id = var.target_stream
}

data "oci_functions_function" "existing_function" {
  provider = oci
  count = lower(var.target_kind) == "functions" ? 1 : 0
  function_id = var.target_function_id
}

locals {
    
  target_stream_id   = lower(var.target_kind) == "streaming" ? (length(regexall("^ocid1.stream.oc.*$", var.target_stream)) > 0 ? var.target_stream : oci_streaming_stream.this[0].id) : null
  target_stream_name = lower(var.target_kind) == "streaming" ? (length(regexall("^ocid1.stream.oc.*$", var.target_stream)) == 0 ? var.target_stream : null) : null

  oss_grants = lower(var.target_kind) == "objectstorage" ? [
      <<EOF
          allow any-user to manage objects in compartment id ${var.compartment_id} where all {
          request.principal.type='serviceconnector',
          target.bucket.name= '${var.target_bucket_name}',
          request.principal.compartment.id='${var.compartment_id}' }
      EOF
  ] : []

  stream_compartment_id = length(regexall("^ocid1.stream.oc.*$", var.target_stream)) > 0 ? data.oci_streaming_stream.existing_stream[0].compartment_id : data.oci_identity_compartment.this.compartment_id
  stream_grants = lower(var.target_kind) == "streaming" ? [
      <<EOF
          allow any-user to use stream-push in compartment id ${local.stream_compartment_id} where all {
          request.principal.type='serviceconnector',
          target.stream.id='${local.target_stream_id}',
          request.principal.compartment.id='${var.compartment_id}' }
      EOF
  ] : [] 

  functions_grants = lower(var.target_kind) == "functions" ? [
      <<EOF
          Allow any-user to use fn-function in compartment id ${data.oci_functions_function.existing_function[0].compartment_id} where all {
          request.principal.type='serviceconnector',     
          request.principal.compartment.id='${var.compartment_id}'}
      EOF
      ,
      <<EOF2
          Allow any-user to use fn-invocation in compartment id ${var.compartment_id} where all {
          request.principal.type='serviceconnector',     
          request.principal.compartment.id='${var.compartment_id}' }
      EOF2
  ] : []

  logging_analytics_grants = lower(var.target_kind) == "logginganalytics" ? [
      <<EOF
          allow any-user to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in compartment id ${var.compartment_id} where all {
          request.principal.type='serviceconnector',
          target.loganalytics-log-group.id='${var.target_log_group_id}',
          request.principal.compartment.id='${var.compartment_id}' }
      EOF
  ] : []

  service_connector_grants = concat(local.oss_grants, local.stream_grants, local.functions_grants, local.logging_analytics_grants)

  policy_compartment_id = contains(["objectstorage","logginganalytics"], lower(var.target_kind)) ? data.oci_identity_compartment.this.compartment_id : lower(var.target_kind) == "streaming" ? local.stream_compartment_id : data.oci_functions_function.existing_function[0].compartment_id                   
}

#--------------------------------------------------
#--- SCH (Service Connector Hub) resource:
#--- 1. oci_sch_service_connector
#--------------------------------------------------
resource "oci_sch_service_connector" "this" {
  provider = oci
  compartment_id = var.compartment_id
  display_name   = var.display_name
  description    = "CIS Landing Zone Service Connector"
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
    bucket             = lower(var.target_kind) == "objectstorage" ? var.target_bucket_name : null
    object_name_prefix = lower(var.target_kind) == "objectstorage" ? var.target_object_name_prefix : null
    namespace          = lower(var.target_kind) == "objectstorage" ? (var.target_bucket_namespace != null ? var.target_bucket_namespace : data.oci_objectstorage_namespace.this.namespace) : null
    batch_rollover_size_in_mbs = lower(var.target_kind) == "objectstorage" ? var.target_object_store_batch_rollover_size_in_mbs : null
    batch_rollover_time_in_ms  = lower(var.target_kind) == "objectstorage" ? var.target_object_store_batch_rollover_time_in_ms : null
    stream_id          = lower(var.target_kind) == "streaming" ? local.target_stream_id : null
    function_id        = lower(var.target_kind) == "functions" ? var.target_function_id : null
    log_group_id       = lower(var.target_kind) == "logginganalytics" ?  var.target_log_group_id : null   
  }
  state  = var.activate ? "ACTIVE" : "INACTIVE"
}

#--------------------------------------------------
#--- SCH Object Storage bucket target resources:
#--- 1. oci_objectstorage_bucket
#--- 2. oci_logging_log_group
#--- 3. oci_logging_log
#--------------------------------------------------
resource "oci_objectstorage_bucket" "this" {
  provider       = oci
  count          = lower(var.target_kind) == "objectstorage" ? 1 : 0
  compartment_id = var.compartment_id
  name           = var.target_bucket_name
  namespace      = var.target_bucket_namespace != null ? var.target_bucket_namespace : data.oci_objectstorage_namespace.this.namespace
  #-- The try expression is expected to produce an error. 
  #-- var.cis_level = 2 and var.target_bucket_kms_key_id = null is a CIS violation 
  kms_key_id     = var.cis_level == "2" ? (var.target_bucket_kms_key_id != null ? var.target_bucket_kms_key_id : try(substr(var.target_bucket_kms_key_id,0,0))) : var.target_bucket_kms_key_id
  versioning     =  "Enabled" 
  defined_tags   = var.target_defined_tags
  freeform_tags  = var.target_freeform_tags
}

#-- Log group for bucket write access logs
resource "oci_logging_log_group" "bucket" {
  provider       = oci
  count          = length(oci_objectstorage_bucket.this) > 0 ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "${oci_objectstorage_bucket.this[0].name}-log-group"
  description    = "CIS Landing Zone Service Connector bucket log group."
  defined_tags   = var.target_defined_tags
  freeform_tags  = var.target_freeform_tags
}

#-- Log for bucket write access logs
resource "oci_logging_log" "bucket" {
  provider     = oci
  count        = length(oci_logging_log_group.bucket) > 0 && var.cis_level == "2" ? 1 : 0
  display_name = "${oci_objectstorage_bucket.this[0].name}-log"
  log_group_id = oci_logging_log_group.bucket[0].id
  log_type     = "SERVICE"
    
  configuration {
    source {
      category    = "write"
      resource    = oci_objectstorage_bucket.this[0].name
      service     = "objectstorage"
      source_type = "OCISERVICE"
    }
    compartment_id = var.compartment_id
  }

  is_enabled         = true
  retention_duration = 30
  defined_tags       = var.target_defined_tags
  freeform_tags      = var.target_freeform_tags
}

#--------------------------------------------------
#--- SCH Streaming target resource:
#--- 1. oci_streaming_stream
#--------------------------------------------------
resource "oci_streaming_stream" "this" {
  provider       = oci
  count          = lower(var.target_kind) == "streaming" ? (length(regexall("^ocid1.streaming.oc.*$", var.target_stream)) > 0 ? 0 : 1) : 0
  name           = local.target_stream_name
  partitions     = var.target_stream_partitions
  compartment_id = var.compartment_id
  defined_tags   = var.target_defined_tags
  freeform_tags  = var.target_freeform_tags
  retention_in_hours = var.target_stream_retention_in_hours
}

#--------------------------------------------------
#--- SCH policy resource:
#--- 1. oci_identity_policy
#--------------------------------------------------
resource "oci_identity_policy" "service_connector" {
  provider       = oci.home
  name           = var.target_policy_name
  description    = "CIS Landing Zone policy for Service Connector Hub to push data to ${lower(var.target_kind)}."
  compartment_id = local.policy_compartment_id
  statements     = local.service_connector_grants
  defined_tags   = var.policy_defined_tags
  freeform_tags  = var.policy_freeform_tags
}
