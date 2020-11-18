# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### Creates a vault and multiple keys in the vault.
module "cis_keys" {
    source            = "../modules/vault/keys"
    tenancy_ocid      = var.tenancy_ocid
    compartment_id    = module.cis_compartments.compartments[local.security_compartment_name].id
    compartment_name  = local.security_compartment_name
    vault_name        = local.vault_name
    vault_type        = local.vault_type
    region            = var.region
    keys              = {
        (local.oss_key_name) = {
            key_shape_algorithm = "AES"
            key_shape_length    = 32
        }
    }
}

### Creates policies for the keys
module "cis_keys_policies" {
    source   = "../modules/vault/policies"
    policies = {
        "${local.oss_key_name}-Policy" = {
            compartment_id = var.tenancy_ocid
            description = "Policy allowing OCI services to access ${module.cis_keys.keys[local.oss_key_name].display_name} in the Vault service."
            statements = [
                "Allow service blockstorage, objectstorage-${var.region}, FssOc1Prod, oke, streaming to use keys in compartment ${local.security_compartment_name} where target.key.id = ${module.cis_keys.keys[local.oss_key_name].id}",
                "Allow group ${local.database_admin_group_name} to use key-delegate in compartment ${local.security_compartment_name} where target.key.id = ${module.cis_keys.keys[local.oss_key_name].id}"
            ]
        }
    } 
}