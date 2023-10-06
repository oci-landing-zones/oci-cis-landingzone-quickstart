# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  #------------------------------------------------------------------------------------------------------
  #-- Any of these local variables can be overriden in a _override.tf file
  #------------------------------------------------------------------------------------------------------
  custom_dynamic_groups_configuration = null

  custom_dynamic_groups_defined_tags  = null
  custom_dynamic_groups_freeform_tags = null


}


locals {
  #------------------------------------------------------------------------------------------------------
  #-- These variables are not meant to be overriden
  #------------------------------------------------------------------------------------------------------
  appdev_dynamic_group_key = "key"

  #-----------------------------------------------------------
  #----- Tags to apply to dynamic groups
  #-----------------------------------------------------------
  default_dynamic_groups_defined_tags  = null
  default_dynamic_groups_freeform_tags = local.landing_zone_tags

  dynamic_groups_defined_tags  = local.custom_dynamic_groups_defined_tags != null ? merge(local.custom_dynamic_groups_defined_tags, local.default_dynamic_groups_defined_tags) : local.default_dynamic_groups_defined_tags
  dynamic_groups_freeform_tags = local.custom_dynamic_groups_freeform_tags != null ? merge(local.custom_dynamic_groups_freeform_tags, local.default_dynamic_groups_freeform_tags) : local.default_dynamic_groups_freeform_tags

  #--------------------------------------------------------------------
  #-- AppDev functions Dynamic Group
  #--------------------------------------------------------------------

  appdev_functions_dynamic_group = var.create_workload_dynamic_groups_and_policies ? { for key,cmp in local.workload_compartments : ("${key}-${local.appdev_dynamic_group_key}") => {

    name          = "${local.appdev_dynamic_group_name_prefix}-${cmp.workload_name}-${local.appdev_dynamic_group_name_suffix}"
    description   = "Dynamic group for application functions execution for workload ${cmp.workload_name}."
    # matching_rule = "ALL {resource.type = 'fnfunc'"
    matching_rule = "ALL {resource.type = 'fnfunc',resource.compartment.id = '${module.workload_compartments.compartments[key].id}'}"
    defined_tags  = local.dynamic_groups_defined_tags
    freeform_tags = local.dynamic_groups_freeform_tags
    }
  } : {}


  #------------------------------------------------------------------------
  #----- Dynamic groups configuration definition. Input to module.
  #------------------------------------------------------------------------
  dynamic_groups_configuration = {
    dynamic_groups : local.appdev_functions_dynamic_group,

  }

  empty_dynamic_groups_configuration = {
    dynamic_groups : {}
  }
}

module "lz_dynamic_groups" {
  depends_on                   = [module.workload_compartments]
  source                       = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam/dynamic-groups"
  providers                    = { oci = oci.home }
  tenancy_ocid                 = var.tenancy_ocid
  dynamic_groups_configuration = var.create_workload_dynamic_groups_and_policies ? local.dynamic_groups_configuration : local.empty_dynamic_groups_configuration
}