# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### Landing Zone tenancy level provisioning policy
module "lz_provisioning_tenancy_group_policy" {
  for_each   = local.provisioning_group_names_t
  depends_on = [module.lz_top_compartments, module.lz_provisioning_groups]
  source   = "../modules/iam/iam-policy"
  policies = {
    "${each.value.group_name}-tenancy-policy" = {
      compartment_id = var.tenancy_ocid
      description    = "Tenancy level policy allowing ${each.value.group_name} group to provision the CIS Landing Zone."
      statements = ["Allow group ${each.value.group_name} to read objectstorage-namespaces in tenancy", # ability to query for object store namespace for creating buckets
                    "Allow group ${each.value.group_name} to use tag-namespaces in tenancy",            # ability to check the tag-namespaces at the tenancy level and to apply tag defaults
                    "Allow group ${each.value.group_name} to read tag-defaults in tenancy",             # ability to check for tag-defaults at the tenancy level
                    "Allow group ${each.value.group_name} to manage cloudevents-rules in tenancy",      # for events: create IAM event rules at the tenancy level 
                    "Allow group ${each.value.group_name} to inspect compartments in tenancy",          # for events: access to resources in compartments to select rules actions
                    "Allow group ${each.value.group_name} to manage cloud-guard-family in tenancy"]     # ability to enable Cloud Guard, which can be done only at the tenancy level
    }
  }
}

### Landing Zone compartment level provisioning policy
module "lz_provisioning_topcmp_group_policy" {
  for_each   = local.provisioning_group_names
  depends_on = [module.lz_top_compartments, module.lz_provisioning_groups]
  source   = "../modules/iam/iam-policy"
  policies = {
    "${each.value.group_name}-cmp-policy" = {
      compartment_id = module.lz_top_compartments.compartments[each.key].id
      description    = "Compartment level policy allowing ${each.value.group_name} group to provision the CIS Landing Zone in ${each.key} compartment."
      statements = ["Allow group ${each.value.group_name} to manage compartments in compartment ${each.key}",
                    "Allow group ${each.value.group_name} to manage policies in compartment ${each.key}",
                    "Allow group ${each.value.group_name} to manage virtual-network-family in compartment ${each.key}",
                    "Allow group ${each.value.group_name} to manage logging-family in compartment ${each.key}",
                    "Allow group ${each.value.group_name} to manage tag-namespaces in compartment ${each.key}",
                    "Allow group ${each.value.group_name} to manage tag-defaults in compartment ${each.key}",
                    "Allow group ${each.value.group_name} to manage object-family in compartment ${each.key}",
                    "Allow group ${each.value.group_name} to manage vaults in compartment ${each.key}",
                    "Allow group ${each.value.group_name} to manage keys in compartment ${each.key}",
                    "Allow group ${each.value.group_name} to use key-delegate in compartment ${each.key}",
                    "Allow group ${each.value.group_name} to manage ons-family in compartment ${each.key}",
                    "Allow group ${each.value.group_name} to manage vss-family in compartment ${each.key}"]
    }
  }
}

