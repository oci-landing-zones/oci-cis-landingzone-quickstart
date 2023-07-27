# # Copyright (c) 2023 Oracle and/or its affiliates.
# # Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

#-- This file supports the creation of tag based policies, which are policies created based on tags that are applied to compartments.
#-- This functionality is supported by the policy module in https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam/tree/main/policies
#-- The default approach is using the supplied policies, defined in iam_policies.tf file.
#-- For using tag based policies, set variable enable_template_policies to true.

locals {
  #-------------------------------------------------------------------------- 
  #-- Any of these custom variables can be overriden in a _override.tf file
  #--------------------------------------------------------------------------
  #-- Custom tags applied to tag based policies.
  custom_template_policies_defined_tags  = null
  custom_template_policies_freeform_tags = null

}

module "lz_template_policies" {
  depends_on             = [module.workload_compartments, module.workload_groups]
  source                 = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam/policies"
  providers              = { oci = oci.home }
  tenancy_ocid           = var.tenancy_ocid
  policies_configuration = local.template_policies_configuration

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
  app_dev_tenancy_level_roles = var.workload_team_manages_database ? { "name" : "${local.appdev_admin_group_name}", "roles" : "application,basic" } : { "name" : "${local.appdev_admin_group_name}", "roles" : "application,database,basic" }
  db_dev_tenancy_level_roles  = var.workload_team_manages_database ? null : { "name" : "${local.database_admin_group_name}", "roles" : "database,basic" }
  tenancy_level_roles         = local.db_dev_tenancy_level_roles != null ? [local.app_dev_tenancy_level_roles, local.db_dev_tenancy_level_roles] : [local.app_dev_tenancy_level_roles]

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
        supplied_compartments : merge(local.enclosing_compartment_map, local.existing_compartments_map, local.new_compartments_map)
      }
    }
    defined_tags : local.template_policies_defined_tags
    freeform_tags : local.template_policies_freeform_tags
  }



  enclosing_compartment_map = {
    (local.enclosing_compartment_key) : {
      name : local.enclosing_lz_compartment_name
      ocid : local.enclosing_lz_compartment_id
      cislz_metadata : {
        "cislz-cmp-type" : "enclosing",
        # "cislz-consumer-groups-security":"${local.security_admin_group_name}",
        "cislz-consumer-groups-application" : "${local.appdev_admin_group_name}",
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
        "cislz-consumer-groups-application" : "${local.appdev_admin_group_name}",
        "cislz-consumer-groups-database" : "${local.database_admin_group_name}",
        # "cislz-consumer-groups-dyn-database-kms":"${local.database_kms_dynamic_group_name}"
      }
    }
    (local.network_compartment_key) : {
      name : local.network_compartment_name
      ocid : var.existing_lz_network_compartment_ocid
      cislz_metadata : {
        "cislz-cmp-type" : "network",
        "cislz-consumer-groups-application" : "${local.appdev_admin_group_name}",
        "cislz-consumer-groups-database" : "${local.database_admin_group_name}",
      }
    }
  }

  new_compartments_map = merge(
    { for i in [1] : local.workload_compartment_key => {
      name : local.provided_appdev_compartment_name
      ocid : module.workload_compartments.compartments[local.workload_compartment_key].name
      cislz_metadata : {
        "cislz-cmp-type" : "application",
        # "cislz-consumer-groups-security":"${local.security_admin_group_name}",
        "cislz-consumer-groups-application" : "${local.appdev_admin_group_name}",
        "cislz-consumer-groups-database" : "${local.database_admin_group_name}",
        # "cislz-consumer-groups-network":"${local.network_admin_group_name}",
        # "cislz-consumer-groups-storage":"${local.storage_admin_group_name}",
        # "cislz-consumer-groups-exainfra":"${local.exainfra_admin_group_name}",
        # "cislz-consumer-groups-dyn-compute-agent":"${local.appdev_computeagent_dynamic_group_name}"
      }
      }
    },
    { for i in [1] : local.database_compartment_key => {
      name : local.provided_database_compartment_name
      ocid : var.create_database_compartment ? module.workload_compartments.compartments[local.database_compartment_key].name : null
      cislz_metadata : {
        "cislz-cmp-type" : "database",
        # "cislz-consumer-groups-security":"${local.security_admin_group_name}",
        "cislz-consumer-groups-application" : "${local.appdev_admin_group_name}",
        "cislz-consumer-groups-database" : "${local.database_admin_group_name}",
        # "cislz-consumer-groups-network":"${local.network_admin_group_name}",
        # "cislz-consumer-groups-storage":"${local.storage_admin_group_name}",
        # "cislz-consumer-groups-exainfra":"${local.exainfra_admin_group_name}",
        # "cislz-consumer-groups-dyn-database-kms":"${local.database_kms_dynamic_group_name}"
      }
      } if var.create_database_compartment
  })
}

#   # Helper object meaning no policies. It satisfies Terraform's ternary operator.
#   empty_template_policies_configuration = {
#     enable_cis_benchmark_checks : false
#     template_policies : null
#     defined_tags : null
#     freeform_tags : null
#   }
# }


# module "cislz_policies" {
#   tenancy_id = var.tenancy_ocid
#   source                     = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam-compartments.git"
#   target_compartments = local.compartment_policies
#   enable_debug = true
# }