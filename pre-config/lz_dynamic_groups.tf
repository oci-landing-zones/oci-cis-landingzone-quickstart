# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  all_dynamic_groups_defined_tags = {}
  all_dynamic_groups_freeform_tags = {}

  default_dynamic_groups_defined_tags = null
  default_dynamic_groups_freeform_tags = local.landing_zone_tags

  dynamic_groups_defined_tags = length(local.all_dynamic_groups_defined_tags) > 0 ? local.all_dynamic_groups_defined_tags : local.default_dynamic_groups_defined_tags
  dynamic_groups_freeform_tags = length(local.all_dynamic_groups_freeform_tags) > 0 ? merge(local.all_dynamic_groups_freeform_tags, local.default_dynamic_groups_freeform_tags) : local.default_dynamic_groups_freeform_tags
}

module "lz_dynamic_groups" {
  source     = "../modules/iam/iam-dynamic-group"
  depends_on = [module.lz_top_compartments]
  for_each   = local.enclosing_compartments
    dynamic_groups = var.deploy_dynamic_groups ? {
      ("${each.key}-sec-fun-dynamic-group") : {
        compartment_id = var.tenancy_ocid
        description    = "Landing Zone dynamic group for security functions in ${each.key} compartment."
        matching_rule  = "ALL {resource.type = 'fnfunc', resource.compartment.id = '${module.lz_top_compartments.compartments[each.key].id}'}"
        defined_tags   = local.dynamic_groups_defined_tags
        freeform_tags  = local.dynamic_groups_freeform_tags
      },
      ("${each.key}-appdev-fun-dynamic-group") : {
        compartment_id = var.tenancy_ocid
        description    = "Landing Zone dynamic group for appdev functions in ${each.key} compartment."
        matching_rule  = "ALL {resource.type = 'fnfunc', resource.compartment.id = '${module.lz_top_compartments.compartments[each.key].id}'}"
        defined_tags   = local.dynamic_groups_defined_tags
        freeform_tags  = local.dynamic_groups_freeform_tags
      },
      ("${each.key}-appdev-computeagent-dynamic-group") : {
        compartment_id = var.tenancy_ocid
        description    = "Landing Zone dynamic group for compute agents in ${each.key} compartment."
        matching_rule  = "ALL {resource.type = 'managementagent', resource.compartment.id = '${module.lz_top_compartments.compartments[each.key].id}'}"
        defined_tags   = local.dynamic_groups_defined_tags
        freeform_tags  = local.dynamic_groups_freeform_tags
      },
      ("${each.key}-database-kms-dynamic-group") : {
        compartment_id = var.tenancy_ocid
        description    = "Landing Zone dynamic group for databases in ${each.key} compartment."
        matching_rule  = "ALL {resource.compartment.id = '${module.lz_top_compartments.compartments[each.key].id}'}"
        defined_tags   = local.dynamic_groups_defined_tags
        freeform_tags  = local.dynamic_groups_freeform_tags
      }
    } : {}
}
