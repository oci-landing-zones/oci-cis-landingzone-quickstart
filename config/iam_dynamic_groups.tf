# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  all_dynamic_groups = {}

  # Names
  security_functions_dynamic_group_name = "${var.service_label}-sec-fun-dynamic-group"
  appdev_functions_dynamic_group_name = "${var.service_label}-appdev-fun-dynamic-group"
  appdev_computeagent_dynamic_group_name = "${var.service_label}-appdev-computeagent-dynamic-group"
  database_kms_dynamic_group_name = "${var.service_label}-database-kms-dynamic-group"

  default_dynamic_groups = var.use_existing_groups == false ? {
    ("${local.security_functions_dynamic_group_name}") = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone dynamic group for functions in ${local.security_compartment.name} compartment."
      matching_rule  = "ALL {resource.type = 'fnfunc',resource.compartment.id = '${module.lz_compartments.compartments[local.security_compartment.key].id}'}"
    },
    ("${local.appdev_functions_dynamic_group_name}") = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone dynamic group for functions in ${local.appdev_compartment.name} compartment."
      matching_rule  = "ALL {resource.type = 'fnfunc',resource.compartment.id = '${module.lz_compartments.compartments[local.appdev_compartment.key].id}'}"
    },
     ("${local.appdev_computeagent_dynamic_group_name}") = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone dynamic group for compute agents in ${local.appdev_compartment.name} compartment."
      matching_rule  = "ALL {resource.type = 'managementagent',resource.compartment.id = '${module.lz_compartments.compartments[local.appdev_compartment.key].id}'}"
    }
    ("${local.database_kms_dynamic_group_name}") = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone dynamic group for databases in ${local.database_compartment.name} compartment."
      matching_rule  = "ALL {resource.compartment.id = '${module.lz_compartments.compartments[local.database_compartment.key].id}'}"
    }
  } : {}
}

module "lz_dynamic_groups" {
  depends_on = [module.lz_compartments]
  source     = "../modules/iam/iam-dynamic-group"
  providers  = { oci = oci.home }
  dynamic_groups = length(local.all_dynamic_groups) > 0 ? local.all_dynamic_groups : local.default_dynamic_groups
}

