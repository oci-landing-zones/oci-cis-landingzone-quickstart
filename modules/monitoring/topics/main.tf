resource "oci_ons_notification_topic" "this" {
    compartment_id = var.compartment_id
    name           = var.notification_topic_name
    description    = var.notification_topic_description
}

resource "oci_ons_subscription" "this" {
    compartment_id = var.compartment_id
    endpoint       = var.subscription_endpoint
    protocol       = var.subscription_protocol
    topic_id       = oci_ons_notification_topic.this.id
}

