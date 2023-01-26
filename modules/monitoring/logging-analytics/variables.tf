# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_id" {
    description = "The tenancy ocid."
    type = string
}

variable "log_group_compartment_id" {
    description = "The compartment ocid for the log group."
    type = string
}

variable "log_group_name" {
    description = "The log group name."
    type = string
    default = "lz-logging-analytics-log-group"
}

variable "defined_tags" {
    description = "Logging Analytics defined tags."
    type = map(string)
    default = null
}

variable "freeform_tags" {
    description = "Logging Analytics freeform tags."
    type = map(string)
    default = null
}
