# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### Landing Zone tenancy level provisioning policy
module "lz_provisioning_tenancy_group_policy" {
  for_each   = local.provisioning_group_names
  depends_on = [null_resource.slow_down_groups]
  source     = "../modules/iam/iam-policy"
  policies = {
    "${each.key}-provisioning-root-policy" = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone provisioning policy."
      statements = ["Allow group ${each.value.group_name} to read objectstorage-namespaces in tenancy", # ability to query for object store namespace for creating buckets
        "Allow group ${each.value.group_name} to use tag-namespaces in tenancy",                        # ability to check the tag-namespaces at the tenancy level and to apply tag defaults
        "Allow group ${each.value.group_name} to read tag-defaults in tenancy",                         # ability to check for tag-defaults at the tenancy level
        "Allow group ${each.value.group_name} to manage cloudevents-rules in tenancy",                  # for events: create IAM event rules at the tenancy level 
        "Allow group ${each.value.group_name} to inspect compartments in tenancy",                      # for events: access to resources in compartments to select rules actions
        "Allow group ${each.value.group_name} to manage cloud-guard-family in tenancy",                 # ability to enable Cloud Guard, which can be done only at the tenancy level
        "Allow group ${each.value.group_name} to read groups in tenancy",                               # for groups lookup 
        "Allow group ${each.value.group_name} to inspect tenancies in tenancy",                         # for home region lookup
      "Allow group ${each.value.group_name} to inspect users in tenancy"]                               # for users lookup
    }
  }
}

### Landing Zone compartment level provisioning policy
module "lz_provisioning_topcmp_group_policy" {
  for_each   = length(local.enclosing_compartments) > 0 ? local.provisioning_group_names : {}
  depends_on = [null_resource.slow_down_compartments, null_resource.slow_down_groups]
  source     = "../modules/iam/iam-policy"
  policies = {
    "${each.key}-provisioning-policy" = {
      compartment_id = module.lz_top_compartments.compartments[each.key].id
      description    = "Landing Zone provisioning policy for ${each.key} compartment."
      statements     = ["Allow group ${each.value.group_name} to manage all-resources in compartment ${each.key}"]
    }
  }
}

### Landing Zone mgmt policy
module "lz_groups_mgmt_policy" {
  depends_on = [null_resource.slow_down_groups]
  for_each   = local.grant_tenancy_level_mgmt_policies == true ? local.lz_group_names : {}
  source     = "../modules/iam/iam-policy"
  policies = {
    "${each.key}-mgmt-root-policy" = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone groups management root policy."
      statements = [
        # Security admin
        "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to manage cloudevents-rules in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to manage tag-namespaces in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to manage tag-defaults in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to manage cloud-guard-family in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to manage repos in tenancy",
        # Cred admin
        "Allow group ${each.value.group_name_prefix}${local.cred_admin_group_name_suffix} to manage users in tenancy where any {request.operation = 'ListApiKeys', request.operation = 'ListAuthTokens', request.operation = 'ListCustomerSecretKeys', request.operation = 'UploadApiKey', request.operation = 'DeleteApiKey', request.operation = 'UpdateAuthToken', request.operation = 'CreateAuthToken', request.operation = 'DeleteAuthToken', request.operation = 'CreateSecretKey', request.operation = 'UpdateCustomerSecretKey', request.operation = 'DeleteCustomerSecretKey', request.operation = 'UpdateUserCapabilities'}",
        # IAM admin
      "Allow group ${each.value.group_name_prefix}${local.iam_admin_group_name_suffix} to manage groups in tenancy where all {target.group.name != 'Administrators', target.group.name != '${each.value.group_name_prefix}${local.cred_admin_group_name_suffix}'}"]
    }
  }
}

