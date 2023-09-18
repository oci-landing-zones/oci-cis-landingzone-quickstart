# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_tenancy" "this" {
  tenancy_id = var.tenancy_ocid
}

data "oci_identity_compartment" "existing_lz_enclosing_compartment" {
  id = var.existing_lz_enclosing_compartment_ocid 
}

data "oci_identity_compartment" "existing_lz_appdev_compartment" {
  id = var.existing_lz_appdev_compartment_ocid 
}

data "oci_identity_compartment" "existing_lz_security_compartment" {
  id = var.existing_lz_security_compartment_ocid 
}

data "oci_identity_compartment" "existing_lz_network_compartment" {
  id = var.existing_lz_network_compartment_ocid 
}


data "oci_identity_regions" "these" {}