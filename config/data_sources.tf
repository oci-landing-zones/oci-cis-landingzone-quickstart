# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_compartments" "existing_top_compartment" {
    compartment_id = var.tenancy_ocid
    name = var.existing_top_compartment_name
}