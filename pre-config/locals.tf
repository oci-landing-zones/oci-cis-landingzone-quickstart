locals {
  top_compartment_name       = var.lz_top_compartment_name != null ? var.lz_top_compartment_name : "${var.unique_prefix}-top-cmp"
  top_compartment_parent_id  = var.lz_top_compartment_parent_id != null ? var.lz_top_compartment_parent_id : var.tenancy_ocid
  provisioning_group_name    = var.lz_provisioning_group_name != null ? var.lz_provisioning_group_name : "${var.unique_prefix}-provisioning-group"
  provisioning_policy_name   = "${var.unique_prefix}-provisioning-policy"
  security_admin_policy_name = "${var.unique_prefix}-security-admin-group-policy"

  iam_admin_group_name           = "${var.unique_prefix}-iam-admin-group"
  network_admin_group_name       = "${var.unique_prefix}-network-admin-group"
  security_admin_group_name      = "${var.unique_prefix}-security-admin-group"
  appdev_admin_group_name        = "${var.unique_prefix}-appdev-admin-group"
  database_admin_group_name      = "${var.unique_prefix}-database-admin-group"
  auditor_group_name             = "${var.unique_prefix}-auditor-group"
  announcement_reader_group_name = "${var.unique_prefix}-announcement-reader-group"
}