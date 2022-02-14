# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration optionally provisions groups that are required by the Landing Zone.

locals {
  all_groups_defined_tags = {}
  all_groups_freeform_tags = {}

  default_groups_defined_tags = null
  default_groups_freeform_tags = local.landing_zone_tags

  groups_defined_tags = length(local.all_groups_defined_tags) > 0 ? local.all_groups_defined_tags : local.default_groups_defined_tags
  groups_freeform_tags = length(local.all_groups_freeform_tags) > 0 ? merge(local.all_groups_freeform_tags, local.default_groups_freeform_tags) : local.default_groups_freeform_tags
}

module "lz_provisioning_groups" {
  for_each     = var.use_existing_provisioning_group == false ? local.provisioning_group_names : tomap({})
    source       = "../modules/iam/iam-group"
    tenancy_ocid = var.tenancy_ocid
    groups = {
      (each.value.group_name) = {
        description   = "Landing Zone group for resource provisioning."
        user_ids      = []
        defined_tags   = local.groups_defined_tags
        freeform_tags  = local.groups_freeform_tags
      }
    }
}

module "lz_groups" {
  for_each       = var.use_existing_groups == false ? local.lz_group_names : tomap({})
    source       = "../modules/iam/iam-group"
    tenancy_ocid = var.tenancy_ocid
    groups       = merge(
      { for i in [1] : "${each.value.group_name_prefix}${local.iam_admin_group_name_suffix}" => {
        description = "Landing Zone group for managing IAM resources."
        user_ids = []
        defined_tags  = local.groups_defined_tags
        freeform_tags = local.groups_freeform_tags
      } if length(trimspace(var.existing_iam_admin_group_name)) == 0},
      { for i in [1] : "${each.value.group_name_prefix}${local.cred_admin_group_name_suffix}" => {
        description = "Landing Zone group for managing credentials."
        user_ids = []
        defined_tags  = local.groups_defined_tags
        freeform_tags = local.groups_freeform_tags
      } if length(trimspace(var.existing_cred_admin_group_name)) == 0},
      { for i in [1] : "${each.value.group_name_prefix}${local.network_admin_group_name_suffix}" => {
        description = "Landing Zone group for managing networking."
        user_ids = []
        defined_tags  = local.groups_defined_tags
        freeform_tags = local.groups_freeform_tags
      } if length(trimspace(var.existing_network_admin_group_name)) == 0},
      { for i in [1] : "${each.value.group_name_prefix}${local.security_admin_group_name_suffix}" => {
        description = "Landing Zone group for managing security."
        user_ids = []
        defined_tags  = local.groups_defined_tags
        freeform_tags = local.groups_freeform_tags
      } if length(trimspace(var.existing_security_admin_group_name)) == 0},
      { for i in [1] : "${each.value.group_name_prefix}${local.appdev_admin_group_name_suffix}" => {
        description = "Landing Zone group for managing application development related resources."
        user_ids = []
        defined_tags  = local.groups_defined_tags
        freeform_tags = local.groups_freeform_tags
      } if length(trimspace(var.existing_appdev_admin_group_name)) == 0},
      { for i in [1] : "${each.value.group_name_prefix}${local.database_admin_group_name_suffix}" => {
        description = "Landing Zone group for managing database related resources."
        user_ids = []
        defined_tags  = local.groups_defined_tags
        freeform_tags = local.groups_freeform_tags
      } if length(trimspace(var.existing_database_admin_group_name)) == 0},
      { for i in [1] : "${each.value.group_name_prefix}${local.auditor_group_name_suffix}" => {
        description = "Landing Zone group for auditing the tenancy."
        user_ids = []
        defined_tags  = local.groups_defined_tags
        freeform_tags = local.groups_freeform_tags
      } if length(trimspace(var.existing_auditor_group_name)) == 0},
      { for i in [1] : "${each.value.group_name_prefix}${local.announcement_reader_group_name_suffix}" => {
        description = "Landing Zone group for reading tenancy announcements."
        user_ids = []
        defined_tags  = local.groups_defined_tags
        freeform_tags = local.groups_freeform_tags
      } if length(trimspace(var.existing_announcement_reader_group_name)) == 0},
      { for i in [1] : "${each.value.group_name_prefix}${local.exainfra_admin_group_name_suffix}" => {
        description = "Landing Zone group for managing Exadata Cloud service infrastructures."
        user_ids = []
        defined_tags  = local.groups_defined_tags
        freeform_tags = local.groups_freeform_tags
      } if length(trimspace(var.existing_exainfra_admin_group_name)) == 0},
      { for i in [1] : "${each.value.group_name_prefix}${local.cost_admin_group_name_suffix}" => {
        description = "Landing Zone group for Cost Management."
        user_ids = []
        defined_tags  = local.groups_defined_tags
        freeform_tags = local.groups_freeform_tags
      } if length(trimspace(var.existing_cost_admin_group_name)) == 0}
    )
}