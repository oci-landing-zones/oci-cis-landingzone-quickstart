# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  all_oss_defined_tags = {}
  all_oss_freeform_tags = {}
    
  oss_bucket_logs = length(module.lz_buckets) > 0 && var.cis_level == "2" ? {for bkt in module.lz_buckets[0].buckets : bkt.name => {
    log_display_name              = "${bkt.name}-object-storage-log",
    log_type                      = "SERVICE",
    log_config_source_resource    = bkt.name,
    log_config_source_category    = "write",
    log_config_source_service     = "objectstorage",
    log_config_source_source_type = "OCISERVICE",
    log_config_compartment        = local.security_compartment_id,
    log_is_enabled                = true,
    log_retention_duration        = 30,
    defined_tags                  = local.oss_defined_tags,
    freeform_tags                 = local.oss_freeform_tags
  }} : {}

  ### DON'T TOUCH THESE ###
  default_oss_defined_tags = null
  default_oss_freeform_tags = local.landing_zone_tags

  oss_defined_tags = length(local.all_oss_defined_tags) > 0 ? local.all_oss_defined_tags : local.default_oss_defined_tags
  oss_freeform_tags = length(local.all_oss_freeform_tags) > 0 ? merge(local.all_oss_freeform_tags, local.default_oss_freeform_tags) : local.default_oss_freeform_tags
}

module "lz_oss_logs" {
  source                 = "../modules/monitoring/logs"
  depends_on             = [ module.lz_buckets ]
  compartment_id         = local.security_compartment_id
  log_group_display_name = "${var.service_label}-object-storage-log-group"
  log_group_description  = "Landing Zone ${var.service_label} Object Storage log group."
  target_resources       = local.oss_bucket_logs 
}
