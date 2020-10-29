output "offending_policies" {
  value = local.offending_policies
}

output "to_do" {
  value = length(local.offending_policies) > 0 ? "Please remove the statement(s) in offending_policies. The grant 'manage all-resources in tenancy' should be given to the Administrators group only." : "No offending policies found. Nothing to do."
}

output "compartments" {
  value = module.compartments.compartments
}