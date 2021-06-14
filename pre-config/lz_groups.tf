# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration optionally provisions groups that are required by the Landing Zone.

module "lz_provisioning_groups" {
  for_each          = var.use_existing_provisioning_group == false ? local.provisioning_group_names : tomap({})
  source            = "../modules/iam/iam-group"
  tenancy_ocid      = var.tenancy_ocid
  group_name        = each.value.group_name
  group_description = "Group entitled for provisioning the CIS Landing Zone resources in compartment ${each.key}"
  user_names        = []
}

module "lz_iam_admin_groups" {
  for_each          = var.use_existing_lz_groups == false ? local.lz_group_names : tomap({})
  source            = "../modules/iam/iam-group"
  tenancy_ocid      = var.tenancy_ocid
  group_name        = "${each.value.group_name_prefix}${local.iam_admin_group_name_suffix}"
  group_description = "Group responsible for managing IAM resources in ${each.key}'s compartment."
  user_names        = []
}

module "lz_cred_admin_groups" {
  for_each          = var.use_existing_lz_groups == false ? local.lz_group_names : tomap({})
  source            = "../modules/iam/iam-group"
  tenancy_ocid      = var.tenancy_ocid
  group_name        = "${each.value.group_name_prefix}${local.cred_admin_group_name_suffix}"
  group_description = "Group responsible for managing credentials in ${each.key}'s compartment."
  user_names        = []
}

module "lz_network_admin_groups" {
  for_each          = var.use_existing_lz_groups == false ? local.lz_group_names : tomap({})
  source            = "../modules/iam/iam-group"
  tenancy_ocid      = var.tenancy_ocid
  group_name        = "${each.value.group_name_prefix}${local.network_admin_group_name_suffix}"
  group_description = "Group responsible for managing networking in ${each.key}'s network subcompartment."
  user_names        = []
}

module "lz_security_admin_groups" {
  for_each          = var.use_existing_lz_groups == false ? local.lz_group_names : tomap({})
  source            = "../modules/iam/iam-group"
  tenancy_ocid      = var.tenancy_ocid
  group_name        = "${each.value.group_name_prefix}${local.security_admin_group_name_suffix}"
  group_description = "Group responsible for managing security in ${each.key}'s security subcompartment."
  user_names        = []
}

module "lz_appdev_admin_groups" {
  for_each          = var.use_existing_lz_groups == false ? local.lz_group_names : tomap({})
  source            = "../modules/iam/iam-group"
  tenancy_ocid      = var.tenancy_ocid
  group_name        = "${each.value.group_name_prefix}${local.appdev_admin_group_name_suffix}"
  group_description = "Group responsible for managing application development related resources in ${each.key}'s appdev subcompartment."
  user_names        = []
}

module "lz_database_admin_groups" {
  for_each          = var.use_existing_lz_groups == false ? local.lz_group_names : tomap({})
  source            = "../modules/iam/iam-group"
  tenancy_ocid      = var.tenancy_ocid
  group_name        = "${each.value.group_name_prefix}${local.database_admin_group_name_suffix}"
  group_description = "Group responsible for managing database related resources in ${each.key}'s database subcompartment'."
  user_names        = []
}

module "lz_auditor_groups" {
  for_each          = var.use_existing_lz_groups == false ? local.lz_group_names : tomap({})
  source            = "../modules/iam/iam-group"
  tenancy_ocid      = var.tenancy_ocid
  group_name        = "${each.value.group_name_prefix}${local.auditor_group_name_suffix}"
  group_description = "Group responsible for auditing the tenancy."
  user_names        = []
}

module "lz_announcement_reader_groups" {
  for_each          = var.use_existing_lz_groups == false ? local.lz_group_names : tomap({})
  source            = "../modules/iam/iam-group"
  tenancy_ocid      = var.tenancy_ocid
  group_name        = "${each.value.group_name_prefix}${local.announcement_reader_group_name_suffix}"
  group_description = "Group for reading announcements in the tenancy."
  user_names        = []
}