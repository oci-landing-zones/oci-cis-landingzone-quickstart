variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}

provider "oci" {
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region           = "${var.region}"
}

/*
 * This example shows how to reference an existing compartment as a resource (compartment_create = false),
 * or if a compartment needs to be created, please set compartment_create = true.
 * Also this example shows how to create two users, a group and add two users to it, and create a policy
 * pertaining to a compartment and group.
 * And some more directives to show dynamic groups and policy for it.
 *
 * Note: the compartment resource internally resolves name collisions and returns a reference to the preexisting
 * compartment. Compartments can not be deleted, so removing a compartment resource from your .tf file will only
 * remove it from your statefile. User, group and dynamic group created by this example can be deleted by using
 * terrafrom destroy.
 */

module "iam_compartment" {
  source                  = "../modules/iam-compartment"
  tenancy_ocid            = "${var.tenancy_ocid}"
  compartment_name        = "tf_example_compartment"
  compartment_description = "compartment created by terraform"
  compartment_create      = false
}

module "iam_user1" {
  source           = "../modules/iam-user"
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_name        = "tf_example_user1@oracle.com"
  user_description = "user1 created by terraform"
}

module "iam_user2" {
  source           = "../modules/iam-user"
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_name        = "tf_example_user2@oracle.com"
  user_description = "user2 created by terraform"
}

module "iam_group" {
  source                = "../modules/iam-group"
  tenancy_ocid          = "${var.tenancy_ocid}"
  group_name            = "tf_example_group"
  group_description     = "group created by terraform"
  user_count            = 2
  user_ids              = ["${module.iam_user1.user_id}", "${module.iam_user2.user_id}"]
  policy_compartment_id = "${module.iam_compartment.compartment_id}"
  policy_name           = "tf-example-policy"
  policy_description    = "policy created by terraform"
  policy_statements     = ["Allow group tf_example_group to read instances in compartment tf_example_compartment", "Allow group tf_example_group to inspect instances in compartment tf_example_compartment"]
}

module "iam_dynamic_group" {
  source                    = "../modules/iam-dynamic-group"
  tenancy_ocid              = "${var.tenancy_ocid}"
  dynamic_group_name        = "tf_example_dynamic_group"
  dynamic_group_description = "dynamic group created by terraform"
  dynamic_group_rule        = "instance.compartment.id = '${module.iam_compartment.compartment_id}'"
  policy_compartment_id     = "${module.iam_compartment.compartment_id}"
  policy_name               = "tf-example-dynamic-policy"
  policy_description        = "dynamic policy created by terraform"
  policy_statements         = ["Allow dynamic-group tf_example_dynamic_group to read instances in compartment tf_example_compartment"]
}
