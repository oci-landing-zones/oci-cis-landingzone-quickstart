# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

#-- This file supports the creation of policies based on metadata associated with compartments.
#-- This functionality is supported by the policy module in https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam/tree/main/policies
#-- The default approach is using the supplied policies, defined in iam_policies.tf file.
#-- For using tag based policies, set variable enable_template_policies to true.

locals {
  #-------------------------------------------------------------------------- 
  #-- Any of these custom variables can be overriden in a _override.tf file
  #--------------------------------------------------------------------------
  #-- Custom tags applied to tag based policies.
  custom_template_policies_defined_tags = null
  custom_template_policies_freeform_tags = null
}  

module "lz_template_policies" {
  depends_on = [module.lz_top_compartment, module.lz_compartments, module.lz_groups, module.lz_dynamic_groups]
  count = var.extend_landing_zone_to_new_region == false && var.enable_template_policies == true ? 1 : 0
  source = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam/policies"
  providers = { oci = oci.home }
  tenancy_ocid = var.tenancy_ocid
  policies_configuration = local.template_policies_configuration
}

locals {
  #----------------------------------------------------------------------- 
  #-- These variables are NOT meant to be overriden.
  #-----------------------------------------------------------------------
  default_template_policies_defined_tags = null
  default_template_policies_freeform_tags = local.landing_zone_tags

  template_policies_defined_tags  = local.custom_template_policies_defined_tags != null ? merge(local.custom_template_policies_defined_tags, local.default_template_policies_defined_tags) : local.default_template_policies_defined_tags
  template_policies_freeform_tags = local.custom_template_policies_freeform_tags != null ? merge(local.custom_template_policies_freeform_tags, local.default_template_policies_freeform_tags) : local.default_template_policies_freeform_tags
  
  #------------------------------------------------------------------------
  #----- Policies configuration definition. Input to module.
  #------------------------------------------------------------------------  
  template_policies_configuration = {
    enable_cis_benchmark_checks : true
    template_policies : {
      tenancy_level_settings : {
        groups_with_tenancy_level_roles : concat(
          [for group in local.iam_admin_group_name           : {"name"=group,"roles"="iam"}],
          [for group in local.cred_admin_group_name          : {"name"=group,"roles"="cred"}],
          [for group in local.cost_admin_group_name          : {"name"=group,"roles"="cost"}],
          [for group in local.security_admin_group_name      : {"name"=group,"roles"="security,basic"}],
          [for group in local.appdev_admin_group_name        : {"name"=group,"roles"="application,basic"}],
          [for group in local.auditor_group_name             : {"name"=group,"roles"="auditor"}],
          [for group in local.database_admin_group_name      : {"name"=group,"roles"="database,basic"}],
          [for group in local.exainfra_admin_group_name      : {"name"=group,"roles"="exainfra,basic"}],
          [for group in local.storage_admin_group_name       : {"name"=group,"roles"="basic"}],
          [for group in local.network_admin_group_name       : {"name"=group,"roles"="network,basic"}],
          [for group in local.announcement_reader_group_name : {"name"=group,"roles"="announcement-reader"}]

        )
        oci_services : {
          enable_all_policies : true
        }
      }
      compartment_level_settings : {
        supplied_compartments : merge(local.enclosing_compartment_map, local.enclosed_compartments_map, local.exainfra_compartment_map)
      }
    }
    policy_name_prefix : var.service_label
    defined_tags : local.template_policies_defined_tags
    freeform_tags : local.template_policies_freeform_tags
  }

  #-- This map satisfies managed, existing, and no enclosing compartments. It is merged with managed compartments in supplied_compartments attribute above.
  enclosing_compartment_map = {
    (local.enclosing_compartment_key) : {
      name : local.enclosing_compartment_name
      ocid : local.enclosing_compartment_id
      cislz_metadata : {
        "cislz-cmp-type":"enclosing",
        "cislz-consumer-groups-security":"${join(",",local.security_admin_group_name)}",
        "cislz-consumer-groups-application":"${join(",",local.appdev_admin_group_name)}",
        "cislz-consumer-groups-iam":"${join(",",local.iam_admin_group_name)}"
      }
    }
  }

  enclosed_compartments_map = {
    (local.security_compartment_key) : {
      name : local.provided_security_compartment_name
      ocid : local.security_compartment_id
      cislz_metadata : {
        "cislz-cmp-type":"security",
        "cislz-consumer-groups-security":"${join(",",local.security_admin_group_name)}",
        "cislz-consumer-groups-application":"${join(",",local.appdev_admin_group_name)}",
        "cislz-consumer-groups-database":"${join(",",local.database_admin_group_name)}",
        "cislz-consumer-groups-network":"${join(",",local.network_admin_group_name)}",
        "cislz-consumer-groups-storage":"${join(",",local.storage_admin_group_name)}",
        "cislz-consumer-groups-exainfra":"${join(",",local.exainfra_admin_group_name)}",
        "cislz-consumer-groups-dyn-database-kms":"${local.database_kms_dynamic_group_name}"
      }
    }
    (local.network_compartment_key) : {
      name : local.provided_network_compartment_name
      ocid : local.network_compartment_id
      cislz_metadata : {
        "cislz-cmp-type":"network",
        "cislz-consumer-groups-security":"${join(",",local.security_admin_group_name)}",
        "cislz-consumer-groups-application":"${join(",",local.appdev_admin_group_name)}",
        "cislz-consumer-groups-database":"${join(",",local.database_admin_group_name)}",
        "cislz-consumer-groups-network":"${join(",",local.network_admin_group_name)}",
        "cislz-consumer-groups-storage":"${join(",",local.storage_admin_group_name)}",
        "cislz-consumer-groups-exainfra":"${join(",",local.exainfra_admin_group_name)}"
      }
    }
    (local.appdev_compartment_key) : {
      name : local.provided_appdev_compartment_name
      ocid : local.appdev_compartment_id
      cislz_metadata : {
        "cislz-cmp-type":"application",
        "cislz-consumer-groups-security":"${join(",",local.security_admin_group_name)}",
        "cislz-consumer-groups-application":"${join(",",local.appdev_admin_group_name)}",
        "cislz-consumer-groups-database":"${join(",",local.database_admin_group_name)}",
        "cislz-consumer-groups-network":"${join(",",local.network_admin_group_name)}",
        "cislz-consumer-groups-storage":"${join(",",local.storage_admin_group_name)}",
        "cislz-consumer-groups-exainfra":"${join(",",local.exainfra_admin_group_name)}",
        "cislz-consumer-groups-dyn-compute-agent":"${local.appdev_computeagent_dynamic_group_name}"
      }
    }
    (local.database_compartment_key) : {
      name : local.provided_database_compartment_name
      ocid : local.database_compartment_id
      cislz_metadata : {
        "cislz-cmp-type":"database",
        "cislz-consumer-groups-security":"${join(",",local.security_admin_group_name)}",
        "cislz-consumer-groups-application":"${join(",",local.appdev_admin_group_name)}",
        "cislz-consumer-groups-database":"${join(",",local.database_admin_group_name)}",
        "cislz-consumer-groups-network":"${join(",",local.network_admin_group_name)}",
        "cislz-consumer-groups-storage":"${join(",",local.storage_admin_group_name)}",
        "cislz-consumer-groups-exainfra":"${join(",",local.exainfra_admin_group_name)}",
        "cislz-consumer-groups-dyn-database-kms":"${local.database_kms_dynamic_group_name}"
      }
    }
  }

  exainfra_compartment_map = local.enable_exainfra_compartment ? {
    (local.exainfra_compartment_key) : {
      name : local.provided_exainfra_compartment_name
      ocid : local.exainfra_compartment_id
      cislz_metadata : {
        "cislz-cmp-type":"exainfra",
        "cislz-consumer-groups-security":"${join(",",local.security_admin_group_name)}",
        "cislz-consumer-groups-application":"${join(",",local.appdev_admin_group_name)}",
        "cislz-consumer-groups-database":"${join(",",local.database_admin_group_name)}",
        "cislz-consumer-groups-network":"${join(",",local.network_admin_group_name)}",
        "cislz-consumer-groups-storage":"${join(",",local.storage_admin_group_name)}",
        "cislz-consumer-groups-exainfra":"${join(",",local.exainfra_admin_group_name)}"
      }
    }
  } : {}
}