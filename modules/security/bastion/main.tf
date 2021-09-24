resource "oci_bastion_bastion" "these" {
  for_each = var.bastions  
    bastion_type     = "STANDARD"
    compartment_id   = each.value.compartment_id
    target_subnet_id = each.value.target_subnet_id
    name             = each.value.name
    client_cidr_block_allow_list = each.value.client_cidr_block_allow_list
    max_session_ttl_in_seconds   = each.value.max_session_ttl_in_seconds
}