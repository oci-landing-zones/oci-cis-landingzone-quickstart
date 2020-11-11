# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration identifies policies containing statements granting manage privilege on all-resources to groups other than Adminstrators.

data "oci_identity_policies" "all" {
  compartment_id = var.tenancy_ocid
  /*
  depends_on = [
    module.network_admins,
    module.compute_storage_admins,
    module.security_admins,
    module.database_admins,
    module.appdev_admins,
    module.iam_admins
  ]*/
}

locals {
  offending_policies = flatten([for p in data.oci_identity_policies.all.policies :
    [for s in p.statements : {
      (p.name) = {statement = s}
    } if contains(split(" ",lower(s)),"manage") && contains(split(" ",lower(s)),"all-resources") && contains(split(" ",lower(s)),"tenancy") && !contains(split(" ",lower(s)),"administrators")
    ] 
  ])
}
