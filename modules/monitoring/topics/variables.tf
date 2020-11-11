# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartment_id" {
  type        = string
  description = "The default compartment OCID to use for resources (unless otherwise specified)."
  default     = ""
} 

variable "notification_topic_name" {
  type        = string
  description = "The notification topic name."
  default     = ""
} 

variable "notification_topic_description" {
  type        = string
  description = "The notification topic description."
  default     = ""
}

variable "subscriptions" {
  type = map(object({
    protocol = string
    endpoint = string
  }))
}  