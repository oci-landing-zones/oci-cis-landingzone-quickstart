# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

resource "oci_ons_subscription" "these" {
   for_each = var.subscriptions
        compartment_id = each.value.compartment_id
        topic_id       = each.value.topic_id
        endpoint       = each.value.endpoint
        protocol       = each.value.protocol
        defined_tags   = each.value.defined_tags
        freeform_tags  = each.value.freeform_tags

    }