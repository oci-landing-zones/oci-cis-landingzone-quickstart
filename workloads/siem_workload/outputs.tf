# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "integration_link" {
  value = lookup(local.siem_info, var.integration_type).doc_link
}
output "next_steps" {
  value = lookup(local.siem_info, var.integration_type).next_steps
}

#output "stream" {
#  value = module.vision_streams[0].streams
#}

#output "stream_pool" {
#  value = module.vision_streams[0].stream_pools
#}
