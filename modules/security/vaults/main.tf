# Copyright (c) 2020 Oracle and/or its affiliates.
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
    display_name   = var.vault_name
    vault_type     = var.vault_type
    defined_tags   = var.defined_tags
    freeform_tags  = var.freeform_tags
}