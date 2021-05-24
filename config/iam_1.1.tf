# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration provisions groups and policies allowing the management of specific services by specific admins on specific compartments.

################################################################################
### ################## Networking Service Artifacts ############################

### Networking service group
module "cis_network_admins" {
  count             = var.use_existing_iam_groups == false ? 1 : 0
  source            = "../modules/iam/iam-group"
  providers         = { oci = oci.home }
  tenancy_ocid      = var.tenancy_ocid
  group_name        = local.network_admin_group_name
  group_description = "Group responsible for managing networking in compartment ${local.network_compartment_name}."
  user_names        = []
}

### Networking service policy
module "cis_network_admins_policy" {
  source                = "../modules/iam/iam-policy"
  providers             = { oci = oci.home }
  depends_on            = [module.cis_network_admins, module.cis_compartments] ### Explicitly declaring dependencies on the group and compartments modules.
  policies              = {
    (local.network_admin_policy_name) = {
      compartment_id    = local.parent_compartment_id
      description       = "Policy allowing ${local.network_admin_group_name} group to manage network related services."
      statements        = ["Allow group ${local.network_admin_group_name} to read all-resources in compartment ${local.network_compartment_name}",
                          "Allow group ${local.network_admin_group_name} to manage virtual-network-family in compartment ${local.network_compartment_name}",
                          "Allow group ${local.network_admin_group_name} to manage dns in compartment ${local.network_compartment_name}",
                          "Allow group ${local.network_admin_group_name} to manage load-balancers in compartment ${local.network_compartment_name}",
                          "Allow group ${local.network_admin_group_name} to manage alarms in compartment ${local.network_compartment_name}",
                          "Allow group ${local.network_admin_group_name} to manage metrics in compartment ${local.network_compartment_name}",
                          "Allow group ${local.network_admin_group_name} to manage orm-stacks in compartment ${local.network_compartment_name}",
                          "Allow group ${local.network_admin_group_name} to manage orm-jobs in compartment ${local.network_compartment_name}",
                          "Allow group ${local.network_admin_group_name} to manage orm-config-source-providers in compartment ${local.network_compartment_name}",
                          "Allow Group ${local.network_admin_group_name} to read audit-events in compartment ${local.network_compartment_name}"]
    }
  }
}

################################################################################


################################################################################
############################ Security Service Artifacts #########################

### Security admin group
module "cis_security_admins" {
  count             = var.use_existing_iam_groups == false ? 1 : 0
  source            = "../modules/iam/iam-group"
  providers         = { oci = oci.home }
  tenancy_ocid      = var.tenancy_ocid
  group_name        = local.security_admin_group_name
  group_description = "Group responsible for managing security services in compartment ${local.security_compartment_name}."
  user_names        = []
}

locals {
  // Permissions to be created always at the root compartment
  security_root_permissions = ["Allow group ${local.security_admin_group_name} to manage cloudevents-rules in tenancy",
                          "Allow group ${local.security_admin_group_name} to manage cloud-guard-family in tenancy",
                          "Allow group ${local.security_admin_group_name} to read tenancies in tenancy",
                          "Allow group ${local.security_admin_group_name} to read objectstorage-namespaces in tenancy"]

  // Permissions to be created always at the enclosing compartment level, which *can* be the root compartment
  security_enccmp_permissions = ["Allow group ${local.security_admin_group_name} to manage tag-namespaces in ${local.policy_level}",
                          "Allow group ${local.security_admin_group_name} to manage tag-defaults in ${local.policy_level}",
                          "Allow group ${local.security_admin_group_name} to manage repos in ${local.policy_level}",
                          "Allow group ${local.security_admin_group_name} to read audit-events in ${local.policy_level}",
                          "Allow group ${local.security_admin_group_name} to read app-catalog-listing in ${local.policy_level}",
                          "Allow group ${local.security_admin_group_name} to read instance-images in ${local.policy_level}",
                          "Allow group ${local.security_admin_group_name} to inspect buckets in ${local.policy_level}"]                        

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
                          "Allow group ${local.security_admin_group_name} to manage orm-config-source-providers in compartment ${local.security_compartment_name}"]  
}

