# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "service_connector" {
  description = "Managed Service Connector information"
  value       = oci_sch_service_connector.logging
}

output "service_connector_target_bucket" {
  description = "Managed Object Storage Bucket used as Service Connector target"
  value       = oci_objectstorage_bucket.sch != null ? oci_objectstorage_bucket.sch : ""
}

output "service_connector_target_stream" {
  description = "Managed Stream used as Service Connector target"
  value       = oci_streaming_stream.sch != null ? oci_streaming_stream.sch : ""
}