### Landing Zone security admin policy
module "lz_groups_policy" {
  depends_on = [module.lz_iam_admin_groups, module.lz_cred_admin_groups, module.lz_security_admin_groups, module.lz_appdev_admin_groups, module.lz_network_admin_groups, module.lz_database_admin_groups, module.lz_auditor_groups, module.lz_announcement_reader_groups]
  for_each   = var.create_tenancy_level_policies == true ? local.lz_group_names : tomap([])
  source     = "../modules/iam/iam-policy"
  policies   = {
    "${each.key}-policy" = {
      compartment_id    = var.tenancy_ocid
      description       = "Tenancy level policies for Landing Zone groups."
      statements        = [
                          # Security admin
                          "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to manage cloudevents-rules in tenancy",
                          "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to manage tag-namespaces in tenancy",
                          "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to manage tag-defaults in tenancy",
                          "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to manage cloud-guard-family in tenancy",
                          "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to manage repos in tenancy",
                          "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to read audit-events in tenancy",
                          "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to read tenancies in tenancy",
                          "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to read objectstorage-namespaces in tenancy",
                          "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to read app-catalog-listing in tenancy",
                          "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to read instance-images in tenancy",
                          "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to inspect buckets in tenancy",
                          # AppDev admin
                          "Allow group ${each.value.group_name_prefix}${local.appdev_admin_group_name_suffix} to read repos in tenancy",
                          "Allow group ${each.value.group_name_prefix}${local.appdev_admin_group_name_suffix} to read objectstorage-namespaces in tenancy",
                          "Allow group ${each.value.group_name_prefix}${local.appdev_admin_group_name_suffix} to read app-catalog-listing in tenancy",
                          "Allow group ${each.value.group_name_prefix}${local.appdev_admin_group_name_suffix} to read instance-images in tenancy",
                          # Network admin
                          "Allow group ${each.value.group_name_prefix}${local.network_admin_group_name_suffix} to read repos in tenancy",
                          "Allow group ${each.value.group_name_prefix}${local.network_admin_group_name_suffix} to read objectstorage-namespaces in tenancy",
                          "Allow group ${each.value.group_name_prefix}${local.network_admin_group_name_suffix} to read app-catalog-listing in tenancy",
                          "Allow group ${each.value.group_name_prefix}${local.network_admin_group_name_suffix} to read instance-images in tenancy",
                          # Database admin
                          "Allow group ${each.value.group_name_prefix}${local.database_admin_group_name_suffix} to read repos in tenancy",
                          "Allow group ${each.value.group_name_prefix}${local.database_admin_group_name_suffix} to read objectstorage-namespaces in tenancy",
                          "Allow group ${each.value.group_name_prefix}${local.database_admin_group_name_suffix} to read app-catalog-listing in tenancy",
                          "Allow group ${each.value.group_name_prefix}${local.database_admin_group_name_suffix} to read instance-images in tenancy",
                          # Cred admin
                          "Allow group ${each.value.group_name_prefix}${local.cred_admin_group_name_suffix} to inspect users in tenancy",
                          "Allow group ${each.value.group_name_prefix}${local.cred_admin_group_name_suffix} to inspect groups in tenancy",
                          "Allow group ${each.value.group_name_prefix}${local.cred_admin_group_name_suffix} to manage users in tenancy where any {request.operation = 'ListApiKeys', request.operation = 'ListAuthTokens', request.operation = 'ListCustomerSecretKeys', request.operation = 'UploadApiKey', request.operation = 'DeleteApiKey', request.operation = 'UpdateAuthToken', request.operation = 'CreateAuthToken', request.operation = 'DeleteAuthToken', request.operation = 'CreateSecretKey', request.operation = 'UpdateCustomerSecretKey', request.operation = 'DeleteCustomerSecretKey', request.operation = 'UpdateUserCapabilities'}",
                          # IAM admin
                          "Allow group ${each.value.group_name_prefix}${local.iam_admin_group_name_suffix} to inspect users in tenancy",
                          "Allow group ${each.value.group_name_prefix}${local.iam_admin_group_name_suffix} to inspect groups in tenancy",
                          "Allow group ${each.value.group_name_prefix}${local.iam_admin_group_name_suffix} to manage groups in tenancy where all {target.group.name != 'Administrators', target.group.name != '${each.value.group_name_prefix}${local.cred_admin_group_name_suffix}'}",
                          "Allow group ${each.value.group_name_prefix}${local.iam_admin_group_name_suffix} to inspect identity-providers in tenancy",
                          "Allow group ${each.value.group_name_prefix}${local.iam_admin_group_name_suffix} to manage identity-providers in tenancy where any {request.operation = 'AddIdpGroupMapping', request.operation = 'DeleteIdpGroupMapping'}",
                          "Allow group ${each.value.group_name_prefix}${local.iam_admin_group_name_suffix} to manage dynamic-groups in tenancy",
                          "Allow group ${each.value.group_name_prefix}${local.iam_admin_group_name_suffix} to manage authentication-policies in tenancy",
                          "Allow group ${each.value.group_name_prefix}${local.iam_admin_group_name_suffix} to manage network-sources in tenancy",
                          "Allow group ${each.value.group_name_prefix}${local.iam_admin_group_name_suffix} to manage quota in tenancy",
                          "Allow group ${each.value.group_name_prefix}${local.iam_admin_group_name_suffix} to read audit-events in tenancy",
                          # Auditor
                          "Allow group ${each.value.group_name_prefix}${local.auditor_group_name_suffix} to read repos in tenancy",
                          "Allow group ${each.value.group_name_prefix}${local.auditor_group_name_suffix} to read objectstorage-namespaces in tenancy",
                          "Allow group ${each.value.group_name_prefix}${local.auditor_group_name_suffix} to read app-catalog-listing in tenancy",
                          "Allow group ${each.value.group_name_prefix}${local.auditor_group_name_suffix} to read instance-images in tenancy",
                          "Allow group ${each.value.group_name_prefix}${local.auditor_group_name_suffix} to inspect buckets in tenancy",
                          # Announcement reader
                          "Allow group ${each.value.group_name_prefix}${local.announcement_reader_group_name_suffix} to read announcements in tenancy"]
    }
  }
}