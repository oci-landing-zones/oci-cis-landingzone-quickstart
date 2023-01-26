/**
 * ## CIS OCI Landing Zone Object Storage Buckets Module.
 *
 * This module manages OCI Object Storage buckets resources per CIS OCI Benchmark.
 * The buckets are encrypted by the provided key ocid given in var.buckets' kms_key_id.
 * If cis_level = 1 and kms_key_id is not provided, the bucket is encrypted with an Oracle managed key.
 * If cis_level = 2 and kms_key_id is not provided, the module produces an error.
 */

# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

#------------------------------------------------------------------
#-- Managed buckets.
#------------------------------------------------------------------
resource "oci_objectstorage_bucket" "these" {
  for_each = var.buckets
    compartment_id = each.value.compartment_id
    name           = each.value.name
    namespace      = each.value.namespace 
    #-- The try expression is expected to produce an error. 
    #-- var.cis_level = 2 and var.kms_key_id = null is a CIS violation
    kms_key_id     = var.cis_level == "2" ? (each.value.kms_key_id != null ? each.value.kms_key_id : try(substr(each.value.kms_key_id,0,0))) : each.value.kms_key_id
    versioning     = "Enabled" 
	  defined_tags   = each.value.defined_tags
	  freeform_tags  = each.value.freeform_tags
}
