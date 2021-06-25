# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "lz_dynamic_groups" {
  source = "../modules/iam/iam-dynamic-group"
  depends_on = [ module.lz_top_compartments ]
  for_each = local.enclosing_compartments
    dynamic_groups = {
        ("${each.key}-fun-dynamic-grp") = {
            compartment_id = var.tenancy_ocid
            description    = "Dynamic Group for functions in compartment ${each.key}"
            matching_rule  = "ALL {resource.type = 'fnfunc',resource.compartment.id = '${module.lz_top_compartments.compartments[each.key].id}'}"
        }
    }
}

