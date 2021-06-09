# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### Dynamic Group policy

resource "oci_identity_dynamic_group" "these" {
  for_each = var.dynamic_groups
    name           = each.key
    compartment_id = each.value.compartment_id
    description    = each.value.description
    matching_rule  = each.value.matching_rule

  #Optional
  # defined_tags = each.defined_tags
  # freeform_tags = each.freeform_tags
}