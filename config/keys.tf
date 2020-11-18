# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### Creates a vault and multiple keys in the vault.
module "cis_vault" {
    source            = "../modules/vault"
    tenancy_ocid      = var.tenancy_ocid
    compartment_id    = module.compartments.compartments[local.security_compartment_name].id
    compartment_name  = local.security_compartment_name
    vault_name        = local.vault_name
    vault_type        = local.vault_type
    region            = var.region
    keys              = {
        "${var.service_label}-oss-key" = {
            key_shape_algorithm = "AES"
            key_shape_length    = 32
        }
    }
}