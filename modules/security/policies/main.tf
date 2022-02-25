# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

/*****************************************
resource  "oci_identity_policy" "these" {
    for_each = var.policies
      name           = each.key
      compartment_id = each.value.compartment_id
      description    = each.value.description
      statements     = each.value.statements
      defined_tags   = each.value.defined_tags
      freeform_tags  = each.value.freeform_tags
}
*******************************************/