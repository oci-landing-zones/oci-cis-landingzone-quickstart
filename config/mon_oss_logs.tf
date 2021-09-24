# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
    oss_bucket_logs = {for bkt in module.lz_buckets.oci_objectstorage_buckets : bkt.name => {
            log_display_name              = "${bkt.name}-object-storage-log",
            log_type                      = "SERVICE",
            log_config_source_resource    = bkt.name,
            log_config_source_category    = "write",
            log_config_source_service     = "objectstorage",
            log_config_source_source_type = "OCISERVICE",
            log_config_compartment        = module.lz_compartments.compartments[local.security_compartment.key].id,
            log_is_enabled                = true,
            log_retention_duration        = 30,
            defined_tags                  = null,
            freeform_tags                 = null
        }
    }
}

module "lz_oss_logs" {
  depends_on             = [ module.lz_buckets ]
  source                 = "../modules/monitoring/logs"
  compartment_id         = module.lz_compartments.compartments[local.security_compartment.key].id
  log_group_display_name = "${var.service_label}-object-storage-log-group"
  log_group_description  = "Landing Zone ${var.service_label} Object Storage log group."
  target_resources       = local.oss_bucket_logs 
}