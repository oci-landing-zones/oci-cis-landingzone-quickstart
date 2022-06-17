# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

/* ### Group
resource "oci_identity_group" "this" {
  name           = var.group_name
  description    = var.group_description
  compartment_id = var.tenancy_ocid
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
  count = data.oci_identity_users.these.users != null ? length(data.oci_identity_users.these.users) : 0
  user_id  = data.oci_identity_users.these.users[count.index].id
  group_id = oci_identity_group.this.id
} */

locals {
  groups = { for g in oci_identity_group.these : g.name => g }
  users  = { for u in data.oci_identity_users.these.users : u.name => u }

  group_memberships = flatten([
    for k, v in var.groups : [
      for user_id in v.user_ids : {
        group_name = k
        user_id    = user_id
      }
    ]
  ])
}

data "oci_identity_users" "these" {
  compartment_id = var.tenancy_ocid
}

resource "oci_identity_group" "these" {
  for_each       = var.groups
    compartment_id = var.tenancy_ocid
    name           = each.key
    description    = each.value.description
    defined_tags   = each.value.defined_tags
    freeform_tags  = each.value.freeform_tags
}

resource "oci_identity_user_group_membership" "these" {
  for_each = { for m in local.group_memberships : "${m.group_name}.${m.user_id}" => m }
  group_id = local.groups[each.value.group_name].id
  user_id  = local.users[each.value.user_id].id
}