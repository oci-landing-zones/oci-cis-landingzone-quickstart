# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration prevents IAMAdmins group from changing Administrators group assignments and tenancy level policies.

module "cis_iam_admins" {
  count             = var.use_existing_iam_groups == false ? 1 : 0
  source            = "../modules/iam/iam-group"
  providers         = { oci = oci.home }
  tenancy_ocid      = var.tenancy_ocid
  group_name        = local.iam_admin_group_name
  group_description = "Group responsible for managing IAM resources in the tenancy."
  user_names        = []
}

module "cis_iam_admins_policy" {
  source                = "../modules/iam/iam-policy"
  providers             = { oci = oci.home }
  depends_on            = [module.cis_iam_admins] ### Explicitly declaring dependency on the group module.
  policies = {
    ("${var.service_label}-IAMAdmins-Policy") = {
      compartment_id    = var.tenancy_ocid
      description       = "Policy allowing ${local.iam_admin_group_name} group to manage IAM resources, except changing Administrators group assignments."
      statements = [#"Allow group ${local.iam_admin_group_name} to manage users in tenancy",
                      "Allow group ${local.iam_admin_group_name} to inspect groups in tenancy",
                      "Allow group ${local.iam_admin_group_name} to manage groups in tenancy where target.group.name != 'Administrators'",
                      "Allow group ${local.iam_admin_group_name} to inspect policies in tenancy",
                      #"Allow group ${local.iam_admin_group_name} to manage policies in tenancy where target.policy.name != 'Tenant Admin Policy'",
                      "Allow group ${local.iam_admin_group_name} to manage policies in ${local.policy_level}",
                      "Allow group ${local.iam_admin_group_name} to manage dynamic-groups in tenancy",
                      "Allow group ${local.iam_admin_group_name} to manage compartments in ${local.policy_level}",
                      "Allow group ${local.iam_admin_group_name} to manage authentication-policies in tenancy",
                      "Allow group ${local.iam_admin_group_name} to manage identity-providers in tenancy",
                      "Allow group ${local.iam_admin_group_name} to manage network-sources in tenancy",
                      "Allow group ${local.iam_admin_group_name} to manage tag-defaults in ${local.policy_level}",
                      "Allow group ${local.iam_admin_group_name} to manage tag-namespaces in ${local.policy_level}",
                      #"Allow group ${local.iam_admin_group_name} to manage credentials in tenancy",
                      "Allow group ${local.iam_admin_group_name} to manage orm-stacks in ${local.policy_level}",
                      "Allow group ${local.iam_admin_group_name} to manage orm-jobs in ${local.policy_level}",
                      "Allow group ${local.iam_admin_group_name} to manage orm-config-source-providers in ${local.policy_level}",
                      "Allow Group ${local.iam_admin_group_name} to read audit-events in tenancy"]
    }
  }
}

module "cis_cred_admins" {
  count             = var.use_existing_iam_groups == false ? 1 : 0
  source            = "../modules/iam/iam-group"
  providers         = { oci = oci.home }
  tenancy_ocid      = var.tenancy_ocid
  group_name        = local.cred_admin_group_name
  group_description = "Group responsible for managing user credentials in the tenancy."
  user_names        = []
}

module "cis_cred_admins_policy" {
  source                = "../modules/iam/iam-policy"
  providers             = { oci = oci.home }
  depends_on            = [module.cis_cred_admins] ### Explicitly declaring dependency on the group module.
  policies              = {
    ("${var.service_label}-CredAdmins-Policy") = {
      compartment_id         = var.tenancy_ocid
      description            = "Policy allowing ${local.cred_admin_group_name} group to manage credentials in tenancy."
      statements             = ["Allow group ${local.cred_admin_group_name} to manage users in tenancy",
                                "Allow group ${local.cred_admin_group_name} to manage credentials in tenancy"]
    }
  }
}