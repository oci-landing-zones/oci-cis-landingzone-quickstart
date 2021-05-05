locals {
  top_compartment_name       = "${var.unique_prefix}-top-cmp"
  provisioning_group_name    = var.create_lz_provisioning_group == true ? "${var.unique_prefix}-provisioning-group" : var.existing_provisioning_group_name
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