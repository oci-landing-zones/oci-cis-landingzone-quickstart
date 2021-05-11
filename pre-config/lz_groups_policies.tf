# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### Landing Zone tenancy level provisioning policy
module "lz_provisioning_tenancy_group_policy" {
  depends_on = [module.lz_top_compartment, module.lz_provisioning_group]
  source   = "../modules/iam/iam-policy"
  policies = {
    (local.provisioning_policy_name) = {
      compartment_id = var.tenancy_ocid
      description    = "Tenancy level policy allowing ${local.provisioning_group_name} group to provision the CIS Landing Zone."
      statements = ["Allow group ${local.provisioning_group_name} to read objectstorage-namespaces in tenancy", # ability to query for object store namespace for creating buckets
                    "Allow group ${local.provisioning_group_name} to use tag-namespaces in tenancy",            # ability to check the tag-namespaces at the tenancy level and to apply tag defaults
                    "Allow group ${local.provisioning_group_name} to read tag-defaults in tenancy",             # ability to check for tag-defaults at the tenancy level
                    "Allow group ${local.provisioning_group_name} to manage cloudevents-rules in tenancy",      # for events: create IAM event rules at the tenancy level 
                    "Allow group ${local.provisioning_group_name} to inspect compartments in tenancy",          # for events: access to resources in compartments to select rules actions
                    "Allow group ${local.provisioning_group_name} to manage cloud-guard-family in tenancy"]     # ability to enable Cloud Guard, which can be done only at the tenancy level
    }
  }
}

### Landing Zone compartment level provisioning policy
module "lz_provisioning_topcmp_group_policy" {
  depends_on = [module.lz_top_compartment, module.lz_provisioning_group]
  source   = "../modules/iam/iam-policy"
  policies = {
    (local.provisioning_policy_name) = {
      compartment_id = module.lz_top_compartment.compartments[local.top_compartment_name].id
      description    = "Compartment level policy allowing ${local.provisioning_group_name} group to provision the CIS Landing Zone."
      statements = ["Allow group ${local.provisioning_group_name} to manage compartments in compartment ${local.top_compartment_name}",
                    "Allow group ${local.provisioning_group_name} to manage policies in compartment ${local.top_compartment_name}",
                    "Allow group ${local.provisioning_group_name} to manage virtual-network-family in compartment ${local.top_compartment_name}",
                    "Allow group ${local.provisioning_group_name} to manage logging-family in compartment ${local.top_compartment_name}",
                    "Allow group ${local.provisioning_group_name} to manage tag-namespaces in compartment ${local.top_compartment_name}",
                    "Allow group ${local.provisioning_group_name} to manage tag-defaults in compartment ${local.top_compartment_name}",
                    "Allow group ${local.provisioning_group_name} to manage object-family in compartment ${local.top_compartment_name}",
                    "Allow group ${local.provisioning_group_name} to manage vaults in compartment ${local.top_compartment_name}",
                    "Allow group ${local.provisioning_group_name} to manage keys in compartment ${local.top_compartment_name}",
                    "Allow group ${local.provisioning_group_name} to use key-delegate in compartment ${local.top_compartment_name}",
                    "Allow group ${local.provisioning_group_name} to manage ons-family in compartment ${local.top_compartment_name}",
                    "Allow group ${local.provisioning_group_name} to manage vss-family in compartment ${local.top_compartment_name}"]
    }
  }
}

