# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

### Policies
resource "oci_identity_policy" "these" {
  for_each = {for k, v in var.policies : k => v if v != null}
    name           = each.key
    description    = each.value.description
    compartment_id = each.value.compartment_id
    statements     = each.value.statements
    defined_tags   = each.value.defined_tags
    freeform_tags  = each.value.freeform_tags
}
