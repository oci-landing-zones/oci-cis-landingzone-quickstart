locals {
    security_compartment_name        = "${var.service_label}-Security"
    network_compartment_name         = "${var.service_label}-Network"
    compute_storage_compartment_name = "${var.service_label}-ComputeStorage"
    appdev_compartment_name          = "${var.service_label}-AppDev"
    database_compartment_name        = "${var.service_label}-Database" 

    security_compartment_name_output        = module.compartments.compartments[local.security_compartment_name].name
    network_compartment_name_output         = module.compartments.compartments[local.network_compartment_name].name
    compute_storage_compartment_name_output = module.compartments.compartments[local.compute_storage_compartment_name].name
    database_compartment_name_output        = module.compartments.compartments[local.database_compartment_name].name
    appdev_compartment_name_output          = module.compartments.compartments[local.appdev_compartment_name].name
}