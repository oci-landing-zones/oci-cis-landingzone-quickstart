# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

/* output "group" {
  value = oci_identity_group.this
}
  
output "group_id" {
  value = oci_identity_group.this.id
}

output "group_name" {
  value = oci_identity_group.this.name
}
 */

 output "groups" {
  value = oci_identity_group.these
}

output "memberships" {
  value = local.group_memberships
}