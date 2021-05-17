locals {
  
  top_compartment_name      = var.enclosing_compartment_name != null ? var.enclosing_compartment_name : "${var.unique_prefix}-top-cmp"
  top_compartment_parent_id = var.existing_enclosing_compartment_parent_ocid != null ? var.existing_enclosing_compartment_parent_ocid : var.tenancy_ocid
  provisioning_group_name   = var.existing_provisioning_group_name != null ? var.existing_provisioning_group_name : "${var.unique_prefix}-provisioning-group"
  provisioning_policy_name  = "${var.unique_prefix}-provisioning-policy"
  tenancy_level_policy_name = "${var.unique_prefix}-groups-tenancy-level-policy"

  iam_admin_group_name           = var.create_lz_groups == true ? "${var.unique_prefix}-iam-admin-group" : var.existing_iam_admin_group_name
  cred_admin_group_name          = var.create_lz_groups == true ? "${var.unique_prefix}-cred-admin-group" : var.existing_cred_admin_group_name
  network_admin_group_name       = var.create_lz_groups == true ? "${var.unique_prefix}-network-admin-group" : var.existing_network_admin_group_name
  security_admin_group_name      = var.create_lz_groups == true ? "${var.unique_prefix}-security-admin-group" : var.existing_security_admin_group_name
  appdev_admin_group_name        = var.create_lz_groups == true ? "${var.unique_prefix}-appdev-admin-group" :  var.existing_appdev_admin_group_name
  database_admin_group_name      = var.create_lz_groups == true ? "${var.unique_prefix}-database-admin-group" : var.existing_database_admin_group_name
  auditor_group_name             = var.create_lz_groups == true ? "${var.unique_prefix}-auditor-group" : var.existing_auditor_group_name
  announcement_reader_group_name = var.create_lz_groups == true ? "${var.unique_prefix}-announcement-reader-group": var.existing_announcement_reader_group_name
}