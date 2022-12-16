# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### Landing Zone tenancy level provisioning policy

locals {
  all_groups_policies_defined_tags = {}
  all_groups_policies_freeform_tags = {}

  default_groups_policies_defined_tags = null
  default_groups_policies_freeform_tags = local.landing_zone_tags

  groups_policies_defined_tags = length(local.all_groups_policies_defined_tags) > 0 ? local.all_groups_policies_defined_tags : local.default_groups_policies_defined_tags
  groups_policies_freeform_tags  = length(local.all_groups_policies_freeform_tags) > 0 ? merge(local.all_groups_policies_freeform_tags, local.default_groups_policies_freeform_tags) : local.default_groups_policies_freeform_tags
}

module "lz_provisioning_tenancy_group_policy" {
  for_each   = local.provisioning_group_names
  depends_on = [null_resource.slow_down_groups]
  source     = "../modules/iam/iam-policy"
  policies = {
    "${each.key}-provisioning-root-policy" = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone provisioning policy."
      defined_tags   = local.groups_policies_defined_tags
      freeform_tags  = local.groups_policies_freeform_tags
      statements = ["Allow group ${each.value.group_name} to read objectstorage-namespaces in tenancy", # ability to query for object store namespace for creating buckets
        "Allow group ${each.value.group_name} to use tag-namespaces in tenancy",                        # ability to check the tag-namespaces at the tenancy level and to apply tag defaults
        "Allow group ${each.value.group_name} to read tag-defaults in tenancy",                         # ability to check for tag-defaults at the tenancy level
        "Allow group ${each.value.group_name} to manage cloudevents-rules in tenancy",                  # for events: create IAM event rules at the tenancy level 
        "Allow group ${each.value.group_name} to inspect compartments in tenancy",                      # for events: access to resources in compartments to select rules actions
        "Allow group ${each.value.group_name} to manage cloud-guard-family in tenancy",                 # ability to enable Cloud Guard, which can be done only at the tenancy level
        "Allow group ${each.value.group_name} to read groups in tenancy",                               # for groups lookup 
        "Allow group ${each.value.group_name} to read dynamic-groups in tenancy",                       # for dynamic-groups lookup        
        "Allow group ${each.value.group_name} to inspect tenancies in tenancy",                         # for home region lookup
        "Allow group ${each.value.group_name} to manage usage-budgets in tenancy",                      # for budget creation   
        "Allow group ${each.value.group_name} to inspect users in tenancy"]                             # for users lookup
    }
  }
}

