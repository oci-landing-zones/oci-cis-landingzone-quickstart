// Copyright (c) 2021, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "subscriptions" {
    type = map(object({
    compartment_id  = string
    topic_id        = string 
    protocol        = string
    endpoint        = string
    defined_tags    = map(string)
    freeform_tags   = map(string)
  }))
}