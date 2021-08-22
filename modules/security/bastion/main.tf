resource "oci_bastion_bastion" "this" {
    bastion_type = "standard"
    compartment_id = var.bastion.compartment_id
    target_subnet_id = var.bastion.target_subnet_id

    name = var.bastion.name
    client_cidr_block_allow_list = var.bastion.client_cidr_block_allow_list
    max_session_ttl_in_seconds = var.bastion.max_session_ttl_in_seconds
}