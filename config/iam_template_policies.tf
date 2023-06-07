# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

#-- This file supports the creation of tag based policies, which are policies created based on tags that are applied to compartments.
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
  #source = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam/policies"
  source = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam//policies?ref=issue-6-cmp-metadata"
  providers = { oci = oci.home }
  tenancy_ocid = var.tenancy_ocid
  policies_configuration = var.extend_landing_zone_to_new_region == false && var.enable_template_policies == true ? local.template_policies_configuration : local.empty_template_policies_configuration
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
        groups_with_tenancy_level_roles : [
          {"name":"${local.cred_admin_group_name}",    "roles":"cred"},
          {"name":"${local.cost_admin_group_name}",    "roles":"cost"},
          {"name":"${local.security_admin_group_name}","roles":"security,basic"},
          {"name":"${local.network_admin_group_name}", "roles":"network,basic"},
          {"name":"${local.appdev_admin_group_name}",  "roles":"application,basic"},
          {"name":"${local.database_admin_group_name}","roles":"database,basic"},
          {"name":"${local.exainfra_admin_group_name}","roles":"exainfra,basic"},
          {"name":"${local.storage_admin_group_name}", "roles":"basic"},
          {"name":"${local.auditor_group_name}",       "roles":"auditor"},
          {"name":"${local.announcement_reader_group_name}","roles":"announcement-reader"}
        ]
        policy_name_prefix : var.service_label
      }
      compartment_level_settings : {
        supplied_compartments : var.enable_template_policies == true ? {for k, v in merge(module.lz_compartments.compartments, local.enclosing_compartment_map) : k => {"name": v.name, "ocid": v.id, "cislz_metadata": local.cislz_compartments_metadata[v.freeform_tags["cislz-cmp-type"]]}} : {}
      }
    }
    defined_tags : local.template_policies_defined_tags
    freeform_tags : local.template_policies_freeform_tags
  }

  #-- This map satisfies managed, existing, and no enclosing compartments. It is merged with managed compartments in supplied_compartments attribute above.
  enclosing_compartment_map = {
    (local.enclosing_compartment_key) : {
      name : local.enclosing_compartment_name
      id : local.enclosing_compartment_id
      freeform_tags : {"cislz-cmp-type" : "enclosing"}
    }
  }

  cislz_compartments_metadata = {
    "enclosing" : {
      "cislz-cmp-type":"enclosing",
      "cislz-consumer-groups-security":"${local.security_admin_group_name}",
      "cislz-consumer-groups-application":"${local.appdev_admin_group_name}",
      "cislz-consumer-groups-iam":"${local.iam_admin_group_name}"
    },
    "network" : {
      "cislz-cmp-type":"network",
      "cislz-consumer-groups-security":"${local.security_admin_group_name}",
      "cislz-consumer-groups-application":"${local.appdev_admin_group_name}",
      "cislz-consumer-groups-database":"${local.database_admin_group_name}",
      "cislz-consumer-groups-network":"${local.network_admin_group_name}",
      "cislz-consumer-groups-storage":"${local.storage_admin_group_name}",
      "cislz-consumer-groups-exainfra":"${local.exainfra_admin_group_name}"
    },
    "security" : {
      "cislz-cmp-type":"security",
      "cislz-consumer-groups-security":"${local.security_admin_group_name}",
      "cislz-consumer-groups-application":"${local.appdev_admin_group_name}",
      "cislz-consumer-groups-database":"${local.database_admin_group_name}",
      "cislz-consumer-groups-network":"${local.network_admin_group_name}",
      "cislz-consumer-groups-storage":"${local.storage_admin_group_name}",
      "cislz-consumer-groups-exainfra":"${local.exainfra_admin_group_name}",
      "cislz-consumer-groups-dyn-database-kms":"${local.database_kms_dynamic_group_name}"
    },
    "application" : {
      "cislz-cmp-type":"application",
      "cislz-consumer-groups-security":"${local.security_admin_group_name}",
      "cislz-consumer-groups-application":"${local.appdev_admin_group_name}",
      "cislz-consumer-groups-database":"${local.database_admin_group_name}",
      "cislz-consumer-groups-network":"${local.network_admin_group_name}",
      "cislz-consumer-groups-storage":"${local.storage_admin_group_name}",
      "cislz-consumer-groups-exainfra":"${local.exainfra_admin_group_name}",
      "cislz-consumer-groups-dyn-compute-agent":"${local.appdev_computeagent_dynamic_group_name}"
    }, 
    "database" : {
      "cislz-cmp-type":"database",
      "cislz-consumer-groups-security":"${local.security_admin_group_name}",
      "cislz-consumer-groups-application":"${local.appdev_admin_group_name}",
      "cislz-consumer-groups-database":"${local.database_admin_group_name}",
      "cislz-consumer-groups-network":"${local.network_admin_group_name}",
      "cislz-consumer-groups-storage":"${local.storage_admin_group_name}",
      "cislz-consumer-groups-exainfra":"${local.exainfra_admin_group_name}"
    },
    "exainfra" : {
      "cislz-cmp-type":"exainfra",
      "cislz-consumer-groups-security":"${local.security_admin_group_name}",
      "cislz-consumer-groups-application":"${local.appdev_admin_group_name}",
      "cislz-consumer-groups-database":"${local.database_admin_group_name}",
      "cislz-consumer-groups-network":"${local.network_admin_group_name}",
      "cislz-consumer-groups-storage":"${local.storage_admin_group_name}",
      "cislz-consumer-groups-exainfra":"${local.exainfra_admin_group_name}"
    }
  } 

  # Helper object meaning no policies. It satisfies Terraform's ternary operator.
  empty_template_policies_configuration = {
    enable_cis_benchmark_checks : false
    template_policies : null
    defined_tags : null
    freeform_tags : null
  }
}