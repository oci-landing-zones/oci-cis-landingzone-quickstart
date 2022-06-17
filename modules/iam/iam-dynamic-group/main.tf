# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

resource "oci_identity_dynamic_group" "these" {
  for_each = var.dynamic_groups
    name           = each.key
    compartment_id = each.value.compartment_id
    description    = each.value.description
    matching_rule  = each.value.matching_rule
    defined_tags   = each.value.defined_tags
    freeform_tags  = each.value.freeform_tags
}