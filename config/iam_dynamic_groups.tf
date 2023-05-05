# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  #------------------------------------------------------------------------------------------------------
  #-- Any of these local variables can be overriden in a _override.tf file
  #------------------------------------------------------------------------------------------------------
  custom_dynamic_groups_configuration = null

  custom_security_fun_dyn_group_name        = null
  custom_appdev_fun_dyn_group_name          = null
  custom_appdev_computeagent_dyn_group_name = null
  custom_database_kms_dyn_group_name        = null

  custom_dynamic_groups_defined_tags   = null
  custom_dynamic_groups_freeform_tags  = null
}

module "lz_dynamic_groups" {
  source     = "git@github.com:oracle-quickstart/terraform-oci-cis-landing-zone-iam.git//dynamic-groups"
  providers  = { oci = oci.home }
  tenancy_ocid = var.tenancy_ocid
  dynamic_groups_configuration = var.extend_landing_zone_to_new_region == false ? (local.custom_dynamic_groups_configuration != null ? local.custom_dynamic_groups_configuration : local.dynamic_groups_configuration) : local.empty_dynamic_groups_configuration
}

locals {
  #------------------------------------------------------------------------------------------------------
  #-- These variables are not meant to be overriden
  #------------------------------------------------------------------------------------------------------

  #-----------------------------------------------------------
  #----- Tags to apply to dynamic groups
  #-----------------------------------------------------------
  default_dynamic_groups_defined_tags  = null
  default_dynamic_groups_freeform_tags = local.landing_zone_tags

  dynamic_groups_defined_tags  = local.custom_dynamic_groups_defined_tags != null ? merge(local.custom_dynamic_groups_defined_tags, local.default_dynamic_groups_defined_tags) : local.default_dynamic_groups_defined_tags
  dynamic_groups_freeform_tags = local.custom_dynamic_groups_freeform_tags != null ? merge(local.custom_dynamic_groups_freeform_tags, local.default_dynamic_groups_freeform_tags) : local.default_dynamic_groups_freeform_tags

  # Names
  #security_functions_dynamic_group_name  = length(trimspace(var.existing_security_fun_dyn_group_name)) == 0  ?  "${var.service_label}-sec-fun-dynamic-group" : data.oci_identity_dynamic_groups.existing_security_fun_dyn_group.dynamic_groups[0].name
  #appdev_functions_dynamic_group_name    = length(trimspace(var.existing_appdev_fun_dyn_group_name)) == 0  ?  "${var.service_label}-appdev-fun-dynamic-group" : data.oci_identity_dynamic_groups.existing_appdev_fun_dyn_group.dynamic_groups[0].name
  #appdev_computeagent_dynamic_group_name = length(trimspace(var.existing_compute_agent_dyn_group_name)) == 0  ? "${var.service_label}-appdev-computeagent-dynamic-group" : data.oci_identity_dynamic_groups.existing_compute_agent_dyn_group.dynamic_groups[0].name
  #database_kms_dynamic_group_name        = length(trimspace(var.existing_database_kms_dyn_group_name)) == 0  ?  "${var.service_label}-database-kms-dynamic-group" : data.oci_identity_dynamic_groups.existing_database_kms_dyn_group.dynamic_groups[0].name

  #--------------------------------------------------------------------
  #-- Security functions Dynamic Group
  #--------------------------------------------------------------------
  security_functions_dynamic_group_key = "${var.service_label}-sec-fun-dynamic-group"
  default_security_functions_dynamic_group_name = "sec-fun-dynamic-group"
  provided_security_functions_dynamic_group_name  = local.custom_security_fun_dyn_group_name != null ? local.custom_security_fun_dyn_group_name : "${var.service_label}-${local.default_security_functions_dynamic_group_name}" #data.oci_identity_dynamic_groups.existing_security_fun_dyn_group.dynamic_groups[0].name
  
  security_functions_dynamic_group = length(trimspace(var.existing_security_fun_dyn_group_name)) == 0 ? {
    (local.security_functions_dynamic_group_key) = {
      name          = local.provided_security_functions_dynamic_group_name  
      description   = "CIS Landing Zone dynamic group for security functions execution."
      matching_rule = "ALL {resource.type = 'fnfunc',resource.compartment.id = '${local.security_compartment_id}'}"
      defined_tags  = local.dynamic_groups_defined_tags
      freeform_tags = merge(local.dynamic_groups_freeform_tags,{"roles":"dyn-security-functions"})
    } 
  } : {}

  #--------------------------------------------------------------------
  #-- AppDev functions Dynamic Group
  #--------------------------------------------------------------------
  appdev_functions_dynamic_group_key = "${var.service_label}-appdev-fun-dynamic-group"
  default_appdev_functions_dynamic_group_name = "appdev-fun-dynamic-group"
  provided_appdev_functions_dynamic_group_name  = local.custom_appdev_fun_dyn_group_name != null ? local.custom_appdev_fun_dyn_group_name : "${var.service_label}-${local.default_appdev_functions_dynamic_group_name}" #data.oci_identity_dynamic_groups.existing_appdev_fun_dyn_group.dynamic_groups[0].name
  
  appdev_functions_dynamic_group = length(trimspace(var.existing_appdev_fun_dyn_group_name)) == 0 ? {
    (local.appdev_functions_dynamic_group_key) = {
      name          = local.provided_appdev_functions_dynamic_group_name   
      description   = "CIS Landing Zone dynamic group for application functions execution."
      matching_rule = "ALL {resource.type = 'fnfunc',resource.compartment.id = '${local.appdev_compartment_id}'}"
      defined_tags  = local.dynamic_groups_defined_tags
      freeform_tags = merge(local.dynamic_groups_freeform_tags,{"roles":"dyn-application-functions"})
    }
  } : {}

  #--------------------------------------------------------------------
  #-- AppDev compute agent Dynamic Group
  #--------------------------------------------------------------------
  appdev_computeagent_dynamic_group_key = "${var.service_label}-appdev-computeagent-dynamic-group"
  default_appdev_computeagent_dynamic_group_name = "appdev-computeagent-dynamic-group"
  provided_appdev_computeagent_dynamic_group_name  = local.custom_appdev_computeagent_dyn_group_name != null ? local.custom_appdev_computeagent_dyn_group_name : "${var.service_label}-${local.default_appdev_computeagent_dynamic_group_name}" #data.oci_identity_dynamic_groups.existing_compute_agent_dyn_group.dynamic_groups[0].name

  appdev_computeagent_dynamic_group = length(trimspace(var.existing_compute_agent_dyn_group_name)) == 0 ? {
    (local.appdev_computeagent_dynamic_group_key) = {
      name          = local.provided_appdev_computeagent_dynamic_group_name  
      description   = "CIS Landing Zone dynamic group for Compute Agent plugin execution."
      matching_rule = "ALL {resource.type = 'managementagent',resource.compartment.id = '${local.appdev_compartment_id}'}"
      defined_tags  = local.dynamic_groups_defined_tags
      freeform_tags = merge(local.dynamic_groups_freeform_tags,{"roles":"dyn-compute-agent"})
    }  
  } : {}

  #--------------------------------------------------------------------
  #-- Database KMS Dynamic Group
  #--------------------------------------------------------------------
  database_kms_dynamic_group_key = "${var.service_label}-database-kms-dynamic-group"
  default_database_kms_dynamic_group_name = "database-kms-dynamic-group"
  provided_database_kms_dynamic_group_name  = local.custom_database_kms_dyn_group_name != null ? local.custom_database_kms_dyn_group_name : "${var.service_label}-${local.default_database_kms_dynamic_group_name}" #data.oci_identity_dynamic_groups.existing_database_kms_dyn_group.dynamic_groups[0].name

  database_kms_dynamic_group = length(trimspace(var.existing_database_kms_dyn_group_name)) == 0 ? {
    (local.database_kms_dynamic_group_key) = {
      name          = local.provided_database_kms_dynamic_group_name  
      description   = "CIS Landing Zone dynamic group for databases accessing Key Management service (aka Vault service)."
      matching_rule = "ALL {resource.compartment.id = '${local.database_compartment_id}'}"
      defined_tags  = local.dynamic_groups_defined_tags
      freeform_tags = merge(local.dynamic_groups_freeform_tags,{"roles":"dyn-database-kms"})
    }  
  } : {}

  #------------------------------------------------------------------------
  #----- Dynamic groups configuration definition. Input to module.
  #------------------------------------------------------------------------
  dynamic_groups_configuration = {
    dynamic_groups : merge(local.security_functions_dynamic_group, local.appdev_functions_dynamic_group,
                           local.appdev_computeagent_dynamic_group, local.database_kms_dynamic_group)
  }

  empty_dynamic_groups_configuration = {
    dynamic_groups : {}
  }

  #----------------------------------------------------------------------------------
  #----- Variables with dynamic group names per dynamic groups module output
  #----------------------------------------------------------------------------------
  security_functions_dynamic_group_name  = length(trimspace(var.existing_security_fun_dyn_group_name)) == 0  ? module.lz_dynamic_groups.dynamic_groups[local.security_functions_dynamic_group_key].name : var.existing_security_fun_dyn_group_name
  appdev_functions_dynamic_group_name    = length(trimspace(var.existing_appdev_fun_dyn_group_name)) == 0    ? module.lz_dynamic_groups.dynamic_groups[local.appdev_functions_dynamic_group_key].name : var.existing_appdev_fun_dyn_group_name
  appdev_computeagent_dynamic_group_name = length(trimspace(var.existing_compute_agent_dyn_group_name)) == 0 ? module.lz_dynamic_groups.dynamic_groups[local.appdev_computeagent_dynamic_group_key].name : var.existing_compute_agent_dyn_group_name
  database_kms_dynamic_group_name        = length(trimspace(var.existing_database_kms_dyn_group_name)) == 0  ? module.lz_dynamic_groups.dynamic_groups[local.database_kms_dynamic_group_key].name : var.existing_database_kms_dyn_group_name
}

