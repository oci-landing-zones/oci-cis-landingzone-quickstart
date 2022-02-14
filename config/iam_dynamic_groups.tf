# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  all_dynamic_groups = {}
  all_dynamic_groups_defined_tags   = {}
  all_dynamic_groups_freeform_tags  = {}

  # Names
  security_functions_dynamic_group_name  = length(trimspace(var.existing_security_fun_dyn_group_name)) == 0  ?  "${var.service_label}-sec-fun-dynamic-group" : data.oci_identity_dynamic_groups.existing_security_fun_dyn_group.dynamic_groups[0].name
  appdev_functions_dynamic_group_name    = length(trimspace(var.existing_appdev_fun_dyn_group_name)) == 0  ?  "${var.service_label}-appdev-fun-dynamic-group" : data.oci_identity_dynamic_groups.existing_appdev_fun_dyn_group.dynamic_groups[0].name
  appdev_computeagent_dynamic_group_name = length(trimspace(var.existing_compute_agent_dyn_group_name)) == 0  ? "${var.service_label}-appdev-computeagent-dynamic-group" : data.oci_identity_dynamic_groups.existing_compute_agent_dyn_group.dynamic_groups[0].name
  database_kms_dynamic_group_name        = length(trimspace(var.existing_database_kms_dyn_group_name)) == 0  ?  "${var.service_label}-database-kms-dynamic-group" : data.oci_identity_dynamic_groups.existing_database_kms_dyn_group.dynamic_groups[0].name


  default_dynamic_groups = merge(
    { for i in [1] : (local.security_functions_dynamic_group_name) => {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone dynamic group for functions in ${local.security_compartment.name} compartment."
      matching_rule  = "ALL {resource.type = 'fnfunc',resource.compartment.id = '${local.security_compartment_id}'}"
      defined_tags = local.dynamic_groups_defined_tags
      freeform_tags = local.dynamic_groups_freeform_tags
    } if length(trimspace(var.existing_security_fun_dyn_group_name)) == 0},
    { for i in [1] : (local.appdev_functions_dynamic_group_name) => {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone dynamic group for functions in ${local.appdev_compartment.name} compartment."
      matching_rule  = "ALL {resource.type = 'fnfunc',resource.compartment.id = '${local.appdev_compartment_id}'}"
      defined_tags = local.dynamic_groups_defined_tags
      freeform_tags = local.dynamic_groups_freeform_tags
    } if length(trimspace(var.existing_appdev_fun_dyn_group_name)) == 0},
    { for i in [1] : (local.appdev_computeagent_dynamic_group_name) => {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone dynamic group for compute agents in ${local.appdev_compartment.name} compartment."
      matching_rule  = "ALL {resource.type = 'managementagent',resource.compartment.id = '${local.appdev_compartment_id}'}"
      defined_tags = local.dynamic_groups_defined_tags
      freeform_tags = local.dynamic_groups_freeform_tags
    } if length(trimspace(var.existing_compute_agent_dyn_group_name)) == 0},
    { for i in [1] : (local.database_kms_dynamic_group_name) => {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone dynamic group for databases in ${local.database_compartment.name} compartment."
      matching_rule  = "ALL {resource.compartment.id = '${local.database_compartment_id}'}"
      defined_tags = local.dynamic_groups_defined_tags
      freeform_tags = local.dynamic_groups_freeform_tags
    } if length(trimspace(var.existing_database_kms_dyn_group_name)) == 0}
  )

  ### DON'T TOUCH THESE ###
  default_dynamic_groups_defined_tags  = null
  default_dynamic_groups_freeform_tags = local.landing_zone_tags

  dynamic_groups_defined_tags  = length(local.all_dynamic_groups_defined_tags) > 0 ? local.all_dynamic_groups_defined_tags : local.default_dynamic_groups_defined_tags
  dynamic_groups_freeform_tags = length(local.all_dynamic_groups_freeform_tags) > 0 ? merge(local.all_dynamic_groups_freeform_tags, local.default_dynamic_groups_freeform_tags) : local.default_dynamic_groups_freeform_tags

}

module "lz_dynamic_groups" {
  depends_on = [module.lz_compartments]
  source     = "../modules/iam/iam-dynamic-group"
  providers  = { oci = oci.home }
  #dynamic_groups = length(local.all_dynamic_groups) > 0 ? local.all_dynamic_groups : local.default_dynamic_groups
  dynamic_groups = var.extend_landing_zone_to_new_region == false ? (length(local.all_dynamic_groups) > 0 ? local.all_dynamic_groups : local.default_dynamic_groups) : {}
}