### Landing Zone security admin policy
module "lz_groups_policy" {
  depends_on = [module.lz_security_admin_group, module.lz_appdev_admin_group, module.lz_network_admin_group, module.lz_database_admin_group, module.lz_auditor_group]
  count      = var.create_tenancy_level_policies == true ? 1 : 0
  source     = "../modules/iam/iam-policy"
  policies   = {
    (local.tenancy_level_policy_name) = {
      compartment_id    = var.tenancy_ocid
      description       = "Tenancy level policies for Landing Zone groups."
      statements        = [
                          # Security admin
                          "Allow group ${local.security_admin_group_name} to manage cloudevents-rules in tenancy",
                          "Allow group ${local.security_admin_group_name} to manage tag-namespaces in tenancy",
                          "Allow group ${local.security_admin_group_name} to manage tag-defaults in tenancy",
                          "Allow group ${local.security_admin_group_name} to manage cloud-guard-family in tenancy",
                          "Allow group ${local.security_admin_group_name} to manage repos in tenancy",
                          "Allow group ${local.security_admin_group_name} to read audit-events in tenancy",
                          "Allow group ${local.security_admin_group_name} to read tenancies in tenancy",
                          "Allow group ${local.security_admin_group_name} to read objectstorage-namespaces in tenancy",
                          "Allow group ${local.security_admin_group_name} to read app-catalog-listing in tenancy",
                          "Allow group ${local.security_admin_group_name} to read instance-images in tenancy",
                          "Allow group ${local.security_admin_group_name} to inspect buckets in tenancy",
                          # AppDev admin
                          "Allow group ${local.appdev_admin_group_name} to read repos in tenancy",
                          "Allow group ${local.appdev_admin_group_name} to read objectstorage-namespaces in tenancy",
                          "Allow group ${local.appdev_admin_group_name} to read app-catalog-listing in tenancy",
                          "Allow group ${local.appdev_admin_group_name} to read instance-images in tenancy",
                          # Network admin
                          "Allow group ${local.network_admin_group_name} to read repos in tenancy",
                          "Allow group ${local.network_admin_group_name} to read objectstorage-namespaces in tenancy",
                          "Allow group ${local.network_admin_group_name} to read app-catalog-listing in tenancy",
                          "Allow group ${local.network_admin_group_name} to read instance-images in tenancy",
                          # Database admin
                          "Allow group ${local.database_admin_group_name} to read repos in tenancy",
                          "Allow group ${local.database_admin_group_name} to read objectstorage-namespaces in tenancy",
                          "Allow group ${local.database_admin_group_name} to read app-catalog-listing in tenancy",
                          "Allow group ${local.database_admin_group_name} to read instance-images in tenancy",
                          # Cred admin
                          "Allow group ${local.cred_admin_group_name} to inspect users in tenancy",
                          "Allow group ${local.cred_admin_group_name} to inspect groups in tenancy",
                          "Allow group ${local.cred_admin_group_name} to manage users in tenancy where any {request.operation = 'ListApiKeys', request.operation = 'ListAuthTokens', request.operation = 'ListCustomerSecretKeys', request.operation = 'UploadApiKey', request.operation = 'DeleteApiKey', request.operation = 'UpdateAuthToken', request.operation = 'CreateAuthToken', request.operation = 'DeleteAuthToken', request.operation = 'CreateSecretKey', request.operation = 'UpdateCustomerSecretKey', request.operation = 'DeleteCustomerSecretKey', request.operation = 'UpdateUserCapabilities'}",
                          # IAM admin
                          "Allow group ${local.iam_admin_group_name} to inspect users in tenancy",
                          "Allow group ${local.iam_admin_group_name} to inspect groups in tenancy",
                          "Allow group ${local.iam_admin_group_name} to manage groups in tenancy where all {target.group.name != 'Administrators', target.group.name != '${local.cred_admin_group_name}'}",
                          "Allow group ${local.iam_admin_group_name} to inspect identity-providers in tenancy",
                          "Allow group ${local.iam_admin_group_name} to manage identity-providers in tenancy where any {request.operation = 'AddIdpGroupMapping', request.operation = 'DeleteIdpGroupMapping'}",
                          "Allow group ${local.iam_admin_group_name} to manage dynamic-groups in tenancy",
                          "Allow group ${local.iam_admin_group_name} to manage authentication-policies in tenancy",
                          "Allow group ${local.iam_admin_group_name} to manage network-sources in tenancy",
                          "Allow group ${local.iam_admin_group_name} to manage quota in tenancy",
                          "Allow group ${local.iam_admin_group_name} to read audit-events in tenancy",
                          # Auditor
                          "Allow group ${local.auditor_group_name} to read repos in tenancy",
                          "Allow group ${local.auditor_group_name} to read objectstorage-namespaces in tenancy",
                          "Allow group ${local.auditor_group_name} to read app-catalog-listing in tenancy",
                          "Allow group ${local.auditor_group_name} to read instance-images in tenancy",
                          "Allow group ${local.auditor_group_name} to inspect buckets in tenancy",
                          # Announcement reader
                          "Allow group ${local.announcement_reader_group_name} to read announcements in tenancy"]
    }
  }
}