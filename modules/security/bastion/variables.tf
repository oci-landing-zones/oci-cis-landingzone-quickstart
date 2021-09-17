variable "bastions" {
    description = "Details of the Bastion resources to be created."
    type = map(object({
      name = string,
      compartment_id = string,
      target_subnet_id = string,
      client_cidr_block_allow_list = list(string),
      max_session_ttl_in_seconds = number
    }))
}