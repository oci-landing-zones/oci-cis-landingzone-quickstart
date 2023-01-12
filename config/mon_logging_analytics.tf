# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
#------------------------------------------------------------------------------------------------------
#-- Any of these local vars can be overriden in a _override.tf file
#------------------------------------------------------------------------------------------------------
  custom_logging_analytics_log_group_name = null
  custom_logging_analytics_defined_tags = null
  custom_logging_analytics_freeform_tags = null
}

module "lz_logging_analytics" {
  source                   = "../modules/monitoring/logging-analytics"
  count                    = var.enable_service_connector ? (var.service_connector_target_kind == "logginganalytics" ? 1 : 0) : 0
  tenancy_id               = var.tenancy_ocid
  log_group_compartment_id = local.security_compartment_id
  log_group_name           = local.logging_analytics_log_group_name
  defined_tags             = local.logging_analytics_defined_tags
  freeform_tags            = local.logging_analytics_freeform_tags
}

locals {
#------------------------------------------------------------------------------------------------------
#-- These variables are NOT meant to be overriden
#------------------------------------------------------------------------------------------------------
#-- Logging Analytics tags 
  default_logging_analytics_defined_tags = null
  default_logging_analytics_freeform_tags = local.landing_zone_tags
  logging_analytics_defined_tags = local.custom_logging_analytics_defined_tags != null ? merge(local.custom_logging_analytics_defined_tags, local.default_logging_analytics_defined_tags) : local.default_logging_analytics_defined_tags
  logging_analytics_freeform_tags = local.custom_logging_analytics_freeform_tags != null ? merge(local.custom_logging_analytics_freeform_tags, local.default_logging_analytics_freeform_tags) : local.default_logging_analytics_freeform_tags

#-- Logging Analytics resources naming 
  default_logging_analytics_log_group_name = "${var.service_label}-logging-analytics-log-group"
  logging_analytics_log_group_name = local.custom_logging_analytics_log_group_name != null ? local.custom_logging_analytics_log_group_name : local.default_logging_analytics_log_group_name
}