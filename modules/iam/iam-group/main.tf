### Group
resource "oci_identity_group" "this" {
  count       = var.group_create ? 1 : 0
  name        = var.group_name
  description = var.group_description
}

### Add user to a group
resource "oci_identity_user_group_membership" "this" {
  count = var.group_create ? length(var.user_ids) : 0
  user_id  = var.user_ids[count.index]
  group_id = element(concat(oci_identity_group.this.*.id, list("")), 0)
}

### Group Policy
resource "oci_identity_policy" "this" {
  count          = var.policy_create ? 1 : 0
  depends_on     = [oci_identity_group.this]
  name           = var.policy_name
  description    = var.policy_description
  compartment_id = var.policy_compartment_id
  statements     = var.policy_statements
}
