# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "lz_dynamic_groups" {
  depends_on = [module.lz_compartments]
  source     = "../modules/iam/iam-dynamic-group"
  providers  = { oci = oci.home }
  dynamic_groups = var.use_existing_iam_groups == false ? {
    ("${var.service_label}-sec-fun-dynamic-grp") = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone dynamic group for functions in ${local.security_compartment_name} compartment."
      matching_rule  = "ALL {resource.type = 'fnfunc',resource.compartment.id = '${module.lz_compartments.compartments[local.security_compartment_name].id}'}"
    },
    ("${var.service_label}-appdev-fun-dynamic-grp") = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone dynamic group for functions in ${local.appdev_compartment_name} compartment."
      matching_rule  = "ALL {resource.type = 'fnfunc',resource.compartment.id = '${module.lz_compartments.compartments[local.appdev_compartment_name].id}'}"
    }
  } : {}
}

