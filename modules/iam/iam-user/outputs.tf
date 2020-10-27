output "user_id" {
  value = "${var.user_create ? element(concat(oci_identity_user.this.*.id, list("")), 0) : lookup(local.user_ids[0], "id") }"
}

output "user_name" {
  value = "${var.user_name}"
}
