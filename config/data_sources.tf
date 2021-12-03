# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_regions" "these" {}

data "oci_identity_tenancy" "this" {
  tenancy_id = var.tenancy_ocid
}

 data "oci_identity_compartment" "existing_enclosing_compartment" {
  id = var.existing_enclosing_compartment_ocid != null ? var.existing_enclosing_compartment_ocid : var.tenancy_ocid
}

/* data "oci_identity_compartment" "existing_enclosing_compartment" {
  id = var.existing_enclosing_compartment_ocid
} */

data "oci_identity_groups" "existing_iam_admin_group" {
  compartment_id = var.tenancy_ocid
  filter {
    name   = "name"
    values = [var.existing_iam_admin_group_name]
  }
}

data "oci_identity_groups" "existing_cred_admin_group" {
  compartment_id = var.tenancy_ocid
  filter {
    name   = "name"
    values = [var.existing_cred_admin_group_name]
  }
}

data "oci_identity_groups" "existing_security_admin_group" {
  compartment_id = var.tenancy_ocid
  filter {
    name   = "name"
    values = [var.existing_security_admin_group_name]
  }
}

data "oci_identity_groups" "existing_network_admin_group" {
  compartment_id = var.tenancy_ocid
  filter {
    name   = "name"
    values = [var.existing_network_admin_group_name]
  }
}

data "oci_identity_groups" "existing_appdev_admin_group" {
  compartment_id = var.tenancy_ocid
  filter {
    name   = "name"
    values = [var.existing_appdev_admin_group_name]
  }
}

data "oci_identity_groups" "existing_database_admin_group" {
  compartment_id = var.tenancy_ocid
  filter {
    name   = "name"
    values = [var.existing_database_admin_group_name]
  }
}

data "oci_identity_groups" "existing_auditor_group" {
  compartment_id = var.tenancy_ocid
  filter {
    name   = "name"
    values = [var.existing_auditor_group_name]
  }
}

data "oci_identity_groups" "existing_announcement_reader_group" {
  compartment_id = var.tenancy_ocid
  filter {
    name   = "name"
    values = [var.existing_announcement_reader_group_name]
  }
}

data "oci_identity_groups" "existing_exainfra_admin_group" {
  compartment_id = var.tenancy_ocid
  filter {
    name   = "name"
    values = [var.existing_exainfra_admin_group_name]
  }
}

data "oci_identity_groups" "existing_cost_admin_group" {
  compartment_id = var.tenancy_ocid
  filter {
    name   = "name"
    values = [var.existing_cost_admin_group_name]
  }
}


data "oci_cloud_guard_cloud_guard_configuration" "this" {
  compartment_id = var.tenancy_ocid
}

data "oci_objectstorage_namespace" "this" {
  compartment_id = var.tenancy_ocid
}

data "oci_identity_compartment" "network" {
  id = var.existing_network_cmp_ocid != null ? var.existing_network_cmp_ocid : "mustneverhappen"
}

data "oci_identity_compartment" "security" {
  id = var.existing_security_cmp_ocid != null ? var.existing_security_cmp_ocid : "mustneverhappen"
}

data "oci_identity_compartment" "appdev" {
  id = var.existing_appdev_cmp_ocid != null ? var.existing_appdev_cmp_ocid : "mustneverhappen"
}

data "oci_identity_compartment" "database" {
  id = var.existing_database_cmp_ocid != null ? var.existing_database_cmp_ocid : "mustneverhappen"
}

data "oci_identity_compartment" "exainfra" {
  id = var.existing_exainfra_cmp_ocid != null ? var.existing_exainfra_cmp_ocid : "mustneverhappen"
}

data "oci_identity_tag_namespaces" "this" {
  compartment_id = var.tenancy_ocid
}

/*
data "oci_ons_notification_topics" "iam" {
  compartment_id = local.security_compartment_id
  name = local.iam_topic_name
}

data "oci_events_rules" "iam" {
  compartment_id  = var.tenancy_ocid
  display_name = local.iam_events_rule_name
}
*/