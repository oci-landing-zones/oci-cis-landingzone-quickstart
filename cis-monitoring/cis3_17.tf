locals {
    oss_bucket_logs = {"cis-bucket" = {
            log_display_name              = "${data.terraform_remote_state.object_storage.outputs.object_storage_bucket.name}-ObjectStorageLog",
            log_type                      = "SERVICE",
            log_config_source_resource    = data.terraform_remote_state.object_storage.outputs.object_storage_bucket.name,
            log_config_source_category    = "write",
            log_config_source_service     = "objectstorage",
            log_config_source_source_type = "OCISERVICE",
            log_config_compartment        = data.terraform_remote_state.iam.outputs.security_compartment_id,
            log_is_enabled                = true,
            log_retention_duration        = 30,
            defined_tags                  = null,
            freeform_tags                 = null
        }
    }
}

module "cis_oss_logs" {
  source                 = "../modules/monitoring/logs"
  compartment_id         = data.terraform_remote_state.iam.outputs.security_compartment_id
  log_group_display_name = "${var.service_label}-ObjectStorageLogGroup"
  log_group_description  = "${var.service_label} Object Storage log group."
  target_resources       = local.oss_bucket_logs 
}