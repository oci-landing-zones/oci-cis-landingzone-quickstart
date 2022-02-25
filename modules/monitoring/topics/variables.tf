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

variable "defined_tags" {
  type        = map(string)
  description = "Map of key-value pairs of defined tags. (Optional)"
  default     = null
}

variable "freeform_tags" {
  type        = map(string)
  description = "Map of key-value pairs of freeform tags. (Optional)"
  default     = null
}

variable "subscriptions" {
  type = map(object({
    defined_tags = map(string)
    protocol     = string
    endpoint     = string
  }))
}  

/* variable "topics" {
  type = map(object({
    compartment_id = string
    name = string
    description = string
    defined_tags = map(string)
    freeform_tags = map(string)
  }))
}

variable "subscriptions" {
  type = map(object({
    protocol = string
    endpoint = string
    compartment_id = string
    topic_key = string
    defined_tags = map(string)
    freeform_tags = map(string)
  }))
} */