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

  #------------------------------------------------------------------------------------------------------
  #-- These variables are not meant to be overriden
  #------------------------------------------------------------------------------------------------------

  #-----------------------------------------------------------
  #----- Tags to apply to groups
  #-----------------------------------------------------------
  default_groups_defined_tags  = null
  default_groups_freeform_tags = local.landing_zone_tags

  groups_defined_tags  = local.custom_groups_defined_tags != null ? merge(local.custom_groups_defined_tags, local.default_groups_defined_tags) : local.default_groups_defined_tags
  groups_freeform_tags = local.custom_groups_freeform_tags != null ? merge(local.custom_groups_freeform_tags, local.default_groups_freeform_tags) : local.default_groups_freeform_tags

  #--------------------------------------------------------------------
  #-- AppDev Admin
  #--------------------------------------------------------------------
  default_appdev_admin_group_name = "${var.service_label}-appdev-admin-group"
  appdev_admin_group_key  = "appdev-admin-group"
  provided_appdev_admin_group_name = local.custom_appdev_admin_group_name != null ? local.custom_appdev_admin_group_name : "${var.service_label}-${local.default_appdev_admin_group_name}"

  appdev_admin_group = length(trimspace(var.existing_appdev_admin_group_name)) == 0 ? {
    (local.appdev_admin_group_key) = {
      name          = local.provided_appdev_admin_group_name
      description   = "CIS Landing Zone Workload group for managing app development related services."
      members       = []
      defined_tags  = local.groups_defined_tags
      freeform_tags = local.groups_freeform_tags
    }
  } : {}

  #--------------------------------------------------------------------
  #-- Database Admin
  #--------------------------------------------------------------------
  default_database_admin_group_name           = "${var.service_label}-database-admin-group"
  database_admin_group_key  = "database-admin-group"
  provided_database_admin_group_name = local.custom_database_admin_group_name != null ? local.custom_database_admin_group_name : "${var.service_label}-${local.default_database_admin_group_name}"

  database_admin_group = length(trimspace(var.existing_database_admin_group_name)) == 0 && !var.workload_team_manages_database ? {
    (local.database_admin_group_key) = {
      name          = local.provided_database_admin_group_name
      description   = "CIS Landing Zone Workload group for managing databases."
      members       = []
      defined_tags  = local.groups_defined_tags
      freeform_tags = local.groups_freeform_tags
    }
  } : {}

  #------------------------------------------------------------------------
  #----- Groups configuration definition. Input to module.
  #------------------------------------------------------------------------  
  groups_configuration = {
    groups : merge(local.appdev_admin_group, local.database_admin_group)
  }

#   empty_groups_configuration = {
#     groups : {}
#   }

  #----------------------------------------------------------------------------------
  #----- Variables with group names per groups module output
  #----------------------------------------------------------------------------------
  appdev_admin_group_name   = length(trimspace(var.existing_appdev_admin_group_name)) == 0 ? module.workload_groups.groups[local.appdev_admin_group_key].name : (length(regexall("^ocid1.group.oc.*$", var.existing_appdev_admin_group_name)) > 0 ? data.oci_identity_group.existing_appdev_admin_group.name : var.existing_appdev_admin_group_name)
  database_admin_group_name = length(trimspace(var.existing_database_admin_group_name)) == 0 && !var.workload_team_manages_database ? module.workload_groups.groups[local.database_admin_group_key].name : (length(regexall("^ocid1.group.oc.*$", var.existing_database_admin_group_name)) > 0 ? data.oci_identity_group.existing_database_admin_group.name : var.existing_database_admin_group_name)



}

module "workload_groups" {
  source = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam/groups"
  providers    = { oci = oci.home }
  tenancy_ocid = var.tenancy_ocid
  groups_configuration = local.groups_configuration
}