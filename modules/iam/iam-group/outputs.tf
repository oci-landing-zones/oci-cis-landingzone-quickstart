output "group_id" {
  value = element(concat(oci_identity_group.this.*.id, list("")), 0)
}

output "group_name" {
  value = var.group_name
}

output "group_policy_name" {
  value = var.policy_name
}
