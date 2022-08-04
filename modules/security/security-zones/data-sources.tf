# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_compartment" "single_compartment" {
  count = var.single_compartment_id != null ? 1 : 0
  id    = var.single_compartment_id
}

data "oci_identity_compartment" "enclosing_compartment" {
  count = var.enclosing_compartment_id != null ? 1 : 0
  id    = var.enclosing_compartment_id
}

data "oci_identity_compartment" "appdev_compartment" {
  count = var.appdev_compartment_id != null ? 1 : 0
  id    = var.appdev_compartment_id
}

data "oci_identity_compartment" "database_compartment" {
  count = var.database_compartment_id != null ? 1 : 0
  id    = var.database_compartment_id
}

data "oci_identity_compartment" "network_compartment" {
  count = var.network_compartment_id != null ? 1 : 0
  id    = var.network_compartment_id
}

data "oci_identity_compartment" "security_compartment" {
  count = var.security_compartment_id != null ? 1 : 0
  id    = var.security_compartment_id
}


data "oci_identity_compartment" "exadata_compartment" {
  count = var.exadata_compartment_id != null ? 1 : 0
  id    = var.exadata_compartment_id
}