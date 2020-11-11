# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_identity_compartment" "these" {
  for_each = var.compartments
    name = each.key
    description = each.value.description
}

data "oci_identity_compartments" "these" {
  depends_on = [
    oci_identity_compartment.these
  ]
  compartment_id = var.tenancy_ocid

  filter {
    name   = "name"
    values = keys(var.compartments)
  }
}
