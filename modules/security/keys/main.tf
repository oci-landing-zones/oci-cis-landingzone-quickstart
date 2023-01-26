/**
 * ## CIS OCI Landing Zone KMS Keys Module.
 *
 * This module manages OCI KMS keys resources and IAM policies resources determining the grants over these keys. 
 * It manages multiple keys given in var.managed_keys. Keys are expected to specify the grantees (service_grantees and group_grantees) allowed to use them.
 * The module can also take a map of existing keys in var.existing_keys to manage their IAM policies. For existing keys, the module manages one policy to each
 * key, as these keys can exist in different compartments.
 */

# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.80.0"
      configuration_aliases = [ oci, oci.home ] 
    }
  }
}

data "oci_identity_compartment" "this" {
  provider = oci.home
  id = var.compartment_id
}

data "oci_kms_vault" "these" {
  provider = oci
  for_each = var.managed_keys
    vault_id = each.value.vault_id
}

locals {
  managed_keys_statements = flatten([
    for k,v in var.managed_keys : concat(
      [for sg in v.service_grantees : "Allow service ${sg} to use keys in compartment ${data.oci_identity_compartment.this.name} where target.key.id = '${oci_kms_key.these[k].id}'"],
      [for gg in v.group_grantees   : "Allow group ${gg} to use key-delegate in compartment ${data.oci_identity_compartment.this.name} where target.key.id = '${oci_kms_key.these[k].id}'"]
    )
  ])
}

#------------------------------------------------------------------
#-- Default managed keys.
#------------------------------------------------------------------
resource "oci_kms_key" "these" {
  provider = oci
  #-- create_before_destroy makes Terraform to first update any resources that depend on these keys before destroying the keys.
  #-- This helps with Object Storage encrypted buckets, when updated with a new encryption key.
  lifecycle {
    create_before_destroy = true
  }
  for_each = var.managed_keys
    compartment_id       = var.compartment_id
    display_name         = each.value.key_name
    management_endpoint  = data.oci_kms_vault.these[each.key].management_endpoint
    defined_tags         = var.defined_tags
    freeform_tags        = var.freeform_tags
    key_shape {
      algorithm = each.value.key_shape_algorithm
      length    = each.value.key_shape_length
    }
}

#------------------------------------------------------------------
#-- Single policy for default managed keys.
#------------------------------------------------------------------
resource "oci_identity_policy" "managed_keys" {
  provider = oci.home
  lifecycle {
    create_before_destroy = true
  }
  count = length(var.managed_keys) > 0 ? 1 : 0
    name           = var.policy_name
    description    = "CIS Landing Zone policy allowing access to keys in the Vault service."
    compartment_id = var.policy_compartment_id
    statements     = local.managed_keys_statements
    defined_tags   = var.defined_tags
    freeform_tags  = var.freeform_tags
}

#------------------------------------------------------------------
#-- Multiple policies for existing keys.
#-- Keys can live in different compartments.
#------------------------------------------------------------------
resource "oci_identity_policy" "existing_keys" {
  provider = oci.home
  for_each = var.existing_keys
    name           = "${each.key}-policy"
    description    = "CIS Landing Zone policy allowing access to keys in the Vault service."
    compartment_id = each.value.compartment_id
    statements     = concat(
        [for sg in each.value.service_grantees : "Allow service ${sg} to use keys in compartment id ${each.value.compartment_id} where target.key.id = '${each.value.key_id}'"],
        [for gg in each.value.group_grantees   : "Allow group ${gg} to use key-delegate in compartment id ${each.value.compartment_id} where target.key.id = '${each.value.key_id}'"])
    defined_tags   = var.defined_tags
    freeform_tags  = var.freeform_tags
}
