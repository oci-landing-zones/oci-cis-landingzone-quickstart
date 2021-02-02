# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output topic {
    description = "Topic information."
    value = oci_ons_notification_topic.this
}

output subcriptions {
    description = "The subscriptions, indexed by endpoint value."
    value = {for s in oci_ons_subscription.these : s.endpoint => s}
}