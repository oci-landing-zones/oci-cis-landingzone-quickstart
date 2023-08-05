locals {
  #------------------------------------------------------------------------------------------------------
  #-- Any of these local variables can be overriden in a _override.tf file
  #------------------------------------------------------------------------------------------------------
  custom_groups_defined_tags  = null
  custom_groups_freeform_tags = null

  workload_group_prefix                 = var.service_label
  workload_group_suffix                 = "workload-group"

  #------------------------------------------------------------------------------------------------------
  #-- These variables are not meant to be overriden
  #------------------------------------------------------------------------------------------------------

  #-----------------------------------------------------------
  #----- Tags to apply to groups
  #-----------------------------------------------------------
  default_groups_defined_tags  = null
  default_groups_freeform_tags = local.landing_zone_tags

  groups_defined_tags  = local.custom_groups_defined_tags != null ? merge(local.custom_groups_defined_tags, local.default_groups_defined_tags) : local.default_groups_defined_tags
  groups_freeform_tags = local.custom_groups_freeform_tags != null ? merge(local.custom_groups_freeform_tags, local.default_groups_freeform_tags) : local.default_groups_freeform_tags

  #--------------------------------------------------------------------
  #-- Workload Admin Groups
  #--------------------------------------------------------------------

  #------------------------------------------------------------------------
  #----- Groups configuration definition. Input to module.
  #------------------------------------------------------------------------  
  groups_configuration = {
    groups : { for group in var.workload_names : "${local.workload_group_prefix}-${group}-${local.workload_group_suffix}" => {
      name : "${local.workload_group_prefix}-${group}-${local.workload_group_suffix}",
      description : "${group} workload group",
      members : [],
      defined_tags  = local.groups_defined_tags,
      freeform_tags = local.groups_freeform_tags
      }

    }

  }
}

module "workload_groups" {
  source               = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam/groups"
  providers            = { oci = oci.home }
  tenancy_ocid         = var.tenancy_ocid
  groups_configuration = local.groups_configuration
}