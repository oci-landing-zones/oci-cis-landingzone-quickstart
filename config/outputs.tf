# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

/*
output "network_compartment_id" {
  value = module.compartments.compartments[local.network_compartment_name].id
  sensitive = true
}

output "security_compartment_id" {
  value = module.compartments.compartments[local.security_compartment_name].id
  sensitive = true
}

output "compute_storage_compartment_id" {
  value = module.compartments.compartments[local.compute_storage_compartment_name].id
  sensitive = true
}

output "appdev_compartment_id" {
  value = module.compartments.compartments[local.appdev_compartment_name].id
  sensitive = true
}

output "database_compartment_id" {
  value = module.compartments.compartments[local.database_compartment_name].id
  sensitive = true
}

output "rotateby_full_tag_name" {
    value = "${module.tags.custom_tag_namespace_name}.${module.tags.custom_tags[local.rotateby_tag_name].name}"
}
*/
/* output "offending_policies" {
  value = length(local.offending_policies) > 0 ? local.offending_policies : null
}

output "to_do" {
  value = length(local.offending_policies) > 0 ? "Please remove the statement(s) shown in offending_policies output. The grant 'manage all-resources in tenancy' should be given to the Administrators group only." : null
} */