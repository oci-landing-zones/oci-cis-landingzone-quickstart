# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Buckets indexed by bucket name
output "oci_objectstorage_buckets" {
  description = "The buckets, indexed by bucket name."
  value       = {for bkt in oci_objectstorage_bucket.these: bkt.name => bkt}
}
