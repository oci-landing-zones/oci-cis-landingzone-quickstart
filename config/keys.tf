# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
#------------------------------------------------------------------------------------------------------
#-- Any of these local vars before ### DON'T TOUCH THESE ### can be overriden in a _override.tf file
#------------------------------------------------------------------------------------------------------
  custom_vault_name = null
  custom_vault_type = null   
  all_vault_defined_tags   = null
  all_vault_freeform_tags  = null

  ### DON'T TOUCH THESE ###
  default_vault_name = "${var.service_label}-vault"
  default_vault_type = "DEFAULT"
  default_vault_defined_tags  = null
  default_vault_freeform_tags = local.landing_zone_tags

  vault_name = local.custom_vault_name != null ? local.custom_vault_name : local.default_vault_name
  vault_type = local.custom_vault_type != null ? local.custom_vault_type : local.default_vault_type
  vault_defined_tags = local.all_vault_defined_tags != null ? local.all_vault_defined_tags : local.default_vault_defined_tags
  vault_freeform_tags = local.all_vault_freeform_tags != null ? merge(local.all_vault_freeform_tags, local.default_vault_freeform_tags) : local.default_vault_freeform_tags
  ###

  enable_vault = (var.enable_oss_bucket && var.existing_bucket_vault_id == null && var.cis_level == "2") || (
                  var.enable_service_connector && var.service_connector_target_kind == "objectstorage" && var.existing_service_connector_bucket_vault_id == null && var.cis_level == "2")
}

#---------------------------------------------------------------------------
#-- This module call manages a KMS Vault used throughout Landing Zone
#---------------------------------------------------------------------------
module "lz_vault" {
  source = "../modules/security/vaults"
  count  = local.enable_vault ? 1 : 0
  compartment_id = local.security_compartment_id
  name           = local.vault_name
  type           = local.vault_type
  defined_tags   = local.vault_defined_tags
  freeform_tags  = local.vault_freeform_tags
}

#------------------------------------------------------------------------------------------------------
#-- Any of these local vars before ### DON'T TOUCH THESE ### can be overriden in a _override.tf file
#------------------------------------------------------------------------------------------------------
locals {

  custom_appdev_bucket_key_name = null
  custom_sch_bucket_key_name = null
  all_keys_defined_tags = null
  all_keys_freeform_tags = null

  ### DON'T TOUCH THESE ###
  default_appdev_bucket_key_name = "${var.service_label}-oss-key"
  appdev_bucket_key_name = local.custom_appdev_bucket_key_name != null ? local.custom_appdev_bucket_key_name : local.default_appdev_bucket_key_name
  
  default_sch_bucket_key_name = "${var.service_label}-sch-bucket-key"
  sch_bucket_key_name = local.custom_sch_bucket_key_name != null ? local.custom_sch_bucket_key_name : local.default_sch_bucket_key_name
  
  default_keys_defined_tags  = null
  default_keys_freeform_tags = local.landing_zone_tags
  
  keys_defined_tags = local.all_keys_defined_tags != null ? local.all_keys_defined_tags : local.default_keys_defined_tags
  keys_freeform_tags = local.all_keys_freeform_tags != null ? merge(local.all_keys_freeform_tags, local.default_keys_freeform_tags) : local.default_keys_freeform_tags
  ###
  
  appdev_key_mapkey = "${var.service_label}-oss-key"
  sch_key_mapkey    = "${var.service_label}-sch-bucket-key" 

  managed_appdev_bucket_key = var.existing_bucket_key_id == null ? {
    (local.appdev_key_mapkey) = {
      vault_id            = var.existing_bucket_vault_id != null ? var.existing_bucket_vault_id : (length(module.lz_vault) > 0 ? module.lz_vault[0].vault.id : null)
      key_name            = local.appdev_bucket_key_name 
      key_shape_algorithm = "AES"
      key_shape_length    = 32
      service_grantees    = ["objectstorage-${var.region}"]
      group_grantees      = [local.database_admin_group_name,local.appdev_admin_group_name]
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
      group_grantees    = [local.database_admin_group_name,local.appdev_admin_group_name]
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

#----------------------------------------------------------------------------
#-- This module call manages KMS Keys used by AppDev bucket
#----------------------------------------------------------------------------
module "lz_keys" {
  source = "../modules/security/keys"
  count  = (var.enable_oss_bucket && var.cis_level == "2") ? 1 : 0
  depends_on            = [null_resource.wait_on_compartments]
  compartment_id        = local.security_compartment_id
  managed_keys          = local.managed_appdev_bucket_key
  policy_compartment_id = local.enclosing_compartment_id
  policy_name           = "${var.service_label}-oss-key-${local.region_key}-policy"
  existing_keys         = local.existing_appdev_bucket_key
  defined_tags          = local.keys_defined_tags
  freeform_tags         = local.keys_freeform_tags
}

#----------------------------------------------------------------------------
#-- This module call manages KMS Keys used by Service Connector bucket
#----------------------------------------------------------------------------
module "lz_service_connector_keys" {
  source = "../modules/security/keys"
  count = (var.enable_service_connector && var.service_connector_target_kind == "objectstorage" && var.cis_level == "2") ? 1 : 0
  depends_on            = [null_resource.wait_on_compartments]
  compartment_id        = local.security_compartment_id
  managed_keys          = local.managed_sch_bucket_key
  policy_compartment_id = local.enclosing_compartment_id
  policy_name           = "${var.service_label}-service-connector-key-${local.region_key}-policy"
  existing_keys         = local.existing_sch_bucket_key
  defined_tags          = local.keys_defined_tags
  freeform_tags         = local.keys_freeform_tags
}
