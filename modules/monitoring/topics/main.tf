# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_ons_notification_topic" "this" {
    compartment_id = var.compartment_id
    name           = var.notification_topic_name
    description    = var.notification_topic_description
}

resource "oci_ons_subscription" "these" {
    for_each = var.subscriptions
        compartment_id = var.compartment_id
        endpoint       = each.value.endpoint
        protocol       = each.value.protocol
        topic_id       = oci_ons_notification_topic.this.id
}

