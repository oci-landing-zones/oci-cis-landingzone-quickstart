# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  all_dynamic_groups_defined_tags = {}
  all_dynamic_groups_freeform_tags = {}

  default_dynamic_groups_defined_tags = {}
  default_dynamic_groups_freeform_tags = {}

  dynamic_groups_defined_tags = length(local.all_dynamic_groups_defined_tags) > 0 ? local.all_dynamic_groups_defined_tags : local.default_dynamic_groups_defined_tags
  dynamic_groups_freeform_tags = length(local.all_dynamic_groups_freeform_tags) > 0 ? local.all_dynamic_groups_freeform_tags : local.default_dynamic_groups_freeform_tags

}

module "lz_dynamic_groups" {
  source     = "../modules/iam/iam-dynamic-group"
  depends_on = [module.lz_top_compartments]
  for_each   = local.enclosing_compartments
  dynamic_groups = {
    ("${each.key}-fun-dynamic-group") = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone dynamic group for functions in compartment ${each.key}"
      defined_tags   = local.dynamic_groups_defined_tags
      freeform_tags  = local.dynamic_groups_freeform_tags
      matching_rule  = "ALL {resource.type = 'fnfunc',resource.compartment.id = '${module.lz_top_compartments.compartments[each.key].id}'}"
    },
    ("${each.key}-adb-dynamic-group") = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone dynamic group for Autonomous Databases in compartment ${each.key}"
      defined_tags   = local.dynamic_groups_defined_tags
      freeform_tags  = local.dynamic_groups_freeform_tags
      matching_rule  = "ALL {resource.type = 'autonomousdatabase',resource.compartment.id = '${module.lz_top_compartments.compartments[each.key].id}'}"
    }
  }
}
