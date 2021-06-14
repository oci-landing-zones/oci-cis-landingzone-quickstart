# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Getting Object Storage Namespace
data "oci_objectstorage_namespace" "bucket_namespace" {
    compartment_id = var.tenancy_ocid
}

# Creates a buckets from a map where the key is the bucket name
resource "oci_objectstorage_bucket" "these" {
    for_each = var.buckets
        namespace = data.oci_objectstorage_namespace.bucket_namespace.namespace 
        name             = each.key
        compartment_id   = each.value.compartment_id
        kms_key_id       = var.kms_key_id
}
