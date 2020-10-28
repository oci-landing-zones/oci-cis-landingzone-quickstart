data "oci_identity_policies" "all" {
  compartment_id = var.tenancy_ocid
  depends_on = [
    module.network_admins,
    module.compute_admins,
    module.volume_admins,
    module.objectstore_admins,
    module.iam_admins
  ]
}

locals {
  offending_policies = flatten([for p in data.oci_identity_policies.all.policies :
    [for s in p.statements : {
      (p.name) = {statement = s}
    } if contains(split(" ",lower(s)),"manage") && contains(split(" ",lower(s)),"all-resources") && contains(split(" ",lower(s)),"tenancy") && !contains(split(" ",lower(s)),"administrators")
    ] 
  ])
}