module "cis_security_admins_root_policy" {
  count      = local.use_existing_tenancy_policies == false ? 1 : 0
  source     = "../modules/iam/iam-policy"
  providers  = { oci = oci.home }
  depends_on = [module.cis_security_admins, module.cis_compartments] ### Explicitly declaring dependencies on the group and compartments modules.
  policies   = {
    (local.security_admin_root_policy_name) = {
      compartment_id    = var.tenancy_ocid
      description       = "Policy allowing ${local.security_admin_group_name} group to manage security related services at the root compartment."
      statements        = local.security_root_permissions
    }
  }
}
### Security admin policy
module "cis_security_admins_policy" {
  source                = "../modules/iam/iam-policy"
  providers             = { oci = oci.home }
  depends_on            = [module.cis_security_admins, module.cis_compartments] ### Explicitly declaring dependencies on the group and compartments modules.
  policies              = {
    (local.security_admin_policy_name) = {
      compartment_id    = local.parent_compartment_id
      description       = "Policy allowing ${local.security_admin_group_name} group to manage security related services in Landing Zone enclosing compartment (${local.policy_level})."
      statements        = concat(local.security_enccmp_permissions, local.security_cmp_permissions) 
    }
  }
}

################################################################################


################################################################################
########################### Database Service Artifacts #########################

### Database service - group for managing DBaaS and Autonomous Database.
module "cis_database_admins" {
  count             = var.use_existing_iam_groups == false ? 1 : 0
  source            = "../modules/iam/iam-group"
  providers         = { oci = oci.home }
  tenancy_ocid      = var.tenancy_ocid
  group_name        = local.database_admin_group_name
  group_description = "Group responsible for managing databases in compartment ${local.database_compartment_name}."
  user_names        = []
  }

### Database service policy
module "cis_database_admins_policy" {
  source                = "../modules/iam/iam-policy"
  providers             = { oci = oci.home }
  depends_on            = [module.cis_database_admins, module.cis_compartments] ### Explicitly declaring dependencies on the group and compartments modules.
  policies              = {
    (local.database_admin_policy_name) = {
      compartment_id    = local.parent_compartment_id
      description       = "Policy allowing ${local.database_admin_group_name} group to manage database related resources."
      statements        = ["Allow group ${local.database_admin_group_name} to read all-resources in compartment ${local.database_compartment_name}",
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
                          "Allow Group ${local.database_admin_group_name} to read audit-events in compartment ${local.database_compartment_name}"]
    }
  }
}

################################################################################


################################################################################
###################### App. Dev. Service Artifacts #############################

### Application Development services - Combined AppDev with Compute and storage
module "cis_appdev_admins" {
  count             = var.use_existing_iam_groups == false ? 1 : 0
  source            = "../modules/iam/iam-group"
  providers         = { oci = oci.home }
  tenancy_ocid      = var.tenancy_ocid
  group_name        = local.appdev_admin_group_name
  group_description = "Group responsible for managing app development related services in compartment ${local.appdev_compartment_name}."
  user_names        = []
  }

###  Application development services policy
module "cis_appdev_admins_policy" {
  source                = "../modules/iam/iam-policy"
  providers             = { oci = oci.home }
  depends_on            = [module.cis_appdev_admins, module.cis_compartments] ### Explicitly declaring dependencies on the group and compartments modules.
  policies              = {
    (local.appdev_admin_policy_name) = {
      compartment_id    = local.parent_compartment_id
      description       = "Policy allowing ${local.appdev_admin_group_name} group to manage app development related services."
      statements        = ["Allow group ${local.appdev_admin_group_name} to read all-resources in compartment ${local.appdev_compartment_name}",
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
                          "Allow group ${local.appdev_admin_group_name} to read app-catalog-listing in ${local.policy_level}",
                          "Allow group ${local.appdev_admin_group_name} to manage instance-images in compartment ${local.security_compartment_name}",
                          "Allow group ${local.appdev_admin_group_name} to read instance-images in ${local.policy_level}",
                          "Allow group ${local.appdev_admin_group_name} to manage repos in compartment ${local.appdev_compartment_name}",
                          "Allow group ${local.appdev_admin_group_name} to read repos in ${local.policy_level}",
                          "Allow group ${local.appdev_admin_group_name} to manage orm-stacks in compartment ${local.appdev_compartment_name}",
                          "Allow group ${local.appdev_admin_group_name} to manage orm-jobs in compartment ${local.appdev_compartment_name}",
                          "Allow group ${local.appdev_admin_group_name} to manage orm-config-source-providers in compartment ${local.appdev_compartment_name}",
                          "Allow Group ${local.appdev_admin_group_name} to read audit-events in compartment ${local.appdev_compartment_name}"]
    }
  }
}