### Landing Zone read-only policy
module "lz_groups_read_only_policy" {
  depends_on = [null_resource.slow_down_groups]
  for_each   = local.lz_group_names
  source     = "../modules/iam/iam-policy"
  policies = {
    "${each.key}-read-only-root-policy" = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone groups read-only root policy."
      statements = [
        # Security admin
        "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to read audit-events in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to read tenancies in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to read objectstorage-namespaces in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to read app-catalog-listing in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to read instance-images in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to inspect buckets in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to use cloud-shell in tenancy",
        # AppDev admin
        "Allow group ${each.value.group_name_prefix}${local.appdev_admin_group_name_suffix} to read repos in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.appdev_admin_group_name_suffix} to read objectstorage-namespaces in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.appdev_admin_group_name_suffix} to read app-catalog-listing in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.appdev_admin_group_name_suffix} to read instance-images in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.appdev_admin_group_name_suffix} to use cloud-shell in tenancy",
        # Network admin
        "Allow group ${each.value.group_name_prefix}${local.network_admin_group_name_suffix} to read repos in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.network_admin_group_name_suffix} to read objectstorage-namespaces in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.network_admin_group_name_suffix} to read app-catalog-listing in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.network_admin_group_name_suffix} to read instance-images in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.network_admin_group_name_suffix} to use cloud-shell in tenancy",
        # Database admin
        "Allow group ${each.value.group_name_prefix}${local.database_admin_group_name_suffix} to read repos in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.database_admin_group_name_suffix} to read objectstorage-namespaces in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.database_admin_group_name_suffix} to read app-catalog-listing in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.database_admin_group_name_suffix} to read instance-images in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.database_admin_group_name_suffix} to use cloud-shell in tenancy",
        # Cred admin
        "Allow group ${each.value.group_name_prefix}${local.cred_admin_group_name_suffix} to inspect users in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.cred_admin_group_name_suffix} to inspect groups in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.cred_admin_group_name_suffix} to use cloud-shell in tenancy",
        # IAM admin
        "Allow group ${each.value.group_name_prefix}${local.iam_admin_group_name_suffix} to inspect users in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.iam_admin_group_name_suffix} to inspect groups in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.iam_admin_group_name_suffix} to inspect identity-providers in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.iam_admin_group_name_suffix} to read audit-events in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.iam_admin_group_name_suffix} to use cloud-shell in tenancy",
        # Auditor
        "Allow group ${each.value.group_name_prefix}${local.auditor_group_name_suffix} to read repos in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.auditor_group_name_suffix} to read objectstorage-namespaces in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.auditor_group_name_suffix} to read app-catalog-listing in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.auditor_group_name_suffix} to read instance-images in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.auditor_group_name_suffix} to read users in tenancy",

        "Allow group ${each.value.group_name_prefix}${local.auditor_group_name_suffix} to inspect buckets in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.auditor_group_name_suffix} to use cloud-shell in tenancy",
        # Announcement reader
        "Allow group ${each.value.group_name_prefix}${local.announcement_reader_group_name_suffix} to read announcements in tenancy",
      "Allow group ${each.value.group_name_prefix}${local.announcement_reader_group_name_suffix} to use cloud-shell in tenancy", ]
    }
  }
}

### Landing Zone compartment level Dynamic Group policy
module "lz_provisioning_topcmp_dynamic_group_policy" {
  for_each   = local.enclosing_compartments
  depends_on = [null_resource.slow_down_compartments, null_resource.slow_down_groups]
  source     = "../modules/iam/iam-policy"
  policies = {
    "${each.key}-adb-kms-policy" = {
      compartment_id = module.lz_top_compartments.compartments[each.key].id
      description    = "Landing Zone provisioning policy ADB to access vaults and keys in ${each.key} compartment."
      statements     = ["Allow dynamic-group ${each.key}-adb-dynamic-group to manage vaults in compartment ${each.key}",
      "Allow dynamic-group ${each.key}-adb-dynamic-group to manage keys in compartment ${each.key}"]
    }
  }
}

resource "null_resource" "slow_down_compartments" {
  depends_on = [module.lz_top_compartments]
  provisioner "local-exec" {
    command = "sleep 30" # Wait 30 seconds for compartments to be available.
  }
}

resource "null_resource" "slow_down_groups" {
  depends_on = [module.lz_groups, module.lz_provisioning_groups]
  provisioner "local-exec" {
    command = "sleep 30" # Wait 30 seconds for compartments to be available.
  }
}