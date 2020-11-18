resource  "oci_identity_policy" "these" {
    for_each = var.policies
      name           = each.key
      compartment_id = each.value.compartment_id
      description    = each.value.description
      statements     = each.value.statements 
}