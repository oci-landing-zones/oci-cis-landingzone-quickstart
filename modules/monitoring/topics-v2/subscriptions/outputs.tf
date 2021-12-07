# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output subscriptions {
    description = "The subscriptions, indexed by ID."
    value = {for sub in oci_ons_subscription.these : sub.id => sub}
}