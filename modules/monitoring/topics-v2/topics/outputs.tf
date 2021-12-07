# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


output "topics" {
  description = "The topcs, indexed by keys in var.topics."
  value = {for k, v in var.topics : k => oci_ons_notification_topic.these[k]}
} 