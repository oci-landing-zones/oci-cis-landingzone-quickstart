data "oci_identity_policies" "all" {
  compartment_id = var.tenancy_ocid
}

locals {
  offending_policies = flatten([for p in data.oci_identity_policies.all.policies :
    [for s in p.statements : {
      "${p.name}" = {statement = s}
    } if contains(split(" ",lower(s)),"manage") && contains(split(" ",lower(s)),"all-resources") && contains(split(" ",lower(s)),"tenancy") && !contains(split(" ",lower(s)),"administrators")
    ] 
  ])
}
output "offending_policies" {
  value = local.offending_policies
}

output "warning" {
  value = length(local.offending_policies) > 0 ? "Please remove the statement(s) in offending_policies. The grant 'manage all-resources in tenancy' should be given to the Administrators group only." : "No offending policies found."
}