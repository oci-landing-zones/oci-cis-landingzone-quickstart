resource "oci_kms_vault" "this" {
    compartment_id = var.compartment_id
    display_name = var.vault_name
    vault_type = var.vault_type
}


resource "oci_kms_key" "this" {
  compartment_id      = var.compartment_id
  display_name        = var.key_display_name
  management_endpoint = oci_kms_vault.this.management_endpoint

  key_shape {
    algorithm = var.key_key_shape_algorithm
    length    = var.key_key_shape_length
  }
  defined_tags = var.defined_tags
}

resource  "oci_identity_policy" "OCI_Services_Key_Access" {
    name = "${var.service_label}-OCIServicesKMSAccess"
    compartment_id = var.tenancy_ocid
    description = "Policy for Cloud Guard to be able to review a tenancy"
  statements = [
    "Allow service blockstorage, objectstorage-${var.region}, FssOc1Prod, oke, streaming to use keys in compartment ${var.compartment_name} where target.key.id = '${oci_kms_key.this.id}'"

  ]

}