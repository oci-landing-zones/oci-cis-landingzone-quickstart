locals {
    security_compartment_name        = "${var.service_label}-Security"
    network_compartment_name         = "${var.service_label}-Network"
    compute_storage_compartment_name = "${var.service_label}-ComputeStorage"
    appdev_compartment_name          = "${var.service_label}-AppDev"
    database_compartment_name        = "${var.service_label}-Database" 
}