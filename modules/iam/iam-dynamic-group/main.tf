########################
# Dynamic Group
########################
resource "oci_identity_dynamic_group" "this" {
  count          = "${var.dynamic_group_create ? 1 : 0}"
  compartment_id = "${var.tenancy_ocid}"
  name           = "${var.dynamic_group_name}"
  description    = "${var.dynamic_group_description}"
  matching_rule  = "${var.dynamic_group_rule}"
}

data "oci_identity_dynamic_groups" "this" {
  count          = "${var.dynamic_group_create ? 0 : 1}"
  compartment_id = "${var.tenancy_ocid}"

  filter {
    name   = "name"
    values = ["${var.dynamic_group_name}"]
  }
}

locals {
  dynamic_group_ids = "${concat(flatten(data.oci_identity_dynamic_groups.this.*.groups), list(map("id", "")))}"
}

########################
# Dynamic Group Policy
########################
resource "oci_identity_policy" "this" {
  count          = "${var.policy_create ? 1 : 0}"
  depends_on     = ["oci_identity_dynamic_group.this"]
  name           = "${var.policy_name}"
  description    = "${var.policy_description}"
  compartment_id = "${var.policy_compartment_id}"
  statements     = ["${var.policy_statements}"]
}
