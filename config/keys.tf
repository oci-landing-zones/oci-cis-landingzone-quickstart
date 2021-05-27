# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### Creates a vault.
module "cis_vault" {
    source            = "../modules/security/vaults"
    compartment_id    = module.cis_compartments.compartments[local.security_compartment_name].id
    vault_name        = local.vault_name
    vault_type        = local.vault_type
}


### Creates the OSS key in the vault created in the above step.
module "cis_keys" {
    source                = "../modules/security/keys"
    compartment_id        = module.cis_compartments.compartments[local.security_compartment_name].id
    vault_mgmt_endPoint   = module.cis_vault.vault.management_endpoint
    keys              = {
        (local.oss_key_name) = {
            key_shape_algorithm = "AES"
            key_shape_length    = 32
        }
    }
}


### Creates policies for the keys
module "cis_keys_policies" {
    #source    = "../modules/vault/policies"
    source    = "../modules/iam/iam-policy"
    providers = { oci = oci.home }
    policies  = {
        "${local.oss_key_name}-Policy" = {
            compartment_id = var.tenancy_ocid
            description = "Policy allowing OCI services to access ${module.cis_keys.keys[local.oss_key_name].display_name} in the Vault service."
            statements = [
                "Allow service objectstorage-${var.region} to use keys in compartment ${local.security_compartment_name} where target.key.id = '${module.cis_keys.keys[local.oss_key_name].id}'",
                "Allow group ${local.database_admin_group_name} to use key-delegate in compartment ${local.security_compartment_name} where target.key.id = '${module.cis_keys.keys[local.oss_key_name].id}'",
                "Allow group ${local.appdev_admin_group_name} to use key-delegate in compartment ${local.security_compartment_name} where target.key.id = '${module.cis_keys.keys[local.oss_key_name].id}'"
            ]
        }
    } 
}