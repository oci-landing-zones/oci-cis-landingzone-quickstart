# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_identity_compartment" "these" {
  for_each = var.compartments
    compartment_id = each.value.parent_id
    name           = each.value.name
    description    = each.value.description
    enable_delete  = each.value.enable_delete
}