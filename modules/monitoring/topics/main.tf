# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

resource "oci_ons_notification_topic" "this" {
    compartment_id = var.compartment_id
    name           = var.notification_topic_name
    description    = var.notification_topic_description
    defined_tags   = var.defined_tags
    freeform_tags  = var.freeform_tags
}

/* resource "oci_ons_notification_topic" "these" {
    for_each = var.topics
        compartment_id = each.value.compartment_id
        name           = each.value.name
        description    = each.value.description
        defined_tags   = each.value.defined_tags
        freeform_tags  = each.value.freeform_tags
} */

resource "oci_ons_subscription" "these" {
    for_each = var.subscriptions
        compartment_id = var.compartment_id
        defined_tags   = each.value.defined_tags
        endpoint       = each.value.endpoint
        protocol       = each.value.protocol
        topic_id       = oci_ons_notification_topic.this.id
}


 /* resource "oci_ons_subscription" "these" {
    for_each = var.subscriptions
        compartment_id = each.value.compartment_id
        endpoint       = each.value.endpoint
        protocol       = each.value.protocol
        topic_id       = oci_ons_notification_topic.these[each.value.topic_key].id
        defined_tags   = each.value.defined_tags
        freeform_tags  = each.value.freeform_tags
} */
