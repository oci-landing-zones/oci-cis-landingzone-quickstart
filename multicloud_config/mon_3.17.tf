# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  oss_bucket_logs = { for bkt in module.cis_buckets.oci_objectstorage_buckets : bkt.name => {
    log_display_name              = "${bkt.name}-ObjectStorageLog",
    log_type                      = "SERVICE",
    log_config_source_resource    = bkt.name,
    log_config_source_category    = "write",
    log_config_source_service     = "objectstorage",
    log_config_source_source_type = "OCISERVICE",
    log_config_compartment        = module.cis_compartments.compartments[local.security_compartment_name].id,
    log_is_enabled                = true,
    log_retention_duration        = 30,
    defined_tags                  = null,
    freeform_tags                 = null
    }
  }
}

module "cis_oss_logs" {
  source                 = "../modules/monitoring/logs"
  compartment_id         = module.cis_compartments.compartments[local.security_compartment_name].id
  log_group_display_name = "${var.service_label}-ObjectStorageLogGroup"
  log_group_description  = "${var.service_label} Object Storage log group."
  target_resources       = local.oss_bucket_logs
}