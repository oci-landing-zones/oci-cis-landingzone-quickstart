# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

#-- This file supports the creation of tag based policies, which are policies created based on tags that are applied to compartments.
#-- This functionality is supported by the policy module in https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam/tree/main/policies
#-- The default approach is using the supplied policies, defined in iam_policies.tf file.
#-- For using tag based policies, set variable enable_template_policies to true.

locals {
  #------------------------------------------------------------------------------------------------------
  #-- Any of these local variables can be overriden in a _override.tf file
  #------------------------------------------------------------------------------------------------------

  custom_cmps_defined_tags  = null
  custom_cmps_freeform_tags = null

  workload_compartment_key = "key"
  workload_compartment_name_prefix       = var.service_label
  workload_compartment_name_suffix       = "cmp"
  workload_group_prefix                 = var.service_label
  workload_group_suffix                 = "workload-group"
  appdev_dynamic_group_name_prefix    = var.service_label
  appdev_dynamic_group_name_suffix    = "fun-dynamic-group"

}

module "workload_compartments" {
  source                     = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam//compartments?ref=v0.1.6"
  providers                  = { oci = oci.home }
  tenancy_ocid               = var.tenancy_ocid
  compartments_configuration = local.compartments_configuration
}


locals {
  #----------------------------------------------------------------------- 
  #-- These variables are NOT meant to be overriden.
  #-----------------------------------------------------------------------
  default_template_compartment_defined_tags  = null
  default_template_compartment_freeform_tags = local.landing_zone_tags

  # template_policies_defined_tags  = local.custom_template_policies_defined_tags != null ? merge(local.custom_template_policies_defined_tags, local.default_template_compartment_defined_tags) : local.default_template_compartment_defined_tags
  # template_policies_freeform_tags = local.custom_template_policies_freeform_tags != null ? merge(local.custom_template_policies_freeform_tags, local.default_template_compartment_freeform_tags) : local.default_template_compartment_freeform_tags


  enclosing_lz_compartment_id   = var.existing_lz_enclosing_compartment_ocid
  enclosing_lz_compartment_name = data.oci_identity_compartment.existing_lz_enclosing_compartment.name


  #   provided_database_compartment_name = local.custom_database_compartment_name != null ? local.custom_database_compartment_name : "${var.service_label}-${var.database_compartment_name}"
  #   provided_appdev_compartment_name   = local.custom_appdev_compartment_name != null ? local.custom_appdev_compartment_name : "${var.service_label}-${var.workload_compartment_name}"


  workload_compartments = { for cmp in var.workload_names : "${local.workload_compartment_name_prefix}-${cmp}-${local.workload_compartment_name_suffix}" => {
    name : "${local.workload_compartment_name_prefix}-${cmp}-${local.workload_compartment_name_suffix}",
    workload_name : cmp, # This is used for dynamic groups
    workload_group_name : "${local.workload_group_prefix}-${cmp}-${local.workload_group_suffix}", # For policeis
    workload_dynamic_group_name : "${local.appdev_dynamic_group_name_prefix}-${cmp}-${local.appdev_dynamic_group_name_suffix}", # For dynamic groups and policies
    description : "${cmp} workload compartment",
    parent_id : var.existing_lz_appdev_compartment_ocid,
    defined_tags : local.default_template_compartment_defined_tags,
    freeform_tags : local.default_template_compartment_freeform_tags,
    children : {}
    }
  }

  compartments_configuration = {
    # default_parent_ocid = local.enclosing_lz_compartment_id,
    # default_parent_ocid = null,

    compartments = local.workload_compartments
  }

}