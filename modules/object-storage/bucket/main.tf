# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Creates a buckets from a map where the key is the bucket name
resource "oci_objectstorage_bucket" "these" {
    for_each = var.buckets
        compartment_id = each.value.compartment_id
        name           = each.value.name
        namespace      = each.value.namespace 
        kms_key_id     = var.kms_key_id
}
