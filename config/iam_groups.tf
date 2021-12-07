# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration provisions Landing Zone groups.

locals {
  default_groups = {
    (local.network_admin_group_name) = {
      description  = "Landing Zone group for managing networking in compartment ${local.network_compartment.name}."
      user_ids     = []
      defined_tags = null
    },
    (local.security_admin_group_name) = {
      description  = "Landing Zone group for managing security services in compartment ${local.security_compartment.name}."
      user_ids     = []
      defined_tags = null
    },
    (local.appdev_admin_group_name) = {
      description  = "Landing Zone group for managing app development related services in compartment ${local.appdev_compartment.name}."
      user_ids     = []
      defined_tags = null
    },
    (local.database_admin_group_name) = {
      description  = "Landing Zone group for managing databases in compartment ${local.database_compartment.name}."
      user_ids     = []
      defined_tags = null
    },
    (local.auditor_group_name) = {
      description  = "Landing Zone group for auditing the tenancy."
      user_ids     = []
      defined_tags = null
    },
    (local.announcement_reader_group_name) = {
      description  = "Landing Zone group for reading Console announcements."
      user_ids     = []
      defined_tags = null
    },
    (local.iam_admin_group_name) = {
      description  = "Landing Zone group for managing IAM resources in the tenancy."
      user_ids     = []
      defined_tags = null
    },
    (local.cred_admin_group_name) = {
      description  = "Landing Zone group for managing users credentials in the tenancy."
      user_ids     = []
      defined_tags = null
    },
    (local.cost_admin_group_name) = {
      description  = "Landing Zone group for Cost Management."
      user_ids     = []
      defined_tags = null
    }
  }
  exainfra_group = var.deploy_exainfra_cmp == true ? {
    (local.exainfra_admin_group_name) = {
      description  = "Landing Zone group for managing Exadata infrastructure in the tenancy."
      user_ids     = []
      defined_tags = null
    }
  } : {}
  
  groups = merge(local.default_groups,local.exainfra_group)

}
module "lz_groups" {
  source       = "../modules/iam/iam-group"
  providers    = { oci = oci.home }
  tenancy_ocid = var.tenancy_ocid
  groups = var.use_existing_groups == false ? local.groups : {}
}