################################################################################


################################################################################
########################### Audit Artifacts ####################################

### Auditors
module "cis_tenancy_auditors" {
  count             = var.use_existing_iam_groups == false ? 1 : 0
  source            = "../modules/iam/iam-group"
  providers         = { oci = oci.home }
  tenancy_ocid      = var.tenancy_ocid
  group_name        = local.auditor_group_name
  group_description = "Group responsible for Auditing the tenancy"
  user_names        = []
  }

### Auditors policy
module "cis_tenancy_auditors_policy" {
  count                 = local.use_existing_tenancy_policies == false ? 1 : 0
  source                = "../modules/iam/iam-policy"
  providers             = { oci = oci.home }
  depends_on            = [module.cis_tenancy_auditors] ### Explicitly declaring dependency on the group module.
  policies              = {
    (local.auditor_policy_name) = {
      compartment_id    = var.tenancy_ocid
      description       = "Policy allowing ${local.auditor_group_name} group to audit the Landing Zone."
      statements        = ["Allow group ${local.auditor_group_name} to inspect all-resources in tenancy",
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
                          "Allow Group ${local.auditor_group_name} to use cloud-shell in tenancy"]
    }
  }
}

################################################################################


################################################################################
######################## Announcement Artifacts #################################
 
### Announcement Readers group
module "cis_tenancy_announcement_readers" {
  count             = var.use_existing_iam_groups == false ? 1 : 0
  source            = "../modules/iam/iam-group"
  providers         = { oci = oci.home }
  tenancy_ocid      = var.tenancy_ocid
  group_name        = local.announcement_reader_group_name
  group_description = "Group responsible for Console Announcements"
  user_names        = []
  }

### Announcement Readers policy
module "cis_tenancy_announcement_readers_policy" {
  count                 = local.use_existing_tenancy_policies == false ? 1 : 0
  source                = "../modules/iam/iam-policy"
  providers             = { oci = oci.home }
  depends_on            = [module.cis_tenancy_announcement_readers] ### Explicitly declaring dependency on the group module.
  policies              = {
    (local.announcement_reader_policy_name) = {
      compartment_id         = var.tenancy_ocid
      description            = "Policy allowing ${local.announcement_reader_group_name} group to read announcements in tenancy."
      statements             = ["Allow group ${local.announcement_reader_group_name} to read announcements in tenancy"]
    }
  }
}

################################################################################

################################################################################
######################## Credential Admin Artifacts ############################

module "cis_cred_admins" {
  count             = var.use_existing_iam_groups == false ? 1 : 0
  source            = "../modules/iam/iam-group"
  providers         = { oci = oci.home }
  tenancy_ocid      = var.tenancy_ocid
  group_name        = local.cred_admin_group_name
  group_description = "Group responsible for managing users credentials in the tenancy."
  user_names        = []
}

module "cis_cred_admins_policy" {
  count             = local.use_existing_tenancy_policies == false ? 1 : 0
  source            = "../modules/iam/iam-policy"
  providers         = { oci = oci.home }
  depends_on        = [module.cis_cred_admins] ### Explicitly declaring dependency on the group module.
  policies          = {
    (local.cred_admin_policy_name) = {
      compartment_id = var.tenancy_ocid
      description    = "Policy allowing ${local.cred_admin_group_name} group to manage credentials in tenancy."
      statements     = ["Allow group ${local.cred_admin_group_name} to inspect users in tenancy",
                        "Allow group ${local.cred_admin_group_name} to inspect groups in tenancy",
                        "Allow group ${local.cred_admin_group_name} to manage users in tenancy  where any {request.operation = 'ListApiKeys',request.operation = 'ListAuthTokens',request.operation = 'ListCustomerSecretKeys',request.operation = 'UploadApiKey',request.operation = 'DeleteApiKey',request.operation = 'UpdateAuthToken',request.operation = 'CreateAuthToken',request.operation = 'DeleteAuthToken',request.operation = 'CreateSecretKey',request.operation = 'UpdateCustomerSecretKey',request.operation = 'DeleteCustomerSecretKey',request.operation = 'UpdateUserCapabilities'}"
                       ]
    }
  }
}
################################################################################