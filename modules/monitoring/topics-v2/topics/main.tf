# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

resource "oci_ons_notification_topic" "these" {
    #Required
    for_each = var.topics
        compartment_id = each.value.compartment_id
        name           = each.value.name
        description    = each.value.description
        defined_tags   = each.value.defined_tags
        freeform_tags  = each.value.freeform_tags  
    }