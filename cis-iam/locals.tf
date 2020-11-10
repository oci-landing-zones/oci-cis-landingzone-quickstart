locals {
    security_compartment_name        = "${var.service_label}-Security"
    network_compartment_name         = "${var.service_label}-Network"
    compute_storage_compartment_name = "${var.service_label}-ComputeStorage"
    database_compartment_name        = "${var.service_label}-Database"
    appdev_compartment_name          = "${var.service_label}-AppDev" 

    security_compartment_name_output        = module.compartments.compartments[local.security_compartment_name].name
    network_compartment_name_output         = module.compartments.compartments[local.network_compartment_name].name
    compute_storage_compartment_name_output = module.compartments.compartments[local.compute_storage_compartment_name].name
    database_compartment_name_output        = module.compartments.compartments[local.database_compartment_name].name
    appdev_compartment_name_output          = module.compartments.compartments[local.appdev_compartment_name].name

    security_admin_group_name        = "${var.service_label}-SecurityAdmins"
    network_admin_group_name         = "${var.service_label}-NetworkAdmins"
    compute_storage_admin_group_name = "${var.service_label}-ComputeStorageAdmins"
    database_admin_group_name        = "${var.service_label}-DatabaseAdmins"
    appdev_admin_group_name          = "${var.service_label}-AppDevAdmins"
    iam_admin_group_name             = "${var.service_label}-IAMAdmins"
    auditor_group_name               = "${var.service_label}-Auditors"

    rotateby_tag_name                = "RotateBy"
    createdby_tag_name               = "CreatedBy"
    createdon_tag_name               = "CreatedOn"

}