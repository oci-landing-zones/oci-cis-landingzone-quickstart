# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

resource "oci_core_drg" "this" {
  count          = var.is_create_drg == true ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "${var.service_label}-drg"
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
}