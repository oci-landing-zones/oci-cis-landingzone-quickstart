# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration provisions Landing Zone policies.

locals {
  // Permissions to be created always at the root compartment
  iam_root_permissions = ["Allow group ${local.iam_admin_group_name} to inspect users in tenancy",
    "Allow group ${local.iam_admin_group_name} to inspect groups in tenancy",
    "Allow group ${local.iam_admin_group_name} to manage groups in tenancy where all {target.group.name != 'Administrators', target.group.name != '${local.cred_admin_group_name}'}",
    "Allow group ${local.iam_admin_group_name} to inspect identity-providers in tenancy",
    "Allow group ${local.iam_admin_group_name} to manage identity-providers in tenancy where any {request.operation = 'AddIdpGroupMapping', request.operation = 'DeleteIdpGroupMapping'}",
    "Allow group ${local.iam_admin_group_name} to manage dynamic-groups in tenancy",
    "Allow group ${local.iam_admin_group_name} to manage authentication-policies in tenancy",
    "Allow group ${local.iam_admin_group_name} to manage network-sources in tenancy",
    "Allow group ${local.iam_admin_group_name} to manage quota in tenancy",
    "Allow group ${local.iam_admin_group_name} to read audit-events in tenancy",
  "Allow group ${local.iam_admin_group_name} to use cloud-shell in tenancy"]

  // Permissions to be created always at the enclosing compartment level, which *can* be the root compartment
  iam_enccmp_permissions = ["Allow group ${local.iam_admin_group_name} to manage policies in ${local.policy_scope}",
    "Allow group ${local.iam_admin_group_name} to manage compartments in ${local.policy_scope}",
    "Allow group ${local.iam_admin_group_name} to manage tag-defaults in ${local.policy_scope}",
    "Allow group ${local.iam_admin_group_name} to manage tag-namespaces in ${local.policy_scope}",
    "Allow group ${local.iam_admin_group_name} to manage orm-stacks in ${local.policy_scope}",
    "Allow group ${local.iam_admin_group_name} to manage orm-jobs in ${local.policy_scope}",
  "Allow group ${local.iam_admin_group_name} to manage orm-config-source-providers in ${local.policy_scope}"]

  // Permissions to be created always at the root compartment
  security_root_permissions = ["Allow group ${local.security_admin_group_name} to manage cloudevents-rules in tenancy",
    "Allow group ${local.security_admin_group_name} to manage cloud-guard-family in tenancy",
    "Allow group ${local.security_admin_group_name} to read tenancies in tenancy",
    "Allow group ${local.security_admin_group_name} to read objectstorage-namespaces in tenancy",
  "Allow group ${local.security_admin_group_name} to use cloud-shell in tenancy"]

  // Permissions to be created always at the enclosing compartment level, which *can* be the root compartment
  security_enccmp_permissions = ["Allow group ${local.security_admin_group_name} to manage tag-namespaces in ${local.policy_scope}",
    "Allow group ${local.security_admin_group_name} to manage tag-defaults in ${local.policy_scope}",
    "Allow group ${local.security_admin_group_name} to manage repos in ${local.policy_scope}",
    "Allow group ${local.security_admin_group_name} to read audit-events in ${local.policy_scope}",
    "Allow group ${local.security_admin_group_name} to read app-catalog-listing in ${local.policy_scope}",
    "Allow group ${local.security_admin_group_name} to read instance-images in ${local.policy_scope}",
  "Allow group ${local.security_admin_group_name} to inspect buckets in ${local.policy_scope}"]

  // Permissions to be created always at the enclosing compartment level, which *can* be the root compartment
  security_cmp_permissions = ["Allow group ${local.security_admin_group_name} to read all-resources in compartment ${local.security_compartment_name}",
    "Allow group ${local.security_admin_group_name} to manage instance-family in compartment ${local.security_compartment_name}",
    "Allow group ${local.security_admin_group_name} to manage vaults in compartment ${local.security_compartment_name}",
    "Allow group ${local.security_admin_group_name} to manage keys in compartment ${local.security_compartment_name}",
    "Allow group ${local.security_admin_group_name} to manage secret-family in compartment ${local.security_compartment_name}",
    "Allow group ${local.security_admin_group_name} to manage logging-family in compartment ${local.security_compartment_name}",
    "Allow group ${local.security_admin_group_name} to manage serviceconnectors in compartment ${local.security_compartment_name}",
    "Allow group ${local.security_admin_group_name} to manage streams in compartment ${local.security_compartment_name}",
    "Allow group ${local.security_admin_group_name} to manage ons-family in compartment ${local.security_compartment_name}",
    "Allow group ${local.security_admin_group_name} to manage functions-family in compartment ${local.security_compartment_name}",
    "Allow group ${local.security_admin_group_name} to manage waas-family in compartment ${local.security_compartment_name}",
    "Allow group ${local.security_admin_group_name} to manage security-zone in compartment ${local.security_compartment_name}",
    "Allow group ${local.security_admin_group_name} to read virtual-network-family in compartment ${local.network_compartment_name}",
    "Allow group ${local.security_admin_group_name} to use subnets in compartment ${local.network_compartment_name}",
    "Allow group ${local.security_admin_group_name} to use network-security-groups in compartment ${local.network_compartment_name}",
    "Allow group ${local.security_admin_group_name} to use vnics in compartment ${local.network_compartment_name}",
    "Allow group ${local.security_admin_group_name} to manage orm-stacks in compartment ${local.security_compartment_name}",
    "Allow group ${local.security_admin_group_name} to manage orm-jobs in compartment ${local.security_compartment_name}",
    "Allow group ${local.security_admin_group_name} to manage orm-config-source-providers in compartment ${local.security_compartment_name}",
  "Allow group ${local.security_admin_group_name} to manage vss-family in compartment ${local.security_compartment_name}"]

  security_kms_database_permissions = local.use_existing_tenancy_policies == false && var.use_existing_groups == false ? ["Allow dynamic-group ${var.service_label}-adb-dynamic-group to manage vaults in compartment ${local.security_compartment_name}",
        "Allow dynamic-group ${var.service_label}-adb-dynamic-group to manage keys in compartment ${local.security_compartment_name}"] : []

}

