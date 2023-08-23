# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
#------------------------------------------------------------------------------------------------------
#-- Any of these local vars can be overriden in a _override.tf file
#------------------------------------------------------------------------------------------------------
  #-- Vault
  custom_vault_name = null
  custom_vault_type = null   
  custom_vault_defined_tags   = null
  custom_vault_freeform_tags  = null

  #-- Keys
  custom_appdev_bucket_key_name = null
  custom_appdev_bucket_key_policy_name = null
  custom_sch_bucket_key_name = null
  custom_sch_bucket_key_policy_name = null
  custom_keys_defined_tags = null
  custom_keys_freeform_tags = null
}

#---------------------------------------------------------------------------
#-- This module call manages a KMS Vault used throughout Landing Zone
#---------------------------------------------------------------------------
module "lz_vault" {
  source = "../modules/security/vaults"
  depends_on = [null_resource.wait_on_services_policy]
  count  = local.enable_vault ? 1 : 0
  compartment_id = local.security_compartment_id
  name           = local.vault_name
  type           = local.vault_type
  defined_tags   = local.vault_defined_tags
  freeform_tags  = local.vault_freeform_tags
}

#----------------------------------------------------------------------------
#-- This module call manages KMS Keys used by AppDev bucket
#----------------------------------------------------------------------------
module "lz_keys" {
  source = "../modules/security/keys"
  providers = {
    oci = oci
    oci.home = oci.home
  }
  depends_on = [null_resource.wait_on_compartments]
  count  = (var.enable_oss_bucket && var.cis_level == "2") ? 1 : 0
  compartment_id        = local.security_compartment_id
  managed_keys          = local.managed_appdev_bucket_key
  policy_compartment_id = local.enclosing_compartment_id
  policy_name           = local.appdev_bucket_key_policy_name
  existing_keys         = local.existing_appdev_bucket_key
  defined_tags          = local.keys_defined_tags
  freeform_tags         = local.keys_freeform_tags
}

#----------------------------------------------------------------------------
#-- This module call manages KMS Keys used by Service Connector bucket
#----------------------------------------------------------------------------
module "lz_service_connector_keys" {
  source = "../modules/security/keys"
  providers = {
    oci = oci
    oci.home = oci.home
  }
  depends_on = [null_resource.wait_on_compartments]
  count = (var.enable_service_connector && var.service_connector_target_kind == "objectstorage" && var.cis_level == "2") ? 1 : 0
  compartment_id        = local.security_compartment_id
  managed_keys          = local.managed_sch_bucket_key
  policy_compartment_id = local.enclosing_compartment_id
  policy_name           = local.sch_bucket_key_policy_name
  existing_keys         = local.existing_sch_bucket_key
  defined_tags          = local.keys_defined_tags
  freeform_tags         = local.keys_freeform_tags
}

locals {
  ### DON'T TOUCH THESE ###
  #-- Vault
  default_vault_name = "${var.service_label}-vault"
  default_vault_type = "DEFAULT"
  default_vault_defined_tags  = null
  default_vault_freeform_tags = local.landing_zone_tags

  vault_name = local.custom_vault_name != null ? local.custom_vault_name : local.default_vault_name
  vault_type = local.custom_vault_type != null ? local.custom_vault_type : local.default_vault_type
  vault_defined_tags = local.custom_vault_defined_tags != null ? local.custom_vault_defined_tags : local.default_vault_defined_tags
  vault_freeform_tags = local.custom_vault_freeform_tags != null ? merge(local.custom_vault_freeform_tags, local.default_vault_freeform_tags) : local.default_vault_freeform_tags
  
  enable_vault = var.cis_level == "2" ? true : false                

  #-- Keys
  default_appdev_bucket_key_name = "${var.service_label}-oss-key"
  appdev_bucket_key_name = local.custom_appdev_bucket_key_name != null ? local.custom_appdev_bucket_key_name : local.default_appdev_bucket_key_name

  default_appdev_bucket_key_policy_name = "${var.service_label}-oss-key-${local.region_key}-policy"
  appdev_bucket_key_policy_name = local.custom_appdev_bucket_key_policy_name != null ? local.custom_appdev_bucket_key_policy_name : local.default_appdev_bucket_key_policy_name
  
  default_sch_bucket_key_name = "${var.service_label}-sch-bucket-key"
  sch_bucket_key_name = local.custom_sch_bucket_key_name != null ? local.custom_sch_bucket_key_name : local.default_sch_bucket_key_name

  default_sch_bucket_key_policy_name = "${var.service_label}-service-connector-key-${local.region_key}-policy"
  sch_bucket_key_policy_name = local.custom_sch_bucket_key_policy_name != null ? local.custom_sch_bucket_key_policy_name : local.default_sch_bucket_key_policy_name
  
  default_keys_defined_tags  = null
  default_keys_freeform_tags = local.landing_zone_tags
  
  keys_defined_tags = local.custom_keys_defined_tags != null ? merge(local.custom_keys_defined_tags, local.default_keys_defined_tags) : local.default_keys_defined_tags
  keys_freeform_tags = local.custom_keys_freeform_tags != null ? merge(local.custom_keys_freeform_tags, local.default_keys_freeform_tags) : local.default_keys_freeform_tags
  
  appdev_key_mapkey = "${var.service_label}-oss-key"
  sch_key_mapkey    = "${var.service_label}-sch-bucket-key" 

  managed_appdev_bucket_key = var.existing_bucket_key_id == null ? {
    (local.appdev_key_mapkey) = {
      vault_id            = var.existing_bucket_vault_id != null ? var.existing_bucket_vault_id : (length(module.lz_vault) > 0 ? module.lz_vault[0].vault.id : null)
      key_name            = local.appdev_bucket_key_name 
      key_shape_algorithm = "AES"
      key_shape_length    = 32
      service_grantees    = ["objectstorage-${var.region}"]
      group_grantees      = concat(local.database_admin_group_name,local.appdev_admin_group_name)
    }
  } : {}

  managed_sch_bucket_key = var.existing_service_connector_bucket_key_id == null ? {
    (local.sch_key_mapkey) = {
      vault_id            = var.existing_service_connector_bucket_vault_id != null ? var.existing_service_connector_bucket_vault_id : (length(module.lz_vault) > 0 ? module.lz_vault[0].vault.id : null)
      key_name            = local.sch_bucket_key_name 
      key_shape_algorithm = "AES"
      key_shape_length    = 32
      service_grantees    = ["objectstorage-${var.region}"]
      group_grantees      = []
    }
  } : {}

  existing_appdev_bucket_key = var.existing_bucket_key_id != null ? {
    (local.appdev_key_mapkey) = {
      key_id            = var.existing_bucket_key_id 
      compartment_id    = var.existing_bucket_vault_compartment_id 
      service_grantees  = ["objectstorage-${var.region}"]
      group_grantees    = concat(local.database_admin_group_name,local.appdev_admin_group_name)
    }
  } : {}

  existing_sch_bucket_key = var.existing_service_connector_bucket_key_id != null ? {
    (local.sch_key_mapkey) = {
      key_id            = var.existing_service_connector_bucket_key_id 
      compartment_id    = var.existing_service_connector_bucket_vault_compartment_id 
      service_grantees  = ["objectstorage-${var.region}"]
      group_grantees    = []
    }
  } : {}
}