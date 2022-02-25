# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "bastions" {
    description = "Details of the Bastion resources to be created."
    type = map(object({
      name = string,
      compartment_id = string,
      target_subnet_id = string,
      client_cidr_block_allow_list = list(string),
      max_session_ttl_in_seconds = number,
      defined_tags = map(string),
      freeform_tags = map(string)
    }))
}