### Landing Zone compartment level provisioning policy
module "lz_provisioning_topcmp_group_policy" {
  for_each   = length(local.enclosing_compartments) > 0 ? local.enclosing_compartments : {}
  depends_on = [null_resource.slow_down_compartments, null_resource.slow_down_groups]
  source     = "../modules/iam/iam-policy"
  policies = {
    "${each.value.name}-provisioning-policy" = {
      compartment_id = module.lz_top_compartments.compartments[each.key].id
      description    = "Landing Zone provisioning policy for ${each.value.name} compartment."
      statements     = var.use_existing_provisioning_group == true ? ["Allow group ${var.existing_provisioning_group_name} to manage all-resources in compartment ${each.value.name}"] : ["Allow group ${each.key}-provisioning-group to manage all-resources in compartment ${each.value.name}"]
      defined_tags   = local.groups_policies_defined_tags
      freeform_tags  = local.groups_policies_freeform_tags
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
      defined_tags   = local.groups_policies_defined_tags
      freeform_tags  = local.groups_policies_freeform_tags
      statements = [
        # Cost Admin - Access to Cost Reports 
        "define tenancy usage-report as ocid1.tenancy.oc1..aaaaaaaaned4fkpkisbwjlr56u7cj63lf3wffbilvqknstgtvzub7vhqkggq", 
        # Security admin
        "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to manage cloudevents-rules in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to manage tag-namespaces in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to manage tag-defaults in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to manage cloud-guard-family in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to read threat-intel-family in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to manage repos in tenancy",
        # Cred admin
        "Allow group ${each.value.group_name_prefix}${local.cred_admin_group_name_suffix} to manage users in tenancy where any {request.operation = 'ListApiKeys', request.operation = 'ListAuthTokens', request.operation = 'ListCustomerSecretKeys', request.operation = 'UploadApiKey', request.operation = 'DeleteApiKey', request.operation = 'UpdateAuthToken', request.operation = 'CreateAuthToken', request.operation = 'DeleteAuthToken', request.operation = 'CreateSecretKey', request.operation = 'UpdateCustomerSecretKey', request.operation = 'DeleteCustomerSecretKey', request.operation = 'UpdateUserCapabilities'}",
        # IAM admin
        "Allow group ${each.value.group_name_prefix}${local.iam_admin_group_name_suffix} to manage groups in tenancy where all {target.group.name != 'Administrators', target.group.name != '${each.value.group_name_prefix}${local.cred_admin_group_name_suffix}'}",
        # Cost Admin
        "Allow group ${each.value.group_name_prefix}${local.cost_admin_group_name_suffix} to manage usage-report in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.cost_admin_group_name_suffix} to manage usage-budgets in tenancy", 
        "endorse group ${each.value.group_name_prefix}${local.cost_admin_group_name_suffix} to read objects in tenancy usage-report"]
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
      defined_tags   = local.groups_policies_defined_tags
      freeform_tags  = local.groups_policies_freeform_tags
      statements = [
        # Security admin
        "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to read audit-events in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to read tenancies in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to read objectstorage-namespaces in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to read app-catalog-listing in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to read instance-images in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to inspect buckets in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to use cloud-shell in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to read usage-budgets in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.security_admin_group_name_suffix} to read usage-reports in tenancy",                
        # AppDev admin
        "Allow group ${each.value.group_name_prefix}${local.appdev_admin_group_name_suffix} to read repos in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.appdev_admin_group_name_suffix} to read objectstorage-namespaces in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.appdev_admin_group_name_suffix} to read app-catalog-listing in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.appdev_admin_group_name_suffix} to read instance-images in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.appdev_admin_group_name_suffix} to use cloud-shell in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.appdev_admin_group_name_suffix} to read usage-budgets in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.appdev_admin_group_name_suffix} to read usage-reports in tenancy",                        
        # Network admin
        "Allow group ${each.value.group_name_prefix}${local.network_admin_group_name_suffix} to read repos in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.network_admin_group_name_suffix} to read objectstorage-namespaces in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.network_admin_group_name_suffix} to read app-catalog-listing in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.network_admin_group_name_suffix} to read instance-images in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.network_admin_group_name_suffix} to use cloud-shell in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.network_admin_group_name_suffix} to read usage-budgets in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.network_admin_group_name_suffix} to read usage-reports in tenancy",                        
        # Database admin
        "Allow group ${each.value.group_name_prefix}${local.database_admin_group_name_suffix} to read repos in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.database_admin_group_name_suffix} to read objectstorage-namespaces in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.database_admin_group_name_suffix} to read app-catalog-listing in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.database_admin_group_name_suffix} to read instance-images in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.database_admin_group_name_suffix} to use cloud-shell in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.database_admin_group_name_suffix} to read usage-budgets in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.database_admin_group_name_suffix} to read usage-reports in tenancy",                        
        "Allow group ${each.value.group_name_prefix}${local.database_admin_group_name_suffix} to read data-safe-family in tenancy",
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
        # Announcement reader
        "Allow group ${each.value.group_name_prefix}${local.announcement_reader_group_name_suffix} to read announcements in tenancy",
      "Allow group ${each.value.group_name_prefix}${local.announcement_reader_group_name_suffix} to use cloud-shell in tenancy", ]
    }
    "${each.key}-auditor-root-policy" = {
      compartment_id = var.tenancy_ocid
      description    = "CIS Landing Zone groups auditor root policy."
      defined_tags   = local.groups_policies_defined_tags
      freeform_tags  = local.groups_policies_freeform_tags
      statements = [
        # Auditor
        "Allow group ${each.value.group_name_prefix}${local.auditor_group_name_suffix} to inspect all-resources in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.auditor_group_name_suffix} to read repos in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.auditor_group_name_suffix} to read objectstorage-namespaces in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.auditor_group_name_suffix} to read app-catalog-listing in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.auditor_group_name_suffix} to read instance-images in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.auditor_group_name_suffix} to read users in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.auditor_group_name_suffix} to inspect buckets in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.auditor_group_name_suffix} to use cloud-shell in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.auditor_group_name_suffix} to read usage-budgets in tenancy",
        "Allow group ${each.value.group_name_prefix}${local.auditor_group_name_suffix} to read usage-reports in tenancy",                        
        "Allow group ${each.value.group_name_prefix}${local.auditor_group_name_suffix} to read data-safe-family in tenancy"
      ]
    }
  }
}

### Landing Zone compartment level Dynamic Group policy
module "lz_provisioning_topcmp_dynamic_group_policy" {
  for_each   = local.enclosing_compartments
  depends_on = [null_resource.slow_down_compartments, null_resource.slow_down_groups]
  source     = "../modules/iam/iam-policy"
  policies = {
    "${each.value.name}-adb-kms-policy" = {
      compartment_id = module.lz_top_compartments.compartments[each.key].id
      description    = "Landing Zone provisioning policy for managing vaults and keys in ${each.value.name} compartment."
      defined_tags   = local.groups_policies_defined_tags
      freeform_tags  = local.groups_policies_freeform_tags
      statements     = length(trimspace(var.existing_database_kms_dyn_group_name)) > 0 ? ["Allow dynamic-group ${var.existing_database_kms_dyn_group_name} to manage vaults in compartment ${each.value.name}","Allow dynamic-group ${var.existing_database_kms_dyn_group_name} to manage keys in compartment ${each.value.name}"] : ["Allow dynamic-group ${each.key}-database-kms-dynamic-group to manage vaults in compartment ${each.value.name}", "Allow dynamic-group ${each.key}-database-kms-dynamic-group to manage keys in compartment ${each.value.name}"]
    }
  }
}

resource "null_resource" "slow_down_compartments" {
  depends_on = [module.lz_top_compartments]
  provisioner "local-exec" {
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
    command     = local.is_windows ? "Start-Sleep ${local.delay_in_secs}" : "sleep ${local.delay_in_secs}"
  }
}

resource "null_resource" "slow_down_groups" {
  depends_on = [module.lz_groups, module.lz_provisioning_groups]
  provisioner "local-exec" {
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
    command     = local.is_windows ? "Start-Sleep ${local.delay_in_secs}" : "sleep ${local.delay_in_secs}"
  }
}