module "lz_root_policies" {
  source     = "../modules/iam/iam-policy"
  providers  = { oci = oci.home }
  depends_on = [module.lz_groups, module.lz_compartments] ### Explicitly declaring dependencies on the group and compartments modules.
  policies = local.use_existing_tenancy_policies == false ? {
    (local.security_admin_root_policy_name) = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone ${local.security_admin_group_name}'s root compartment policy."
      statements     = local.security_root_permissions
    },
    (local.iam_admin_root_policy_name) = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone ${local.iam_admin_group_name}'s root compartment policy."
      statements     = local.iam_root_permissions
    },
    (local.network_admin_root_policy_name) = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone ${local.network_admin_group_name}'s root compartment policy."
      statements     = ["Allow group ${local.network_admin_group_name} to use cloud-shell in tenancy"]
    },
    (local.appdev_admin_root_policy_name) = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone ${local.appdev_admin_group_name}'s root compartment policy."
      statements     = ["Allow group ${local.appdev_admin_group_name} to use cloud-shell in tenancy"]
    },
    (local.database_admin_root_policy_name) = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone ${local.database_admin_group_name}'s root compartment policy."
      statements     = ["Allow group ${local.database_admin_group_name} to use cloud-shell in tenancy"]
    },
    (local.auditor_policy_name) = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone ${local.auditor_group_name}'s root compartment policy."
      statements = ["Allow group ${local.auditor_group_name} to inspect all-resources in tenancy",
        "Allow group ${local.auditor_group_name} to read instances in tenancy",
        "Allow group ${local.auditor_group_name} to read load-balancers in tenancy",
        "Allow group ${local.auditor_group_name} to read buckets in tenancy",
        "Allow group ${local.auditor_group_name} to read nat-gateways in tenancy",
        "Allow group ${local.auditor_group_name} to read public-ips in tenancy",
        "Allow group ${local.auditor_group_name} to read file-family in tenancy",
        "Allow group ${local.auditor_group_name} to read instance-configurations in tenancy",
        "Allow Group ${local.auditor_group_name} to read network-security-groups in tenancy",
        "Allow Group ${local.auditor_group_name} to read resource-availability in tenancy",
        "Allow Group ${local.auditor_group_name} to read audit-events in tenancy",
        "Allow Group ${local.auditor_group_name} to read users in tenancy",
        "Allow Group ${local.auditor_group_name} to use cloud-shell in tenancy",
        "Allow Group ${local.auditor_group_name} to read vss-family in tenancy"]
    },
    (local.announcement_reader_policy_name) = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone ${local.announcement_reader_group_name}'s root compartment policy."
      statements = ["Allow group ${local.announcement_reader_group_name} to read announcements in tenancy",
      "Allow group ${local.announcement_reader_group_name} to use cloud-shell in tenancy"]
    },
    (local.cred_admin_policy_name) = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone ${local.cred_admin_group_name}'s root compartment policy."
      statements = ["Allow group ${local.cred_admin_group_name} to inspect users in tenancy",
        "Allow group ${local.cred_admin_group_name} to inspect groups in tenancy",
        "Allow group ${local.cred_admin_group_name} to manage users in tenancy  where any {request.operation = 'ListApiKeys',request.operation = 'ListAuthTokens',request.operation = 'ListCustomerSecretKeys',request.operation = 'UploadApiKey',request.operation = 'DeleteApiKey',request.operation = 'UpdateAuthToken',request.operation = 'CreateAuthToken',request.operation = 'DeleteAuthToken',request.operation = 'CreateSecretKey',request.operation = 'UpdateCustomerSecretKey',request.operation = 'DeleteCustomerSecretKey',request.operation = 'UpdateUserCapabilities'}",
      "Allow group ${local.cred_admin_group_name} to use cloud-shell in tenancy"]
    }
  } : {}
}

