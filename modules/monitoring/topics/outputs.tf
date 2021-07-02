# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output topic {
    description = "Topic information."
    value = oci_ons_notification_topic.this
}

output subscriptions {
    description = "The topic subscriptions."
    value = oci_ons_subscription.these
}