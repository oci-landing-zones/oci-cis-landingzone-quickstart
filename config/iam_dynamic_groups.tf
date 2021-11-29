# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "lz_dynamic_groups" {
  depends_on = [module.lz_compartments]
  source     = "../modules/iam/iam-dynamic-group"
  providers  = { oci = oci.home }
  dynamic_groups = var.use_existing_groups == false || var.extend_landing_zone_to_new_region == false ? {
    ("${var.service_label}-sec-fun-dynamic-group") = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone dynamic group for functions in ${local.security_compartment.name} compartment."
      matching_rule  = "ALL {resource.type = 'fnfunc',resource.compartment.id = '${local.security_compartment_id}'}"
      defined_tags   = null
      freeform_tags  = null
    },
    ("${var.service_label}-appdev-fun-dynamic-group") = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone dynamic group for functions in ${local.appdev_compartment.name} compartment."
      matching_rule  = "ALL {resource.type = 'fnfunc',resource.compartment.id = '${local.appdev_compartment_id}'}"
      defined_tags   = null
      freeform_tags  = null
    },
     ("${var.service_label}-appdev-computeagent-dynamic-group") = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone dynamic group for compute agents in ${local.appdev_compartment.name} compartment."
      matching_rule  = "ALL {resource.type = 'managementagent',resource.compartment.id = '${module.lz_compartments.compartments[local.appdev_compartment.key].id}'}"
      defined_tags   = null
      freeform_tags  = null
    }
    ("${var.service_label}-database-kms-dynamic-group") = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone dynamic group for databases in ${local.database_compartment.name} compartment."
      matching_rule  = "ALL {resource.compartment.id = '${local.database_compartment_id}'}"
      defined_tags   = null
      freeform_tags  = null
    }
  } : {}
}

