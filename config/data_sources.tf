# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_regions" "these" {}

data "oci_identity_tenancy" "this" {
  tenancy_id = var.tenancy_ocid
}

data "oci_identity_compartment" "existing_enclosing_compartment" {
  id = var.existing_enclosing_compartment_ocid != null ? var.existing_enclosing_compartment_ocid : var.tenancy_ocid
}

data "oci_identity_group" "existing_iam_admin_group" {
  group_id = length(trimspace(var.existing_iam_admin_group_name)) > 0 ? var.existing_iam_admin_group_name : "nogroup"
}

data "oci_identity_groups" "existing_iam_admin_group" {
  compartment_id = var.tenancy_ocid
  filter {
    name   = "name"
    values = [var.existing_iam_admin_group_name]
  }
}

data "oci_identity_group" "existing_cred_admin_group" {
  group_id = length(trimspace(var.existing_cred_admin_group_name)) > 0 ? var.existing_cred_admin_group_name : "nogroup"
}

data "oci_identity_groups" "existing_cred_admin_group" {
  compartment_id = var.tenancy_ocid
  filter {
    name   = "name"
    values = [var.existing_cred_admin_group_name]
  }
}

data "oci_identity_group" "existing_security_admin_group" {
  group_id = length(trimspace(var.existing_security_admin_group_name)) > 0 ? var.existing_security_admin_group_name : "nogroup"
}

data "oci_identity_groups" "existing_security_admin_group" {
  compartment_id = var.tenancy_ocid
  filter {
    name   = "name"
    values = [var.existing_security_admin_group_name]
  }
}

data "oci_identity_group" "existing_network_admin_group" {
  group_id = length(trimspace(var.existing_network_admin_group_name)) > 0 ? var.existing_network_admin_group_name : "nogroup"
}

data "oci_identity_groups" "existing_network_admin_group" {
  compartment_id = var.tenancy_ocid
  filter {
    name   = "name"
    values = [var.existing_network_admin_group_name]
  }
}

data "oci_identity_group" "existing_appdev_admin_group" {
  group_id = length(trimspace(var.existing_appdev_admin_group_name)) > 0 ? var.existing_appdev_admin_group_name : "nogroup"
}

data "oci_identity_groups" "existing_appdev_admin_group" {
  compartment_id = var.tenancy_ocid
  filter {
    name   = "name"
    values = [var.existing_appdev_admin_group_name]
  }
}

data "oci_identity_group" "existing_database_admin_group" {
  group_id = length(trimspace(var.existing_database_admin_group_name)) > 0 ? var.existing_database_admin_group_name : "nogroup"
}

data "oci_identity_groups" "existing_database_admin_group" {
  compartment_id = var.tenancy_ocid
  filter {
    name   = "name"
    values = [var.existing_database_admin_group_name]
  }
}

data "oci_identity_group" "existing_auditor_group" {
  group_id = length(trimspace(var.existing_auditor_group_name)) > 0 ? var.existing_auditor_group_name : "nogroup"
}

data "oci_identity_groups" "existing_auditor_group" {
  compartment_id = var.tenancy_ocid
  filter {
    name   = "name"
    values = [var.existing_auditor_group_name]
  }
}

data "oci_identity_group" "existing_announcement_reader_group" {
  group_id = length(trimspace(var.existing_announcement_reader_group_name)) > 0 ? var.existing_announcement_reader_group_name : "nogroup"
}

data "oci_identity_groups" "existing_announcement_reader_group" {
  compartment_id = var.tenancy_ocid
  filter {
    name   = "name"
    values = [var.existing_announcement_reader_group_name]
  }
}

data "oci_identity_group" "existing_exainfra_admin_group" {
  group_id = length(trimspace(var.existing_exainfra_admin_group_name)) > 0 ? var.existing_exainfra_admin_group_name : "nogroup"
}

data "oci_identity_groups" "existing_exainfra_admin_group" {
  compartment_id = var.tenancy_ocid
  filter {
    name   = "name"
    values = [var.existing_exainfra_admin_group_name]
  }
}

data "oci_identity_group" "existing_cost_admin_group" {
  group_id = length(trimspace(var.existing_cost_admin_group_name)) > 0 ? var.existing_cost_admin_group_name : "nogroup"
}

data "oci_identity_groups" "existing_cost_admin_group" {
  compartment_id = var.tenancy_ocid
  filter {
    name   = "name"
    values = [var.existing_cost_admin_group_name]
  }
}

data "oci_identity_group" "existing_storage_admin_group" {
  group_id = length(trimspace(var.existing_storage_admin_group_name)) > 0 ? var.existing_storage_admin_group_name : "nogroup"
}

data "oci_identity_groups" "existing_storage_admin_group" {
  compartment_id = var.tenancy_ocid
  filter {
    name   = "name"
    values = [var.existing_storage_admin_group_name]
  }
}

data "oci_identity_dynamic_groups" "existing_security_fun_dyn_group" {
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
}

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
    values = [local.network_compartment.name]
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
    values = [local.security_compartment.name]
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
    values = [local.appdev_compartment.name]
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
    values = [local.database_compartment.name]
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
    values = [local.exainfra_compartment.name]
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
