# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_regions" "these" {}

data "oci_identity_region_subscriptions" "these" {
  tenancy_id = var.tenancy_ocid
}

data "oci_identity_tenancy" "this" {
  tenancy_id = var.tenancy_ocid
}

data "oci_identity_compartment" "existing_enclosing_compartment" {
  id = var.existing_enclosing_compartment_ocid != null ? var.existing_enclosing_compartment_ocid : var.tenancy_ocid
}

data "oci_identity_group" "existing_iam_admin_group" {
  for_each = length(trimspace(var.rm_existing_iam_admin_group_name)) > 0 ? toset([var.rm_existing_iam_admin_group_name]) : toset(var.existing_iam_admin_group_name)
    group_id = length(trimspace(each.value)) > 0 ? each.value : "nogroup"
}

data "oci_identity_group" "existing_cred_admin_group" {
  for_each = length(trimspace(var.rm_existing_cred_admin_group_name)) > 0 ? toset([var.rm_existing_cred_admin_group_name]) : toset(var.existing_cred_admin_group_name)
    group_id = length(trimspace(each.value)) > 0 ? each.value : "nogroup"
}

data "oci_identity_group" "existing_security_admin_group" {
  for_each = length(trimspace(var.rm_existing_security_admin_group_name)) > 0 ? toset([var.rm_existing_security_admin_group_name]) : toset(var.existing_security_admin_group_name)
    group_id = length(trimspace(each.value)) > 0 ? each.value : "nogroup"
}

data "oci_identity_group" "existing_network_admin_group" {
  for_each = length(trimspace(var.rm_existing_network_admin_group_name)) > 0 ? toset([var.rm_existing_network_admin_group_name]) : toset(var.existing_network_admin_group_name)
    group_id = length(trimspace(each.value)) > 0 ? each.value : "nogroup"
}

data "oci_identity_group" "existing_appdev_admin_group" {
  for_each = length(trimspace(var.rm_existing_appdev_admin_group_name)) > 0 ? toset([var.rm_existing_appdev_admin_group_name]) : toset(var.existing_appdev_admin_group_name)
    group_id = length(trimspace(each.value)) > 0 ? each.value : "nogroup"
}

data "oci_identity_group" "existing_database_admin_group" {
  for_each = length(trimspace(var.rm_existing_database_admin_group_name)) > 0 ? toset([var.rm_existing_database_admin_group_name]) : toset(var.existing_database_admin_group_name)
    group_id = length(trimspace(each.value)) > 0 ? each.value : "nogroup"
}

data "oci_identity_group" "existing_auditor_group" {
  for_each = length(trimspace(var.rm_existing_auditor_group_name)) > 0 ? toset([var.rm_existing_auditor_group_name]) : toset(var.existing_auditor_group_name)
    group_id = length(trimspace(each.value)) > 0 ? each.value : "nogroup"
}

data "oci_identity_group" "existing_announcement_reader_group" {
  for_each = length(trimspace(var.rm_existing_announcement_reader_group_name)) > 0 ? toset([var.rm_existing_announcement_reader_group_name]) : toset(var.existing_announcement_reader_group_name)
    group_id = length(trimspace(each.value)) > 0 ? each.value : "nogroup"
}

data "oci_identity_group" "existing_exainfra_admin_group" {
  for_each = length(trimspace(var.rm_existing_exainfra_admin_group_name)) > 0 ? toset([var.rm_existing_exainfra_admin_group_name]) : toset(var.existing_exainfra_admin_group_name)
    group_id = length(trimspace(each.value)) > 0 ? each.value : "nogroup"
}

data "oci_identity_group" "existing_cost_admin_group" {
  for_each = length(trimspace(var.rm_existing_cost_admin_group_name)) > 0 ? toset([var.rm_existing_cost_admin_group_name]) : toset(var.existing_cost_admin_group_name)
    group_id = length(trimspace(each.value)) > 0 ? each.value : "nogroup"
}

data "oci_identity_group" "existing_storage_admin_group" {
  for_each = length(trimspace(var.rm_existing_storage_admin_group_name)) > 0 ? toset([var.rm_existing_storage_admin_group_name]) : toset(var.existing_storage_admin_group_name)
    group_id = length(trimspace(each.value)) > 0 ? each.value : "nogroup"
}

/* data "oci_identity_dynamic_groups" "existing_security_fun_dyn_group" {
  compartment_id = var.tenancy_ocid
  filter {
    name   = "name"
    values = [var.existing_security_fun_dyn_group_name]
  }
}

data "oci_identity_dynamic_groups" "existing_appdev_fun_dyn_group" {
  compartment_id = var.tenancy_ocid
  filter {
    name   = "name"
    values = [var.existing_appdev_fun_dyn_group_name]
  }
}

data "oci_identity_dynamic_groups" "existing_compute_agent_dyn_group" {
  compartment_id = var.tenancy_ocid
  filter {
    name   = "name"
    values = [var.existing_compute_agent_dyn_group_name]
  }
}

data "oci_identity_dynamic_groups" "existing_database_kms_dyn_group" {
  compartment_id = var.tenancy_ocid
  filter {
    name   = "name"
    values = [var.existing_database_kms_dyn_group_name]
  }
} */

data "oci_cloud_guard_cloud_guard_configuration" "this" {
  compartment_id = var.tenancy_ocid
}

data "oci_objectstorage_namespace" "this" {
  compartment_id = var.tenancy_ocid
}

data "oci_identity_compartments" "network" {
  compartment_id = local.enclosing_compartment_id
  filter {
    name = "name"
    values = [local.provided_network_compartment_name]
  }
  filter {
    name = "state"
    values = ["ACTIVE"]
  }
}

data "oci_identity_compartments" "security" {
  compartment_id = local.enclosing_compartment_id
  filter {
    name = "name"
    values = [local.provided_security_compartment_name]
  }
  filter {
    name = "state"
    values = ["ACTIVE"]
  }
}

data "oci_identity_compartments" "appdev" {
  compartment_id = local.enclosing_compartment_id
  filter {
    name = "name"
    values = [local.provided_appdev_compartment_name]
  }
  filter {
    name = "state"
    values = ["ACTIVE"]
  }
}

data "oci_identity_compartments" "database" {
  compartment_id = local.enclosing_compartment_id
  filter {
    name = "name"
    values = [local.provided_database_compartment_name]
  }
  filter {
    name = "state"
    values = ["ACTIVE"]
  }
}

data "oci_identity_compartments" "exainfra" {
  compartment_id = local.enclosing_compartment_id
  filter {
    name = "name"
    values = [local.provided_exainfra_compartment_name]
  }
  filter {
    name = "state"
    values = ["ACTIVE"]
  }
}

data "oci_identity_tag_namespaces" "this" {
  compartment_id = var.tenancy_ocid
}

data "oci_identity_compartments" "all" {
  depends_on = [module.lz_compartments]
  compartment_id = var.tenancy_ocid
  compartment_id_in_subtree = true
  access_level = "ACCESSIBLE"
  state = "ACTIVE"
}
