# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

#---------------------------------------------------------------
#--- Service Connector variables 
#---------------------------------------------------------------
variable "tenancy_id" {
    description = "The tenancy ocid."
    type = string
}

variable "compartment_id" {
    description = "The compartment ocid where to create the Service Connector."
    type = string
}

variable "display_name" {
    description = "The Service Connector display name."
    type = string
    default = "lz-service-connector"
}

variable "activate" {
    description = "Whether the Service Connector should be activated."
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
#--- Sources variables 
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
#--- Target variables 
#---------------------------------------------------------------
variable "target_kind" {
    description = "The target kind."
    type = string
    default = "objectstorage"
    validation {
        condition     = contains(["objectstorage", "streaming", "functions", "logginganalytics"], var.target_kind)
        error_message = "Validation failed for target_kind: valid values are objectstorage, streaming, functions or logginganalytics."
    }
}

variable "target_compartment_id" {
    description = "The target compartment ocid."
    type = string
}

variable "target_bucket_namespace" {
    description = "The target Object Storage bucket namespace. If null, the module retrives the namespace based on the tenancy ocid."
    type = string
    default = null
}

variable "target_bucket_name" {
    description = "The target Object Storage bucket name to be created."
    type = string
    default = "lz-service-connector-bucket"
}

variable "target_object_name_prefix" {
    description = "The target Object Storage object name prefix."
    type = string
    default = "lz-sch"
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

variable "target_defined_tags" {
    description = "The Service Connector target defined tags."
    type = map(string)
    default = null
}

variable "target_freeform_tags" {
    description = "The Service Connector target freeform tags."
    type = map(string)
    default = null
}

variable "target_stream" {
    description = "The target stream name or ocid. If a name is given, a new stream is created. If an ocid is given, the existing stream is used."
    type = string
    default = "lz-service-connector-stream"
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

variable "target_function_id" {
    description = "The target function ocid."
    type = string
    default = null
}

variable "target_log_group_id" {
    description = "The target log group ocid. Used when target_kind = logginganalytics."
    type = string
    default = null
}

#---------------------------------------------------------------
#--- Policy variables 
#---------------------------------------------------------------
variable "target_policy_name" {
    description = "The Service Connector target policy name."
    type = string
    default = "lz-service-connector-target-policy"
}

variable "policy_defined_tags" {
    description = "The Service Connector policy defined tags."
    type = map(string)
    default = null
}

variable "policy_freeform_tags" {
    description = "The Service Connector policy freeform tags."
    type = map(string)
    default = null
}

variable "cis_level" {
  type = string
  description = "The CIS OCI Benchmark profile level for buckets. Level 1 is be practical and prudent. Level 2 is intended for environments where security is more critical than manageability and usability."
  default = "1"
  validation {
    condition     = contains(["1", "2"], var.cis_level)
    error_message = "Validation failed for cis_level: valid values are 1 or 2."
  }
}
