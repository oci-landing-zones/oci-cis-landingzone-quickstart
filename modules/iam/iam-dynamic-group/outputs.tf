output "dynamic_group_id" {
  value = "${var.dynamic_group_create ? element(concat(oci_identity_dynamic_group.this.*.id, list("")), 0) : lookup(local.dynamic_group_ids[0], "id") }"
}

output "dynamic_group_name" {
  value = "${var.dynamic_group_name}"
}

output "dynamic_group_policy_name" {
  value = "${var.policy_name}"
}
