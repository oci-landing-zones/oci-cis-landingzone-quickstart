# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

#---------------------------------------------------------------
#--- Service Connector variables -------------------------------
#---------------------------------------------------------------
variable "tenancy_ocid" {
    description = "The tenancy ocid."
    type = string
}

variable "service_label" {
    description = "The service label."
    type = string
}

variable "compartment_id" {
    description = "The compartment ocid where to create the Service Connector."
    type = string
}

variable "display_name" {
    description = "The Service Connector display name."
    type = string
    default = "service-connector"
}

variable "enable_service_connector" {
    description = "Whether the Service Connector should be enabled."
    type = bool
    default = false
}

variable "defined_tags" {
    description = "The Service Connector defined tags."
    type = map(string)
    default = null
}

variable "freeform_tags" {
    description = "The Service Connector freeform tags."
    type = map(string)
    default = null
}

#---------------------------------------------------------------
#--- Sources variables ------------------------------------------
#---------------------------------------------------------------
variable "logs_sources" {
    description = "The Service Connector logs sources."
    type = list(object({
        compartment_id = string,
        log_group_id   = string,
        log_id         = string
    }))
}

#---------------------------------------------------------------
#--- Target variables ------------------------------------------
#---------------------------------------------------------------
variable "target_kind" {
    description = "The target kind."
    type = string
    default = "objectstorage"
    validation {
        condition     = contains(["objectstorage", "streaming", "functions"], var.target_kind)
        error_message = "Validation failed for target_kind: valid values are objectstorage, streaming or functions."
    }
}

variable "target_compartment_id" {
    description = "The target compartment ocid."
    type = string
}

variable "target_bucket_name" {
    description = "The target Object Storage bucket name to be created."
    type = string
    default = "service-connector-bucket"
}

variable "target_object_name_prefix" {
    description = "The target Object Storage object name prefix."
    type = string
    default = "sch"
}

variable "target_bucket_kms_key_id" {
    description = "The KMS key ocid used to encrypt the target Object Storage bucket."
    type = string
}

variable "target_object_store_batch_rollover_size_in_mbs" {
    description = "The batch rollover size in megabytes."
    type = number
    default = 100
}

variable "target_object_store_batch_rollover_time_in_ms" {
    description = "The batch rollover time in milliseconds."
    type = number
    default = 420000
}

variable "target_bucket_defined_tags" {
    description = "The Service Connector target bucket defined tags."
    type = map(string)
    default = null
}

variable "target_bucket_freeform_tags" {
    description = "The Service Connector target bucket freeform tags."
    type = map(string)
    default = null
}

variable "target_stream" {
    description = "The target stream name or ocid. If a name is given, a new stream is created. If an ocid is given, the existing stream is used."
    type = string
    default = "service-connector-stream"
}

variable "target_stream_partitions" {
    description = "The number of partitions in the target stream. Applicable if target_stream is not an ocid."
    type = number
    default = 1
}

variable "target_stream_retention_in_hours" {
    description = "The retention period of the target stream, in hours. Applicable if target_stream is not an ocid."
    type = number
    default = 24
}

variable "target_stream_defined_tags" {
    description = "The Service Connector target stream defined tags."
    type = map(string)
    default = null
}

variable "target_stream_freeform_tags" {
    description = "The Service Connector target stream freeform tags."
    type = map(string)
    default = null
}

variable "target_function_id" {
    description = "The target function ocid."
    type = string
    default = null
}

#---------------------------------------------------------------
#--- Policy variables ------------------------------------------
#---------------------------------------------------------------
variable "policy_compartment_id" {
    description = "The Service Connector policy compartment ocid"
    type = string
    default = null
}

variable "target_policy_name" {
    description = "The Service Connector target policy name"
    type = string
    default = "service-connector-target-policy"
}

variable "policy_defined_tags" {
    description = "The Service Connector policy defined tags"
    type = map(string)
    default = null
}

variable "policy_freeform_tags" {
    description = "The Service Connector policy freeform tags"
    type = map(string)
    default = null
}
