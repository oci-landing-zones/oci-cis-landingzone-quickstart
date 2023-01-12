# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "log_group" {
  description = "Logging Analytics log group."
  value       = oci_log_analytics_log_analytics_log_group.this
}