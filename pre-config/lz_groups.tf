# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration optionally provisions groups that are required by the Landing Zone.

module "lz_provisioning_group" {
  count             = var.use_existing_provisioning_group == false ? 1 : 0
  source            = "../modules/iam/iam-group"
  tenancy_ocid      = var.tenancy_ocid
  group_name        = local.provisioning_group_name
  group_description = "Group entitled for provisioning the CIS Landing Zone resources."
  user_names        = []
}

module "lz_iam_admin_group" {
  count             = var.create_lz_groups == true ? 1 : 0
  source            = "../modules/iam/iam-group"
  tenancy_ocid      = var.tenancy_ocid
  group_name        = local.iam_admin_group_name
  group_description = "Group responsible for managing IAM resources in Landing Zone."
  user_names        = []
}

module "lz_network_admin_group" {
  count             = var.create_lz_groups == true ? 1 : 0
  source            = "../modules/iam/iam-group"
  tenancy_ocid      = var.tenancy_ocid
  group_name        = local.network_admin_group_name
  group_description = "Group responsible for managing networking in Landing Zone."
  user_names        = []
}

module "lz_security_admin_group" {
  count             = var.create_lz_groups == true ? 1 : 0
  source            = "../modules/iam/iam-group"
  tenancy_ocid      = var.tenancy_ocid
  group_name        = local.security_admin_group_name
  group_description = "Group responsible for managing security in Landing Zone."
  user_names        = []
}

module "lz_appdev_admin_group" {
  count             = var.create_lz_groups == true ? 1 : 0
  source            = "../modules/iam/iam-group"
  tenancy_ocid      = var.tenancy_ocid
  group_name        = local.appdev_admin_group_name
  group_description = "Group responsible for managing application development related resources in Landing Zone."
  user_names        = []
}

module "lz_database_admin_group" {
  count             = var.create_lz_groups == true ? 1 : 0
  source            = "../modules/iam/iam-group"
  tenancy_ocid      = var.tenancy_ocid
  group_name        = local.database_admin_group_name
  group_description = "Group responsible for managing database related resources in Landing Zone."
  user_names        = []
}

module "lz_auditor_group" {
  count             = var.create_lz_groups == true ? 1 : 0
  source            = "../modules/iam/iam-group"
  tenancy_ocid      = var.tenancy_ocid
  group_name        = local.auditor_group_name
  group_description = "Group responsible for auditing the tenancy."
  user_names        = []
}

module "lz_announcement_reader_group" {
  count             = var.create_lz_groups == true ? 1 : 0
  source            = "../modules/iam/iam-group"
  tenancy_ocid      = var.tenancy_ocid
  group_name        = local.announcement_reader_group_name
  group_description = "Group for reading announcements in the tenancy."
  user_names        = []
}