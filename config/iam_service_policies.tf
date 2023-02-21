# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  all_service_policy_statements = []

  all_service_policy_defined_tags = {}
  all_service_policy_freeform_tags = {}

  # Names
  services_policy_name   = "${var.service_label}-services-policy"
  vault_policy_name   = "${var.service_label}-vault-policy"
  vault_regional_policy_name   = "${var.service_label}-vault-${var.region}-policy"


  cloud_guard_statements = [
    "Allow service cloudguard to read all-resources in tenancy",
    "Allow service cloudguard to use network-security-groups in tenancy"
  ]

  os_mgmt_statements = [
    "Allow service osms to read instances in tenancy"
  ]

  adb_vault_statements = [
    "Allow dynamic-group ${local.database_kms_dynamic_group_name} to use vaults in compartment ${local.security_compartment.name}",
    "Allow dynamic-group ${local.database_kms_dynamic_group_name} to use keys in compartment ${local.security_compartment.name}",
    "Allow dynamic-group ${local.database_kms_dynamic_group_name} to use secret-family in compartment ${local.security_compartment.name}"
  ]

  vault_service_policies = [
    "Allow service blockstorage, oke, streaming, Fss${local.realm}Prod to use keys in compartment ${local.security_compartment.name}"
  ]
  
  vault_regional_service_policies = [
    "Allow service objectstorage-${var.region} to use keys in compartment ${local.security_compartment.name}"
  ]


  default_service_policy_defined_tags = null
  default_service_policy_freeform_tags = local.landing_zone_tags

  service_policy_defined_tags = length(local.all_service_policy_defined_tags) > 0 ? local.all_service_policy_defined_tags : local.default_service_policy_defined_tags
  service_policy_freeform_tags = length(local.all_service_policy_freeform_tags) > 0 ? merge(local.all_service_policy_freeform_tags, local.default_service_policy_freeform_tags) : local.default_service_policy_freeform_tags

  default_service_policy_statements = concat(local.cloud_guard_statements, local.os_mgmt_statements)

  service_global_policies = {
    (local.services_policy_name) = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone policy for OCI services: Cloud Guard, Vulnerability Scanning and OS Management."
      statements     = length(local.all_service_policy_statements) > 0 ? local.all_service_policy_statements : local.default_service_policy_statements
      defined_tags = local.service_policy_defined_tags
      freeform_tags = local.service_policy_freeform_tags
    },
    (local.vault_policy_name) = {
      compartment_id = local.enclosing_compartment_id
      description    = "Landing Zone policy for OCI services: Blockstorage, OKE and streams to use keys in the ${local.security_compartment.name} compartment."
      statements     = local.vault_service_policies
      defined_tags = local.service_policy_defined_tags
      freeform_tags = local.service_policy_freeform_tags
    } 
  }
  service_regional_policies = {
    (local.vault_regional_policy_name) = {
      compartment_id = local.enclosing_compartment_id
      description    = "Landing Zone policy for OCI services: Object Storage in ${var.region} to use keys in the ${local.security_compartment.name} compartment."
      statements     = local.vault_regional_service_policies
      defined_tags = local.service_policy_defined_tags
      freeform_tags = local.service_policy_freeform_tags
    }
    
  }

}

module "lz_services_policy" {
  depends_on = [module.lz_dynamic_groups]
  source = "../modules/iam/iam-policy"
  providers = { oci = oci.home }
  policies   = var.extend_landing_zone_to_new_region == false ? (local.use_existing_root_cmp_grants == true ? {} : merge(local.service_global_policies, local.service_regional_policies) ) : local.service_regional_policies
}