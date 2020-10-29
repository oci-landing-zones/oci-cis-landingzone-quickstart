### Group
resource "oci_identity_group" "this" {
  name        = var.group_name
  description = var.group_description
}

### Add user to a group
resource "oci_identity_user_group_membership" "this" {
  count = length(var.user_ids)
  user_id  = var.user_ids[count.index]
  group_id = oci_identity_group.this.id
}

### Group Policy
resource "oci_identity_policy" "this" {
  depends_on     = [oci_identity_group.this]
  name           = var.policy_name
  description    = var.policy_description
  compartment_id = var.policy_compartment_id
  statements     = var.policy_statements
}
