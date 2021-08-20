# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "lz_dynamic_groups" {
  source     = "../modules/iam/iam-dynamic-group"
  depends_on = [module.lz_top_compartments]
  for_each   = local.enclosing_compartments
  dynamic_groups = {
    ("${each.key}-fun-dynamic-group") = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone dynamic group for functions in compartment ${each.key}"
      matching_rule  = "ALL {resource.type = 'fnfunc',resource.compartment.id = '${module.lz_top_compartments.compartments[each.key].id}'}"
    },
    ("${each.key}-adb-dynamic-group") = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone dynamic group for Autonomous Databases in compartment ${each.key}"
      matching_rule  = "ALL {resource.type = 'autonomousdatabase',resource.compartment.id = '${module.lz_top_compartments.compartments[each.key].id}'}"
    }
  }
}

