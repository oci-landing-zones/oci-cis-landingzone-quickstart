locals {
  #------------------------------------------------------------------------------------------------------
  #-- Any of these local variables can be overriden in a _override.tf file
  #------------------------------------------------------------------------------------------------------
  custom_groups_defined_tags  = null
  custom_groups_freeform_tags = null

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

  #------------------------------------------------------------------------
  #----- Groups configuration definition. Input to module.
  #------------------------------------------------------------------------  
  groups_configuration = {
    groups : { for group in local.workload_compartments : (group.workload_group_name) => {
      name : group.workload_group_name,
      description : "${group.workload_group_name} workload group",
      members : [],
      defined_tags  = local.groups_defined_tags,
      freeform_tags = local.groups_freeform_tags
      }

    }

  }

  empty_groups_configuration = {
    groups : {}
  }
}

module "workload_groups" {
  source               = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam/groups"
  providers            = { oci = oci.home }
  tenancy_ocid         = var.tenancy_ocid
  groups_configuration = var.create_workload_groups_and_policies ? local.groups_configuration : local.empty_groups_configuration
}