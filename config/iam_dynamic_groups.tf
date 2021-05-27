# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "cis_dynamic_groups" {
    depends_on = [module.cis_compartments]
    source = "../modules/iam/iam-dynamic-group"
    providers = { oci = oci.home }
    dynamic_groups = {
        ("${var.service_label}-sec-fun-dynamic-group") = {
            compartment_id = var.tenancy_ocid
            description    = "Dynamic Group for Functions in ${local.security_compartment_name} compartment"
            matching_rule  = "ALL {resource.type = 'fnfunc',resource.compartment.id = '${module.cis_compartments.compartments[local.security_compartment_name].id}'}"
        },
        ("${var.service_label}-appdev-fun-dynamic-group") = {
            compartment_id = var.tenancy_ocid
            description    = "Dynamic Group for Functions in ${local.appdev_compartment_name} compartment"
            matching_rule  = "ALL {resource.type = 'fnfunc',resource.compartment.id = '${module.cis_compartments.compartments[local.appdev_compartment_name].id}'}"
        }

    }
}

