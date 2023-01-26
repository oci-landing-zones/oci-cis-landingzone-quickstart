/**
 * ## CIS OCI Landing Zone KMS Vaults Module.
 *
 * This module manages a single OCI KMS vault resource defined by var.name and var.type in compartment var.compartment_id.
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

resource "oci_kms_vault" "this" {
  compartment_id = var.compartment_id
  display_name   = var.name
  vault_type     = var.type
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
}
