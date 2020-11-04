output "offending_policies" {
  value = local.offending_policies
}

output "to_do" {
  value = length(local.offending_policies) > 0 ? "Please remove the statement(s) in offending_policies. The grant 'manage all-resources in tenancy' should be given to the Administrators group only." : "No offending policies found. Nothing to do."
}

output "network_compartment_id" {
  value = module.compartments.compartments[local.network_compartment_name].id
}

output "security_compartment_id" {
  value = module.compartments.compartments[local.security_compartment_name].id
}

output "compute_storage_compartment_id" {
  value = module.compartments.compartments[local.compute_storage_compartment_name].id
}

output "appdev_compartment_id" {
  value = module.compartments.compartments[local.appdev_compartment_name].id
}

output "database_compartment_id" {
  value = module.compartments.compartments[local.database_compartment_name].id
}