module "lz_policies" {
  source     = "../modules/iam/iam-policy"
  providers  = { oci = oci.home }
  depends_on = [module.lz_groups, module.lz_compartments] ### Explicitly declaring dependencies on the group and compartments modules.
  policies = {
    (local.network_admin_policy_name) = {
      compartment_id = local.parent_compartment_id
      description    = "Landing Zone policy for ${local.network_admin_group_name} group to manage network related services."
      statements = ["Allow group ${local.network_admin_group_name} to read all-resources in compartment ${local.network_compartment_name}",
        "Allow group ${local.network_admin_group_name} to manage virtual-network-family in compartment ${local.network_compartment_name}",
        "Allow group ${local.network_admin_group_name} to manage dns in compartment ${local.network_compartment_name}",
        "Allow group ${local.network_admin_group_name} to manage load-balancers in compartment ${local.network_compartment_name}",
        "Allow group ${local.network_admin_group_name} to manage alarms in compartment ${local.network_compartment_name}",
        "Allow group ${local.network_admin_group_name} to manage metrics in compartment ${local.network_compartment_name}",
        "Allow group ${local.network_admin_group_name} to manage orm-stacks in compartment ${local.network_compartment_name}",
        "Allow group ${local.network_admin_group_name} to manage orm-jobs in compartment ${local.network_compartment_name}",
        "Allow group ${local.network_admin_group_name} to manage orm-config-source-providers in compartment ${local.network_compartment_name}",
        "Allow Group ${local.network_admin_group_name} to read audit-events in compartment ${local.network_compartment_name}",
      "Allow Group ${local.network_admin_group_name} to read vss-family in compartment ${local.security_compartment_name}"]
    },
    (local.security_admin_policy_name) = {
      compartment_id = local.parent_compartment_id
      description    = "Landing Zone policy for ${local.security_admin_group_name} group to manage security related services in Landing Zone enclosing compartment (${local.policy_scope})."
      statements     = concat(local.security_enccmp_permissions, local.security_cmp_permissions)
    },
    (local.database_admin_policy_name) = {
      compartment_id = local.parent_compartment_id
      description    = "Landing Zone policy for ${local.database_admin_group_name} group to manage database related resources."
      statements = concat(["Allow group ${local.database_admin_group_name} to read all-resources in compartment ${local.database_compartment_name}",
        "Allow group ${local.database_admin_group_name} to manage database-family in compartment ${local.database_compartment_name}",
        "Allow group ${local.database_admin_group_name} to manage autonomous-database-family in compartment ${local.database_compartment_name}",
        "Allow group ${local.database_admin_group_name} to manage alarms in compartment ${local.database_compartment_name}",
        "Allow group ${local.database_admin_group_name} to manage metrics in compartment ${local.database_compartment_name}",
        "Allow group ${local.database_admin_group_name} to manage object-family in compartment ${local.database_compartment_name}",
        "Allow group ${local.database_admin_group_name} to use vnics in compartment ${local.database_compartment_name}",
        "Allow group ${local.database_admin_group_name} to use subnets in compartment ${local.database_compartment_name}",
        "Allow group ${local.database_admin_group_name} to use network-security-groups in compartment ${local.database_compartment_name}",
        "Allow group ${local.database_admin_group_name} to read virtual-network-family in compartment ${local.network_compartment_name}",
        "Allow group ${local.database_admin_group_name} to use vnics in compartment ${local.network_compartment_name}",
        "Allow group ${local.database_admin_group_name} to use subnets in compartment ${local.network_compartment_name}",
        "Allow group ${local.database_admin_group_name} to use network-security-groups in compartment ${local.network_compartment_name}",
        "Allow group ${local.database_admin_group_name} to manage orm-stacks in compartment ${local.database_compartment_name}",
        "Allow group ${local.database_admin_group_name} to manage orm-jobs in compartment ${local.database_compartment_name}",
        "Allow group ${local.database_admin_group_name} to manage orm-config-source-providers in compartment ${local.database_compartment_name}",
        "Allow group ${local.database_admin_group_name} to read audit-events in compartment ${local.database_compartment_name}",
        "Allow group ${local.database_admin_group_name} to read vss-family in compartment ${local.security_compartment_name}",
        "Allow group ${local.database_admin_group_name} to read vaults in compartment ${local.security_compartment_name}",
        "Allow group ${local.database_admin_group_name} to inspect keys in compartment ${local.security_compartment_name}"], 
        local.security_kms_database_permissions)
    },
    (local.appdev_admin_policy_name) = {
      compartment_id = local.parent_compartment_id
      description    = "Landing Zone policy for ${local.appdev_admin_group_name} group to manage app development related services."
      statements = ["Allow group ${local.appdev_admin_group_name} to read all-resources in compartment ${local.appdev_compartment_name}",
        "Allow group ${local.appdev_admin_group_name} to manage functions-family in compartment ${local.appdev_compartment_name}",
        "Allow group ${local.appdev_admin_group_name} to manage api-gateway-family in compartment ${local.appdev_compartment_name}",
        "Allow group ${local.appdev_admin_group_name} to manage ons-family in compartment ${local.appdev_compartment_name}",
        "Allow group ${local.appdev_admin_group_name} to manage streams in compartment ${local.appdev_compartment_name}",
        "Allow group ${local.appdev_admin_group_name} to manage cluster-family in compartment ${local.appdev_compartment_name}",
        "Allow group ${local.appdev_admin_group_name} to manage alarms in compartment ${local.appdev_compartment_name}",
        "Allow group ${local.appdev_admin_group_name} to manage metrics in compartment ${local.appdev_compartment_name}",
        "Allow group ${local.appdev_admin_group_name} to manage logs in compartment ${local.appdev_compartment_name}",
        "Allow group ${local.appdev_admin_group_name} to manage instance-family in compartment ${local.appdev_compartment_name}",
        "Allow group ${local.appdev_admin_group_name} to manage volume-family in compartment ${local.appdev_compartment_name}",
        "Allow group ${local.appdev_admin_group_name} to manage object-family in compartment ${local.appdev_compartment_name}",
        "Allow group ${local.appdev_admin_group_name} to read virtual-network-family in compartment ${local.network_compartment_name}",
        "Allow group ${local.appdev_admin_group_name} to use subnets in compartment ${local.network_compartment_name}",
        "Allow group ${local.appdev_admin_group_name} to use network-security-groups in compartment ${local.network_compartment_name}",
        "Allow group ${local.appdev_admin_group_name} to use vnics in compartment ${local.network_compartment_name}",
        "Allow group ${local.appdev_admin_group_name} to use load-balancers in compartment ${local.network_compartment_name}",
        "Allow group ${local.appdev_admin_group_name} to read autonomous-database-family in compartment ${local.database_compartment_name}",
        "Allow group ${local.appdev_admin_group_name} to read database-family in compartment ${local.database_compartment_name}",
        "Allow group ${local.appdev_admin_group_name} to read vaults in compartment ${local.security_compartment_name}",
        "Allow group ${local.appdev_admin_group_name} to inspect keys in compartment ${local.security_compartment_name}",
        "Allow group ${local.appdev_admin_group_name} to read app-catalog-listing in ${local.policy_scope}",
        "Allow group ${local.appdev_admin_group_name} to manage instance-images in compartment ${local.security_compartment_name}",
        "Allow group ${local.appdev_admin_group_name} to read instance-images in ${local.policy_scope}",
        "Allow group ${local.appdev_admin_group_name} to manage repos in compartment ${local.appdev_compartment_name}",
        "Allow group ${local.appdev_admin_group_name} to read repos in ${local.policy_scope}",
        "Allow group ${local.appdev_admin_group_name} to manage orm-stacks in compartment ${local.appdev_compartment_name}",
        "Allow group ${local.appdev_admin_group_name} to manage orm-jobs in compartment ${local.appdev_compartment_name}",
        "Allow group ${local.appdev_admin_group_name} to manage orm-config-source-providers in compartment ${local.appdev_compartment_name}",
        "Allow group ${local.appdev_admin_group_name} to read audit-events in compartment ${local.appdev_compartment_name}",
      "Allow group ${local.appdev_admin_group_name} to read vss-family in compartment ${local.security_compartment_name}"]
    },
    (local.iam_admin_policy_name) = {
      compartment_id = local.parent_compartment_id
      description    = "Landing Zone policy for ${local.iam_admin_group_name} group to manage IAM resources in Landing Zone enclosing compartment (${local.policy_scope})."
      statements     = local.iam_enccmp_permissions
    }
  }
}
