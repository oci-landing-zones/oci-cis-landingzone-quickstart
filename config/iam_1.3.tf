# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration prevents IAMAdmins group from changing Administrators group assignments and tenancy level policies.

locals {
  // Permissions to be created always at the root compartment
  iam_root_permissions = ["Allow group ${local.iam_admin_group_name} to inspect users in tenancy",
                               "Allow group ${local.iam_admin_group_name} to inspect groups in tenancy",
                               "Allow group ${local.iam_admin_group_name} to manage groups in tenancy where all {target.group.name ! = 'Administrators', target.group.name ! = '${local.cred_admin_group_name}'}",
                               "Allow group ${local.iam_admin_group_name} to inspect identity-providers in tenancy",
                               "Allow group ${local.iam_admin_group_name} to manage identity-providers in tenancy where any {request.operation = 'AddIdpGroupMapping', request.operation = 'DeleteIdpGroupMapping'}",
                               "Allow group ${local.iam_admin_group_name} to manage dynamic-groups in tenancy",
                               "Allow group ${local.iam_admin_group_name} to manage authentication-policies in tenancy",
                               "Allow group ${local.iam_admin_group_name} to manage network-sources in tenancy",
                               "Allow group ${local.iam_admin_group_name} to manage quota in tenancy",
                               "Allow group ${local.iam_admin_group_name} to read audit-events in tenancy"]


  // Permissions to be created always at the enclosing compartment level, which *can* be the root compartment
  iam_enccmp_permissions = ["Allow group ${local.iam_admin_group_name} to manage policies in ${local.policy_level}",
                               "Allow group ${local.iam_admin_group_name} to manage compartments in ${local.policy_level}",
                               "Allow group ${local.iam_admin_group_name} to manage tag-defaults in ${local.policy_level}",
                               "Allow group ${local.iam_admin_group_name} to manage tag-namespaces in ${local.policy_level}",
                               "Allow group ${local.iam_admin_group_name} to manage orm-stacks in ${local.policy_level}",
                               "Allow group ${local.iam_admin_group_name} to manage orm-jobs in ${local.policy_level}",
                               "Allow group ${local.iam_admin_group_name} to manage orm-config-source-providers in ${local.policy_level}"]

}

module "cis_iam_admins" {
  count             = var.use_existing_iam_groups == false ? 1 : 0
  source            = "../modules/iam/iam-group"
  providers         = { oci = oci.home }
  tenancy_ocid      = var.tenancy_ocid
  group_name        = local.iam_admin_group_name
  group_description = "Group responsible for managing IAM resources in the tenancy."
  user_names        = []
}

module "cis_iam_admins_root_policy" {
  count      = local.use_existing_tenancy_policies == false ? 1 : 0
  source     = "../modules/iam/iam-policy"
  providers  = { oci = oci.home }
  depends_on = [module.cis_iam_admins, module.cis_compartments] ### Explicitly declaring dependencies on the group and compartments modules.
  policies   = {
    (local.iam_admin_root_policy_name) = {
      compartment_id    = var.tenancy_ocid
      description       = "Policy allowing ${local.iam_admin_group_name} group to manage security related services at the root compartment."
      statements        = local.iam_root_permissions
    }
  }
}

module "cis_iam_admins_policy" {
  source             = "../modules/iam/iam-policy"
  providers          = { oci = oci.home }
  depends_on         = [module.cis_iam_admins] ### Explicitly declaring dependency on the group module.
  policies = {
    (local.iam_admin_policy_name) = {
      compartment_id = local.parent_compartment_id
      description    = "Policy allowing ${local.iam_admin_group_name} group to manage IAM resources in Landing Zone enclosing compartment (${local.policy_level})."
      statements     = local.iam_enccmp_permissions
    }
  }
}
