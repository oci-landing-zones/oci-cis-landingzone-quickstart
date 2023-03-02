# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  all_services_policy_statements = []

  # Names
  services_policy_name = "${local.unique_prefix}-services-policy"

  cloud_guard_statements = [
    "Allow service cloudguard to read all-resources in tenancy",
    "Allow service cloudguard to use network-security-groups in tenancy"]

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

  all_services_policy_defined_tags = {}
  all_services_policy_freeform_tags = {}

  default_services_policy_defined_tags = null
  default_services_policy_freeform_tags = local.landing_zone_tags

  services_policy_defined_tags = length(local.all_services_policy_defined_tags) > 0 ? local.all_services_policy_defined_tags : local.default_services_policy_defined_tags
  services_policy_freeform_tags  = length(local.all_services_policy_freeform_tags) > 0 ? merge(local.all_services_policy_freeform_tags, local.default_services_policy_freeform_tags) : local.default_services_policy_freeform_tags
  default_services_policy_statements = concat(local.cloud_guard_statements, local.vss_statements, local.os_mgmt_statements)
}

module "lz_services_policy" {
  source              = "../modules/iam/iam-services-policy"
  tenancy_id          = var.tenancy_ocid
  service_label       = var.unique_prefix
  tenancy_policy_name = "${var.unique_prefix}-services-policy"
  defined_tags        = local.service_policy_defined_tags
  freeform_tags       = local.service_policy_freeform_tags
}

locals {
#--------------------------------------------------------------------------
#-- These variables are NOT meant to be overriden.
#--------------------------------------------------------------------------  
  default_service_policy_defined_tags = null
  default_service_policy_freeform_tags = local.landing_zone_tags

  service_policy_defined_tags = local.custom_service_policy_defined_tags != null ? merge(local.custom_service_policy_defined_tags, local.default_service_policy_defined_tags) : local.default_service_policy_defined_tags
  service_policy_freeform_tags = local.custom_service_policy_freeform_tags != null ? merge(local.custom_service_policy_freeform_tags, local.default_service_policy_freeform_tags) : local.default_service_policy_freeform_tags
}