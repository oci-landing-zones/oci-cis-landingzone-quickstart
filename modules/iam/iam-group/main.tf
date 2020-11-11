# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### Group
resource "oci_identity_group" "this" {
  name        = var.group_name
  description = var.group_description
}

data "oci_identity_users" "these" {
  compartment_id = var.tenancy_ocid
  filter {
    name   = "name"
    values = var.user_names
  }
}
### Add users to group
 resource "oci_identity_user_group_membership" "this" {
  count = length(data.oci_identity_users.these.users)
  user_id  = data.oci_identity_users.these.users[count.index].id
  group_id = oci_identity_group.this.id
} 

### Group policy
resource "oci_identity_policy" "this" {
  depends_on     = [oci_identity_group.this]
  name           = var.policy_name
  description    = var.policy_description
  compartment_id = var.policy_compartment_id
  statements     = var.policy_statements
}
