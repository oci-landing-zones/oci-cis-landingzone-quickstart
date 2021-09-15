# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### Policies
resource "oci_identity_policy" "these" {
  for_each = var.policies
    name           = each.key
    description    = each.value.description
    compartment_id = each.value.compartment_id
    statements     = each.value.statements
}
