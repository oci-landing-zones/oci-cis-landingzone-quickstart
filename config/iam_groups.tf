# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration provisions Landing Zone groups.

locals {
  #------------------------------------------------------------------------------------------------------
  #-- Any of these local variables can be overriden in a _override.tf file
  #------------------------------------------------------------------------------------------------------
  custom_groups_defined_tags = null
  custom_groups_freeform_tags = null

  custom_iam_admin_group_name = null
  custom_cred_admin_group_name = null
  custom_cost_admin_group_name = null
  custom_network_admin_group_name = null
  custom_security_admin_group_name = null
  custom_appdev_admin_group_name = null
  custom_database_admin_group_name = null
  custom_exainfra_admin_group_name = null
  custom_storage_admin_group_name = null
  custom_auditor_group_name = null
  custom_announcement_reader_group_name = null
}

module "lz_groups" {
  source = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam/groups"
  providers    = { oci = oci.home }
  tenancy_ocid = var.tenancy_ocid
  groups_configuration = var.extend_landing_zone_to_new_region == false ? local.groups_configuration : local.empty_groups_configuration
}

locals {
  #------------------------------------------------------------------------------------------------------
  #-- These variables are not meant to be overriden
  #------------------------------------------------------------------------------------------------------

  #-----------------------------------------------------------
  #----- Tags to apply to groups
  #-----------------------------------------------------------
  default_groups_defined_tags = null
  default_groups_freeform_tags = local.landing_zone_tags

  groups_defined_tags = local.custom_groups_defined_tags != null ? merge(local.custom_groups_defined_tags, local.default_groups_defined_tags) : local.default_groups_defined_tags
  groups_freeform_tags = local.custom_groups_freeform_tags != null ? merge(local.custom_groups_freeform_tags, local.default_groups_freeform_tags) : local.default_groups_freeform_tags

  #--------------------------------------------------------------------
  #-- IAM Admin
  #--------------------------------------------------------------------
  iam_admin_group_key = "${var.service_label}-iam-admin-group"
  default_iam_admin_group_name = "iam-admin-group"
  provided_iam_admin_group_name = local.custom_iam_admin_group_name != null ? local.custom_iam_admin_group_name : "${var.service_label}-${local.default_iam_admin_group_name}" 
  
  #iam_admin_group = length(trimspace(var.existing_iam_admin_group_name)) == 0 ? {
  iam_admin_group = length(var.existing_iam_admin_group_name) == 0 && length(trimspace(var.rm_existing_iam_admin_group_name)) == 0 ? {
    (local.iam_admin_group_key) = {
      name          = local.provided_iam_admin_group_name
      description   = "CIS Landing Zone group for managing IAM resources in the tenancy."
      members       = []
      defined_tags  = local.groups_defined_tags
      freeform_tags = local.groups_freeform_tags
    }
  } : {} 

  #--------------------------------------------------------------------
  #-- Credentials Admin
  #--------------------------------------------------------------------  
  cred_admin_group_key = "${var.service_label}-cred-admin-group"
  default_cred_admin_group_name = "cred-admin-group"
  provided_cred_admin_group_name = local.custom_cred_admin_group_name != null ? local.custom_cred_admin_group_name : "${var.service_label}-${local.default_cred_admin_group_name}"  
  
  cred_admin_group = length(var.existing_cred_admin_group_name) == 0 && length(trimspace(var.rm_existing_cred_admin_group_name)) == 0 ? {
    (local.cred_admin_group_key) = {
      name          = local.provided_cred_admin_group_name
      description   = "CIS Landing Zone group for managing users credentials in the tenancy."
      members       = []
      defined_tags  = local.groups_defined_tags
      freeform_tags = local.groups_freeform_tags
    }
  } : {}

  #--------------------------------------------------------------------
  #-- Cost Admin
  #--------------------------------------------------------------------
  cost_admin_group_key = "${var.service_label}-cost-admin-group"
  default_cost_admin_group_name = "cost-admin-group"
  provided_cost_admin_group_name = local.custom_cost_admin_group_name != null ? local.custom_cost_admin_group_name : "${var.service_label}-${local.default_cost_admin_group_name}" 
  
  cost_admin_group = length(var.existing_cost_admin_group_name) == 0 && length(trimspace(var.rm_existing_cost_admin_group_name)) == 0 ? {
    (local.cost_admin_group_key) = {
      name         = local.provided_cost_admin_group_name 
      description  = "CIS Landing Zone group for Cost management."
      members      = []
      defined_tags  = local.groups_defined_tags
      freeform_tags = local.groups_freeform_tags
    }
  } : {}

  #--------------------------------------------------------------------
  #-- Network Admin
  #--------------------------------------------------------------------
  network_admin_group_key = "${var.service_label}-network-admin-group"
  default_network_admin_group_name = "network-admin-group"
  provided_network_admin_group_name = local.custom_network_admin_group_name != null ? local.custom_network_admin_group_name : "${var.service_label}-${local.default_network_admin_group_name}"
  
  network_admin_group = length(var.existing_network_admin_group_name) == 0 && length(trimspace(var.rm_existing_network_admin_group_name)) == 0 ? {
    (local.network_admin_group_key) = {
      name          = local.provided_network_admin_group_name  
      description   = "CIS Landing Zone group for network management."
      members       = []
      defined_tags  = local.groups_defined_tags
      freeform_tags = local.groups_freeform_tags
    } 
  } : {} 

  #--------------------------------------------------------------------
  #-- Security Admin
  #--------------------------------------------------------------------
  security_admin_group_key = "${var.service_label}-security-admin-group"
  default_security_admin_group_name = "security-admin-group"
  provided_security_admin_group_name = local.custom_security_admin_group_name != null ? local.custom_security_admin_group_name : "${var.service_label}-${local.default_security_admin_group_name}"
    
  security_admin_group = length(var.existing_security_admin_group_name) == 0 && length(trimspace(var.rm_existing_security_admin_group_name)) == 0 ? {
    (local.security_admin_group_key) = {
      name          = local.provided_security_admin_group_name  
      description   = "CIS Landing Zone group for security services management."
      members       = []
      defined_tags  = local.groups_defined_tags
      freeform_tags = local.groups_freeform_tags
    }
  } : {}

  #--------------------------------------------------------------------
  #-- AppDev Admin
  #--------------------------------------------------------------------
  appdev_admin_group_key = "${var.service_label}-appdev-admin-group"
  default_appdev_admin_group_name = "appdev-admin-group"
  provided_appdev_admin_group_name = local.custom_appdev_admin_group_name != null ? local.custom_appdev_admin_group_name : "${var.service_label}-${local.default_appdev_admin_group_name}"
  
  appdev_admin_group = length(var.existing_appdev_admin_group_name) == 0 && length(trimspace(var.rm_existing_appdev_admin_group_name)) == 0 ? {
    (local.appdev_admin_group_key) = {
      name          = local.provided_appdev_admin_group_name  
      description   = "CIS Landing Zone group for managing app development related services."
      members       = []
      defined_tags  = local.groups_defined_tags
      freeform_tags = local.groups_freeform_tags
    }
  } : {}

  #--------------------------------------------------------------------
  #-- Database Admin
  #--------------------------------------------------------------------
  database_admin_group_key = "${var.service_label}-database-admin-group"
  default_database_admin_group_name = "database-admin-group"
  provided_database_admin_group_name = local.custom_database_admin_group_name != null ? local.custom_database_admin_group_name : "${var.service_label}-${local.default_database_admin_group_name}"
  
  database_admin_group = length(var.existing_database_admin_group_name) == 0 && length(trimspace(var.rm_existing_database_admin_group_name)) == 0 ? {
    (local.database_admin_group_key) = {
      name          = local.provided_database_admin_group_name  
      description   = "CIS Landing Zone group for managing databases."
      members       = []
      defined_tags  = local.groups_defined_tags
      freeform_tags = local.groups_freeform_tags
    }
  } : {}

  #--------------------------------------------------------------------
  #-- Exainfra Admin
  #--------------------------------------------------------------------
  exainfra_admin_group_key = "${var.service_label}-exainfra-admin-group"
  default_exainfra_admin_group_name = "exainfra-admin-group"
  provided_exainfra_admin_group_name = local.custom_exainfra_admin_group_name != null ? local.custom_exainfra_admin_group_name : "${var.service_label}-${local.default_exainfra_admin_group_name}"
    
  exainfra_admin_group = var.deploy_exainfra_cmp == true && length(var.existing_exainfra_admin_group_name) == 0 && length(trimspace(var.rm_existing_exainfra_admin_group_name)) == 0 ? {
    (local.exainfra_admin_group_key) = {
      name          = local.provided_exainfra_admin_group_name  
      description   = "CIS Landing Zone group for managing Exadata Cloud Service infrastructure."
      members       = []
      defined_tags  = local.groups_defined_tags
      freeform_tags = local.groups_freeform_tags
    }
  } : {}

  #------------------------------------------------------------------------
  #-- Storage admin
  #------------------------------------------------------------------------
  storage_admin_group_key = "${var.service_label}-storage-admin-group"
  default_storage_admin_group_name = "storage-admin-group"
  provided_storage_admin_group_name = local.custom_storage_admin_group_name != null ? local.custom_storage_admin_group_name : "${var.service_label}-${local.default_storage_admin_group_name}"

  storage_admin_group = length(var.existing_storage_admin_group_name) == 0 && length(trimspace(var.rm_existing_storage_admin_group_name)) == 0 ? {
    (local.storage_admin_group_key) = {
      name          = local.provided_storage_admin_group_name  
      description   = "CIS Landing Zone group for storage services management."
      members       = []
      defined_tags  = local.groups_defined_tags
      freeform_tags = local.groups_freeform_tags
    } 
  } : {}

  #------------------------------------------------------------------------
  #-- Auditors
  #------------------------------------------------------------------------
  auditor_group_key = "${var.service_label}-auditor-group"
  default_auditor_group_name = "auditor-group"
  provided_auditor_group_name = local.custom_auditor_group_name != null ? local.custom_auditor_group_name : "${var.service_label}-${local.default_auditor_group_name}"
  
  auditor_group = length(var.existing_auditor_group_name) == 0 && length(trimspace(var.rm_existing_auditor_group_name)) == 0 ? {
    (local.auditor_group_key) = {
      name          = local.provided_auditor_group_name  
      description   = "CIS Landing Zone group for auditing the tenancy."
      members       = []
      defined_tags  = local.groups_defined_tags
      freeform_tags = local.groups_freeform_tags
    }
  } : {}

  #------------------------------------------------------------------------
  #-- Announcement readers
  #------------------------------------------------------------------------
  announcement_reader_group_key = "${var.service_label}-announcement-reader-group"
  default_announcement_reader_group_name = "announcement-reader-group"
  provided_announcement_reader_group_name = local.custom_announcement_reader_group_name != null ? local.custom_announcement_reader_group_name : "${var.service_label}-${local.default_announcement_reader_group_name}"
  
  announcement_reader_group = length(var.existing_announcement_reader_group_name) == 0 && length(trimspace(var.rm_existing_announcement_reader_group_name)) == 0 ? {
    (local.announcement_reader_group_key) = {
      name          = local.provided_announcement_reader_group_name  
      description   = "CIS Landing Zone group for reading Console announcements."
      members       = []
      defined_tags  = local.groups_defined_tags
      freeform_tags = local.groups_freeform_tags
    }
  } : {}

  #------------------------------------------------------------------------
  #----- Groups configuration definition. Input to module.
  #------------------------------------------------------------------------  
  groups_configuration = {
    groups : merge(local.iam_admin_group, local.cred_admin_group, local.cost_admin_group,
                   local.network_admin_group, local.security_admin_group,
                   local.appdev_admin_group, local.database_admin_group, local.exainfra_admin_group,
                   local.storage_admin_group, local.auditor_group, local.announcement_reader_group)
  }

  empty_groups_configuration = {
    groups : {}
  }

  #----------------------------------------------------------------------------------
  #----- Variables with group names per groups module output
  #----------------------------------------------------------------------------------
  iam_admin_group_name           = length(var.existing_iam_admin_group_name) == 0 && length(trimspace(var.rm_existing_iam_admin_group_name)) == 0                       ? [module.lz_groups.groups[local.iam_admin_group_key].name]            : (length(regexall("^ocid1.group.oc.*$", var.rm_existing_iam_admin_group_name)) > 0            ? ["'${data.oci_identity_group.existing_iam_admin_group[var.rm_existing_iam_admin_group_name].name}'"]                 : [ for i,v in var.existing_iam_admin_group_name : (length(regexall("^ocid1.group.oc.*$", var.existing_iam_admin_group_name[i])) > 0                      ? "'${data.oci_identity_group.existing_iam_admin_group[v].name}'"            :  "'${v}'")])
  cred_admin_group_name          = length(var.existing_cred_admin_group_name) == 0 && length(trimspace(var.rm_existing_cred_admin_group_name)) == 0                     ? [module.lz_groups.groups[local.cred_admin_group_key].name]           : (length(regexall("^ocid1.group.oc.*$", var.rm_existing_cred_admin_group_name)) > 0           ? ["'${data.oci_identity_group.existing_cred_admin_group[var.rm_existing_cred_admin_group_name].name}'"]               : [ for i,v in var.existing_cred_admin_group_name : (length(regexall("^ocid1.group.oc.*$", var.existing_cred_admin_group_name[i])) > 0                    ? "'${data.oci_identity_group.existing_cred_admin_group[v].name}'"           :  "'${v}'")])
  security_admin_group_name      = length(var.existing_security_admin_group_name) == 0 && length(trimspace(var.rm_existing_security_admin_group_name)) == 0             ? [module.lz_groups.groups[local.security_admin_group_key].name]       : (length(regexall("^ocid1.group.oc.*$", var.rm_existing_security_admin_group_name)) > 0       ? ["'${data.oci_identity_group.existing_security_admin_group[var.rm_existing_security_admin_group_name].name}'"]       : [ for i,v in var.existing_security_admin_group_name : (length(regexall("^ocid1.group.oc.*$", var.existing_security_admin_group_name[i])) > 0            ? "'${data.oci_identity_group.existing_security_admin_group[v].name}'"       :  "'${v}'")])
  network_admin_group_name       = length(var.existing_network_admin_group_name) == 0 && length(trimspace(var.rm_existing_network_admin_group_name)) == 0              ? [module.lz_groups.groups[local.network_admin_group_key].name]        : (length(regexall("^ocid1.group.oc.*$", var.rm_existing_network_admin_group_name)) > 0        ? ["'${data.oci_identity_group.existing_network_admin_group[var.rm_existing_network_admin_group_name].name}'"]         : [ for i,v in var.existing_network_admin_group_name : (length(regexall("^ocid1.group.oc.*$", var.existing_network_admin_group_name[i])) > 0              ? "'${data.oci_identity_group.existing_network_admin_group[v].name}'"        :  "'${v}'")])
  database_admin_group_name      = length(var.existing_database_admin_group_name) == 0 && length(trimspace(var.rm_existing_database_admin_group_name)) == 0             ? [module.lz_groups.groups[local.database_admin_group_key].name]       : (length(regexall("^ocid1.group.oc.*$", var.rm_existing_database_admin_group_name)) > 0       ? ["'${data.oci_identity_group.existing_database_admin_group[var.rm_existing_database_admin_group_name].name}'"]       : [ for i,v in var.existing_database_admin_group_name : (length(regexall("^ocid1.group.oc.*$", var.existing_database_admin_group_name[i])) > 0            ? "'${data.oci_identity_group.existing_database_admin_group[v].name}'"       :  "'${v}'")])
  appdev_admin_group_name        = length(var.existing_appdev_admin_group_name) == 0 && length(trimspace(var.rm_existing_appdev_admin_group_name)) == 0                 ? [module.lz_groups.groups[local.appdev_admin_group_key].name]         : (length(regexall("^ocid1.group.oc.*$", var.rm_existing_appdev_admin_group_name)) > 0         ? ["'${data.oci_identity_group.existing_appdev_admin_group[var.rm_existing_appdev_admin_group_name].name}'"]           : [ for i,v in var.existing_appdev_admin_group_name : (length(regexall("^ocid1.group.oc.*$", var.existing_appdev_admin_group_name[i])) > 0                ? "'${data.oci_identity_group.existing_appdev_admin_group[v].name}'"         :  "'${v}'")])
  auditor_group_name             = length(var.existing_auditor_group_name) == 0 && length(trimspace(var.rm_existing_auditor_group_name)) == 0                           ? [module.lz_groups.groups[local.auditor_group_key].name]              : (length(regexall("^ocid1.group.oc.*$", var.rm_existing_auditor_group_name)) > 0              ? ["'${data.oci_identity_group.existing_auditor_group[var.rm_existing_auditor_group_name].name}'"]                     : [ for i,v in var.existing_auditor_group_name : (length(regexall("^ocid1.group.oc.*$", var.existing_auditor_group_name[i])) > 0                          ? "'${data.oci_identity_group.existing_auditor_group[v].name}'"         :  "'${v}'")])
  announcement_reader_group_name = length(var.existing_announcement_reader_group_name) == 0 && length(trimspace(var.rm_existing_announcement_reader_group_name)) == 0   ? [module.lz_groups.groups[local.announcement_reader_group_key].name]  : (length(regexall("^ocid1.group.oc.*$", var.rm_existing_announcement_reader_group_name)) > 0  ? ["'${data.oci_identity_group.existing_announcement_reader_group[var.rm_existing_announcement_reader_group_name].name}'"]  : [ for i,v in var.existing_announcement_reader_group_name : (length(regexall("^ocid1.group.oc.*$", var.existing_announcement_reader_group_name[i])) > 0  ? "'${data.oci_identity_group.existing_announcement_reader_group[v].name}'"  :  "'${v}'")])
  cost_admin_group_name          = length(var.existing_cost_admin_group_name) == 0 && length(trimspace(var.rm_existing_cost_admin_group_name)) == 0                     ? [module.lz_groups.groups[local.cost_admin_group_key].name]           : (length(regexall("^ocid1.group.oc.*$", var.rm_existing_cost_admin_group_name)) > 0           ? ["'${data.oci_identity_group.existing_cost_admin_group[var.rm_existing_cost_admin_group_name].name}'"]               : [ for i,v in var.existing_cost_admin_group_name : (length(regexall("^ocid1.group.oc.*$", var.existing_cost_admin_group_name[i])) > 0                    ? "'${data.oci_identity_group.existing_cost_admin_group[v].name}'"           :  "'${v}'")])
  storage_admin_group_name       = length(var.existing_storage_admin_group_name) == 0 && length(trimspace(var.rm_existing_storage_admin_group_name)) == 0               ? [module.lz_groups.groups[local.storage_admin_group_key].name]        : (length(regexall("^ocid1.group.oc.*$", var.rm_existing_storage_admin_group_name)) > 0        ? ["'${data.oci_identity_group.existing_storage_admin_group[var.rm_existing_storage_admin_group_name].name}'"]        : [ for i,v in var.existing_storage_admin_group_name : (length(regexall("^ocid1.group.oc.*$", var.existing_storage_admin_group_name[i])) > 0              ? "'${data.oci_identity_group.existing_storage_admin_group[v].name}'"        :  "'${v}'")])
  exainfra_admin_group_name      = var.deploy_exainfra_cmp ? (length(var.existing_exainfra_admin_group_name) == 0 && length(trimspace(var.rm_existing_exainfra_admin_group_name)) == 0 ? [module.lz_groups.groups[local.exainfra_admin_group_key].name] : (length(regexall("^ocid1.group.oc.*$", var.rm_existing_exainfra_admin_group_name)) > 0  ? ["'${data.oci_identity_group.existing_exainfra_admin_group[var.rm_existing_exainfra_admin_group_name].name}'"]  : [ for i,v in var.existing_exainfra_admin_group_name : (length(regexall("^ocid1.group.oc.*$", var.existing_exainfra_admin_group_name[i])) > 0  ? "'${data.oci_identity_group.existing_exainfra_admin_group[v].name}'" :  "'${v}'")])) : [for grp in var.existing_exainfra_admin_group_name : "'${grp}'"]
}