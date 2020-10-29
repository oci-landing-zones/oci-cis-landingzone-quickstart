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
