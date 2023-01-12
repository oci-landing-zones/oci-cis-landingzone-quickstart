# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "service_connector" {
  description = "Managed Service Connector information."
  value       = oci_sch_service_connector.this
}

output "service_connector_target" {
  description = "Managed Service Connector target."
  value       = length(oci_objectstorage_bucket.this) > 0 ? oci_objectstorage_bucket.this[0] : length(oci_streaming_stream.this) > 0 ? oci_streaming_stream.this[0] : null
}