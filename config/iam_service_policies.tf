# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  all_service_policy_statements = []

  # Names
  services_policy_name   = "${var.service_label}-services-policy"

  cloud_guard_statements = [
    "Allow service cloudguard to read keys in tenancy",
    "Allow service cloudguard to read compartments in tenancy",
    "Allow service cloudguard to read tenancies in tenancy",
    "Allow service cloudguard to read audit-events in tenancy",
    "Allow service cloudguard to read compute-management-family in tenancy",
    "Allow service cloudguard to read instance-family in tenancy",
    "Allow service cloudguard to read virtual-network-family in tenancy",
    "Allow service cloudguard to read volume-family in tenancy",
    "Allow service cloudguard to read database-family in tenancy",
    "Allow service cloudguard to read object-family in tenancy",
    "Allow service cloudguard to read load-balancers in tenancy",
    "Allow service cloudguard to read users in tenancy",
    "Allow service cloudguard to read groups in tenancy",
    "Allow service cloudguard to read policies in tenancy",
    "Allow service cloudguard to read dynamic-groups in tenancy",
    "Allow service cloudguard to read authentication-policies in tenancy",
    "Allow service cloudguard to use network-security-groups in tenancy"
  ]

  vss_statements = [
    "Allow service vulnerability-scanning-service to manage instances in tenancy",
    "Allow service vulnerability-scanning-service to read compartments in tenancy",
    "Allow service vulnerability-scanning-service to read vnics in tenancy",
    "Allow service vulnerability-scanning-service to read vnic-attachments in tenancy"
  ]

  os_mgmt_statements = [
    "Allow service osms to read instances in tenancy"
  ]

  default_service_policy_statements = concat(local.cloud_guard_statements, local.vss_statements, local.os_mgmt_statements)

  service_policies = {
    (local.services_policy_name) = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone policy for OCI services: Cloud Guard, Vulnerability Scanning and OS Management."
      statements     = length(local.all_service_policy_statements) > 0 ? local.all_service_policy_statements : local.default_service_policy_statements
    }
  }
}

module "lz_services_policy" {
  depends_on = [module.lz_dynamic_groups]
  source = "../modules/iam/iam-policy"
  providers = { oci = oci.home }
  policies   = var.extend_landing_zone_to_new_region == false ? (local.use_existing_root_cmp_grants == true ? {} : local.service_policies) : {}
}