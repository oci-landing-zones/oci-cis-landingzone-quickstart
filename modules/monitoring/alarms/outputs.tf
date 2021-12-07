# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


output "alarms" {
  description = "The topcs, indexed by keys in var.topics."
  value = {for k, v in var.alarms : k => oci_monitoring_alarm.these[k]}
} 