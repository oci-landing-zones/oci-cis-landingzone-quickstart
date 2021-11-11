# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


output topics {
    description = "The topics, indexed by name."
    value = {for topic in oci_ons_notification_topic.these : topic.name => topic}
}