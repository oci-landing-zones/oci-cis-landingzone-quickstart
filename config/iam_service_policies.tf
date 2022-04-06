# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  all_service_policy_statements = []

  all_service_policy_defined_tags = {}
  all_service_policy_freeform_tags = {}

  # Names
  services_policy_name   = "${var.service_label}-services-policy"

  cloud_guard_statements = [
    "Allow service cloudguard to read all-resources in tenancy",
    "Allow service cloudguard to use network-security-groups in tenancy"
  ]

  vss_statements = [
    "Allow service vulnerability-scanning-service to manage instances in tenancy",
    "Allow service vulnerability-scanning-service to read compartments in tenancy",
    "Allow service vulnerability-scanning-service to read repos in tenancy",
    "Allow service vulnerability-scanning-service to read vnics in tenancy",
    "Allow service vulnerability-scanning-service to read vnic-attachments in tenancy"
  ]

  os_mgmt_statements = [
    "Allow service osms to read instances in tenancy"
  ]

  default_service_policy_defined_tags = null
  default_service_policy_freeform_tags = local.landing_zone_tags

  service_policy_defined_tags = length(local.all_service_policy_defined_tags) > 0 ? local.all_service_policy_defined_tags : local.default_service_policy_defined_tags
  service_policy_freeform_tags = length(local.all_service_policy_freeform_tags) > 0 ? merge(local.all_service_policy_freeform_tags, local.default_service_policy_freeform_tags) : local.default_service_policy_freeform_tags

  default_service_policy_statements = concat(local.cloud_guard_statements, local.vss_statements, local.os_mgmt_statements)

  service_policies = {
    (local.services_policy_name) = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone policy for OCI services: Cloud Guard, Vulnerability Scanning and OS Management."
      statements     = length(local.all_service_policy_statements) > 0 ? local.all_service_policy_statements : local.default_service_policy_statements
      defined_tags = local.service_policy_defined_tags
      freeform_tags = local.service_policy_freeform_tags
    }
  }
}

module "lz_services_policy" {
  depends_on = [module.lz_dynamic_groups]
  source = "../modules/iam/iam-policy"
  providers = { oci = oci.home }
  policies   = var.extend_landing_zone_to_new_region == false ? (local.use_existing_root_cmp_grants == true ? {} : local.service_policies) : {}
}