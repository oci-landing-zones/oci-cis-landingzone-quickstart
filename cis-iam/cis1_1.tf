### Service level admins are created to manage resources of a particular service
# Networking service
module "network_admins" {
  #depends_on            = [module.compartments]
  source                = "../modules/iam/iam-group"
  tenancy_ocid          = var.tenancy_ocid
  group_name            = local.network_admin_group_name
  group_description     = "Group responsible for managing networking in compartment ${local.network_compartment_name_output}."
  user_names            = []
  policy_compartment_id = var.tenancy_ocid
  policy_name           = "${var.service_label}-NetworkAdmins-Policy"
  policy_description    = "Policy allowing ${var.service_label}-NetworkAdmins group to manage virtual-network-family in compartment ${local.network_compartment_name_output}."
  policy_statements     = ["Allow group ${module.network_admins.group_name} to manage virtual-network-family in compartment ${local.network_compartment_name_output}"]
}
# Security services
module "security_admins" {
  source                = "../modules/iam/iam-group"
  tenancy_ocid          = var.tenancy_ocid
  group_name            = local.security_admin_group_name
  group_description     = "Group responsible for managing security services in compartment ${local.security_compartment_name_output}."
  user_names            = []
  policy_compartment_id = var.tenancy_ocid
  policy_name           = "${var.service_label}-SecurityAdmins-Policy"
  policy_description    = "Policy allowing ${var.service_label}-SecurityAdmins group to manage security related services in compartment ${local.security_compartment_name_output}."
  policy_statements     = ["Allow group ${module.security_admins.group_name} to manage vaults in compartment ${local.security_compartment_name_output}",
                           "Allow group ${module.security_admins.group_name} to manage keys in compartment ${local.security_compartment_name_output}",
                           "Allow group ${module.security_admins.group_name} to manage secret-family in compartment ${local.security_compartment_name_output}"]
}
# Compute and Storage services
module "compute_storage_admins" {
  source                = "../modules/iam/iam-group"
  tenancy_ocid          = var.tenancy_ocid
  group_name            = local.compute_storage_admin_group_name
  group_description     = "Group responsible for managing compute instances and storage resources in compartment ${local.compute_storage_compartment_name_output}."
  user_names            = []
  policy_compartment_id = var.tenancy_ocid
  policy_name           = "${var.service_label}-ComputeStorageAdmins-Policy"
  policy_description    = "Policy allowing ${var.service_label}-ComputeStorageAdmins group to manage instance-family and storage resources in compartment ${local.compute_storage_compartment_name_output}."
  policy_statements     = ["Allow group ${module.compute_storage_admins.group_name} to manage instance-family in compartment ${local.compute_storage_compartment_name_output}",
                           "Allow group ${module.compute_storage_admins.group_name} to manage volume-family in compartment ${local.compute_storage_compartment_name_output}",
                           "Allow group ${module.compute_storage_admins.group_name} to manage object-family in compartment ${local.compute_storage_compartment_name_output}",
                           "Allow group ${module.compute_storage_admins.group_name} to manage file-family in compartment ${local.compute_storage_compartment_name_output}"]
}
# Database service
module "database_admins" {
  source                = "../modules/iam/iam-group"
  tenancy_ocid          = var.tenancy_ocid
  group_name            = local.database_admin_group_name
  group_description     = "Group responsible for managing databases in compartment ${local.database_compartment_name_output}."
  user_names            = []
  policy_compartment_id = var.tenancy_ocid
  policy_name           = "${var.service_label}-DatabaseAdmins-Policy"
  policy_description    = "Policy allowing ${var.service_label}-DatabaseAdmins group to manage database-family in compartment ${local.database_compartment_name_output}."
  policy_statements     = ["Allow group ${module.database_admins.group_name} to manage database-family in compartment ${local.database_compartment_name_output}"]
}
# Application Development services
module "appdev_admins" {
  source                = "../modules/iam/iam-group"
  tenancy_ocid          = var.tenancy_ocid
  group_name            = local.appdev_admin_group_name
  group_description     = "Group responsible for managing app development related services in compartment ${local.appdev_compartment_name_output}."
  user_names            = []
  policy_compartment_id = var.tenancy_ocid
  policy_name           = "${var.service_label}-AppDevAdmins-Policy"
  policy_description    = "Policy allowing ${var.service_label}-AppDevAdmins group to manage app development related services in compartment ${local.appdev_compartment_name_output}."
  policy_statements     = ["Allow group ${module.appdev_admins.group_name} to manage functions-family in compartment ${local.appdev_compartment_name_output}",
                           "Allow group ${module.appdev_admins.group_name} to manage api-gateway-family in compartment ${local.appdev_compartment_name_output}",
                           "Allow group ${module.appdev_admins.group_name} to manage ons-family in compartment ${local.appdev_compartment_name_output}",
                           "Allow group ${module.appdev_admins.group_name} to manage streams in compartment ${local.appdev_compartment_name_output}",
                           "Allow group ${module.appdev_admins.group_name} to manage cluster-family in compartment ${local.appdev_compartment_name_output}"]
}