### Service level admins are created to manage resources of a particular service
# Networking service
module "network_admins" {
  source                = "../modules/iam/iam-group"
  tenancy_ocid          = var.tenancy_ocid
  group_name            = "${var.service_label}-NetworkAdmins"
  group_description     = "Group responsible for managing networking in the tenancy."
  user_ids              = []
  policy_compartment_id = var.tenancy_ocid
  policy_name           = "${var.service_label}-NetworkAdmins-Policy"
  policy_description    = "Policy allowing NetworkAdmins group to manage virtual-network-family in tenancy."
  policy_statements     = ["Allow group ${module.network_admins.group_name} to manage virtual-network-family in tenancy"]
}
# Compute service
module "compute_admins" {
  source                = "../modules/iam/iam-group"
  tenancy_ocid          = var.tenancy_ocid
  group_name            = "${var.service_label}-ComputeAdmins"
  group_description     = "Group responsible for managing compute instances in the tenancy."
  user_ids              = []
  policy_compartment_id = var.tenancy_ocid
  policy_name           = "${var.service_label}-ComputeAdmins-Policy"
  policy_description    = "Policy allowing ComputeAdmins group to manage instance-family in tenancy."
  policy_statements     = ["Allow group ${module.compute_admins.group_name} to manage instance-family in tenancy"]
}
# Volume service
module "volume_admins" {
  source                = "../modules/iam/iam-group"
  tenancy_ocid          = var.tenancy_ocid
  group_name            = "${var.service_label}-VolumeAdmins"
  group_description     = "Group responsible for managing volumes in the tenancy."
  user_ids              = []
  policy_compartment_id = var.tenancy_ocid
  policy_name           = "${var.service_label}-VolumeAdmins-Policy"
  policy_description    = "Policy allowing VolumeAdmins group to manage volume-family in tenancy."
  policy_statements     = ["Allow group ${module.volume_admins.group_name} to manage volume-family in tenancy"]
}
# Object Store service
module "objectstore_admins" {
  source                = "../modules/iam/iam-group"
  tenancy_ocid          = var.tenancy_ocid
  group_name            = "${var.service_label}-ObjectStoreAdmins"
  group_description     = "Group responsible for managing object store in the tenancy."
  user_ids              = []
  policy_compartment_id = var.tenancy_ocid
  policy_name           = "${var.service_label}-ObjectStoreAdmins-Policy"
  policy_description    = "Policy allowing ObjectStoreAdmins group to manage object-family in tenancy."
  policy_statements     = ["Allow group ${module.objectstore_admins.group_name} to manage object-family in tenancy"]
}