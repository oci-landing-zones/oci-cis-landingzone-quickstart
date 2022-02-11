# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  vault_name   = "${var.service_label}-vault"
  vault_type   = "DEFAULT"

  oss_key_name = "${var.service_label}-oss-key"
  oss_key_policy_name = "${local.oss_key_name}-${local.region_key}-policy"

  all_keys_defined_tags = {}
  all_keys_freeform_tags = {}
  all_vault_defined_tags = {}
  all_vault_freeform_tags = {}

  ### DON'T TOUCH THESE ###

  default_keys_defined_tags = null
  default_keys_freeform_tags = local.landing_zone_tags
  default_vault_defined_tags = null
  default_vault_freeform_tags = local.landing_zone_tags

  keys_defined_tags = length(local.all_keys_defined_tags) > 0 ? local.all_keys_defined_tags : local.default_keys_defined_tags
  keys_freeform_tags = length(local.all_keys_freeform_tags) > 0 ? local.all_keys_freeform_tags : local.default_keys_freeform_tags

  vault_defined_tags = length(local.all_vault_defined_tags) > 0 ? local.all_vault_defined_tags : local.default_vault_defined_tags
  vault_freeform_tags = length(local.all_vault_freeform_tags) > 0 ? local.all_vault_freeform_tags : local.default_vault_freeform_tags
}

### Creates a vault.
module "lz_vault" {
    source            = "../modules/security/vaults"
    compartment_id    = local.security_compartment_id #module.lz_compartments.compartments[local.security_compartment.key].id
    vault_name        = local.vault_name
    vault_type        = local.vault_type
    defined_tags      = local.vault_defined_tags
    freeform_tags     = local.vault_freeform_tags
}


### Creates the OSS key in the vault created in the above step.
module "lz_keys" {
    source                = "../modules/security/keys"
    compartment_id        = local.security_compartment_id #module.lz_compartments.compartments[local.security_compartment.key].id
    vault_mgmt_endPoint   = module.lz_vault.vault.management_endpoint
    keys              = {
        (local.oss_key_name) = {
            defined_tags        = local.keys_defined_tags
            freeform_tags       = local.keys_freeform_tags
            key_shape_algorithm = "AES"
            key_shape_length    = 32
        }
    }
}


### Creates policies for the keys
module "lz_keys_policies" {
    source    = "../modules/iam/iam-policy"
    providers = { oci = oci.home }
    # Vault is a regional service. As such, we must not skip provisioning when extending Landing Zone to a new region.
    policies  = {
        "${local.oss_key_policy_name}" = {
            compartment_id = local.enclosing_compartment_id
            description = "Landing Zone policy allowing access to ${module.lz_keys.keys[local.oss_key_name].display_name} in the Vault service."
            defined_tags = local.keys_defined_tags
            freeform_tags = local.keys_freeform_tags
            statements = [
                "Allow service objectstorage-${var.region} to use keys in compartment ${local.security_compartment.name} where target.key.id = '${module.lz_keys.keys[local.oss_key_name].id}'",
                "Allow group ${local.database_admin_group_name} to use key-delegate in compartment ${local.security_compartment.name} where target.key.id = '${module.lz_keys.keys[local.oss_key_name].id}'",
                "Allow group ${local.appdev_admin_group_name} to use key-delegate in compartment ${local.security_compartment.name} where target.key.id = '${module.lz_keys.keys[local.oss_key_name].id}'"
            ]
        }
    }
}