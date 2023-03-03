# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
#--------------------------------------------------------------------------
#-- Any of these custom variables can be overriden in a _override.tf file.
#--------------------------------------------------------------------------  
  custom_service_policy_defined_tags = null
  custom_service_policy_freeform_tags = null
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