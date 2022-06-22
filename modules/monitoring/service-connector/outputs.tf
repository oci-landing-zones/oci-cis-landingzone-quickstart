# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "service_connector" {
  description = "service connector information"
  value       = oci_sch_service_connector.this
}
