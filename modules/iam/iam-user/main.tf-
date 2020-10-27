########################
# User
########################
resource "oci_identity_user" "this" {
  count       = "${var.user_create ? 1 : 0}"
  name        = "${var.user_name}"
  description = "${var.user_description}"
}

data "oci_identity_users" "this" {
  count          = "${var.user_create ? 0 : 1}"
  compartment_id = "${var.tenancy_ocid}"

  filter {
    name   = "name"
    values = ["${var.user_name}"]
  }
}

locals {
  user_ids = "${concat(flatten(data.oci_identity_users.this.*.users), list(map("id", "")))}"
}
