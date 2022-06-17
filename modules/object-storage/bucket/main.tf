# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

# Creates a buckets from a map where the key is the bucket name
resource "oci_objectstorage_bucket" "these" {
    for_each = var.buckets
        compartment_id = each.value.compartment_id
        name           = each.value.name
        namespace      = each.value.namespace 
        kms_key_id     = var.kms_key_id
        versioning     =  "Enabled" 
	defined_tags   = each.value.defined_tags
	freeform_tags  = each.value.freeform_tags
}
