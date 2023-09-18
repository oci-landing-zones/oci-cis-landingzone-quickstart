# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# -- This file supports the creation of tag based policies, which are policies created based on tags that are applied to compartments.
# -- This functionality is supported by the policy module in https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam/tree/main/policies
# -- The default approach is using the supplied policies, defined in iam_policies.tf file.
# -- For using tag based policies, set variable enable_template_policies to true.

locals {
  #-------------------------------------------------------------------------- 
  #-- Any of these custom variables can be overriden in a _override.tf file
  #--------------------------------------------------------------------------
  #-- Custom tags applied to tag based policies.
  custom_template_policies_defined_tags  = null
  custom_template_policies_freeform_tags = null
  workload_policy_prefix                 = var.service_label
  workload_policy_suffix                 = "ply"
}


locals {
  #----------------------------------------------------------------------- 
  #-- These variables are NOT meant to be overriden.
  #-----------------------------------------------------------------------
  default_template_policies_defined_tags  = null
  default_template_policies_freeform_tags = local.landing_zone_tags

  template_policies_defined_tags  = local.custom_template_policies_defined_tags != null ? merge(local.custom_template_policies_defined_tags, local.default_template_policies_defined_tags) : local.default_template_policies_defined_tags
  template_policies_freeform_tags = local.custom_template_policies_freeform_tags != null ? merge(local.custom_template_policies_freeform_tags, local.default_template_policies_freeform_tags) : local.default_template_policies_freeform_tags

  enclosing_compartment_key = "ENCLOSING-CMP"
  security_compartment_key  = "SECURITY-CMP"
  network_compartment_key   = "NETWORK-CMP"

  #------------------------------------------------------------------------
  #----- Policies configuration definition. Input to module.
  #------------------------------------------------------------------------
  app_dev_tenancy_level_roles = [for group in module.workload_groups.groups : { "name" : group.name, "roles" : "application,basic" }]

  # var.workload_team_manages_database ? { "name" : "${local.appdev_admin_group_name}", "roles" : "application,basic" } : { "name" : "${local.appdev_admin_group_name}", "roles" : "application,database,basic" }
  # db_dev_tenancy_level_roles  = var.workload_team_manages_database ? null : { "name" : "${local.database_admin_group_name}", "roles" : "database,basic" }
  tenancy_level_roles = local.app_dev_tenancy_level_roles
  
  empty_template_policies_configuration = {
    enable_cis_benchmark_checks : false
    template_policies : null
    defined_tags : null
    freeform_tags : null
  }

  template_policies_configuration = {
    enable_cis_benchmark_checks : true
    template_policies : {
      tenancy_level_settings : {
        groups_with_tenancy_level_roles : local.tenancy_level_roles
        oci_services : {
          enable_all_policies : true
        }
        policy_name_prefix : var.service_label
      }
      compartment_level_settings : {
        supplied_compartments : merge(local.enclosing_compartment_map, local.existing_compartments_map, local.new_workload_compartments_map)
      }
    }
    defined_tags : local.template_policies_defined_tags
    freeform_tags : local.template_policies_freeform_tags
  }


  # List of groups to apply Apdev 
  cislz-consumer-groups-workloads = join(",", [for group in module.workload_groups.groups : group.name])

  enclosing_compartment_map = {
    (local.enclosing_compartment_key) : {
      name : local.enclosing_lz_compartment_name
      ocid : local.enclosing_lz_compartment_id
      cislz_metadata : {
        "cislz-cmp-type" : "enclosing",
        # "cislz-consumer-groups-security":"${local.security_admin_group_name}",
        "cislz-consumer-groups-application" : "${local.cislz-consumer-groups-workloads}",
        # "cislz-consumer-groups-iam":"${local.iam_admin_group_name}"
      }
    }
  }



  existing_compartments_map = {
    (local.security_compartment_key) : {
      name : local.security_compartment_name
      ocid : var.existing_lz_security_compartment_ocid
      cislz_metadata : {
        "cislz-cmp-type" : "security",
        "cislz-consumer-groups-application" : "${local.cislz-consumer-groups-workloads}",
        # "cislz-consumer-groups-dyn-database-kms":"${local.database_kms_dynamic_group_name}"
      }
    }
    (local.network_compartment_key) : {
      name : local.network_compartment_name
      ocid : var.existing_lz_network_compartment_ocid
      cislz_metadata : {
        "cislz-cmp-type" : "network",
        "cislz-consumer-groups-application" : "${local.cislz-consumer-groups-workloads}",
      }
    }
  }

  new_workload_compartments_map = merge(
    { for cmp in module.workload_compartments.compartments : cmp.name => {
      name : cmp.name,
      ocid : cmp.id,
      cislz_metadata : {
        "cislz-cmp-type" : "application",
        "cislz-consumer-groups-application" : "${lookup(local.workload_compartments, cmp.name).workload_group_name}",
        # "cislz-consumer-groups-dyn-compute-agent":"${local.appdev_computeagent_dynamic_group_name}"
      }
  } })
}

module "lz_template_policies" {
  depends_on             = [module.workload_compartments, module.workload_groups]
  source                 = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam/policies"
  providers              = { oci = oci.home }
  tenancy_ocid           = var.tenancy_ocid
  policies_configuration = var.create_workload_groups_and_policies ? local.template_policies_configuration : local.empty_template_policies_configuration

}
