output "group_id" {
  value = oci_identity_group.this.id
}

output "group_name" {
  value = var.group_name
}

output "group_policy_name" {
  value = var.policy_name
}
