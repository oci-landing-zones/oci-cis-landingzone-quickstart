# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_compartment" "existing_top_compartment" {
    id = var.existing_top_compartment_ocid
}

data "oci_identity_user_group_memberships" "runner" {
    compartment_id = var.tenancy_ocid
    user_id = var.user_ocid
}

data "oci_identity_group" "runner_group" {
    for_each = toset(local.runner_group_ids)
        group_id = each.key
}
