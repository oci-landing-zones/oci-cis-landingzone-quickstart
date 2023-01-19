# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
#------------------------------------------------------------------------------------------------------
#-- Any of these local vars can be overriden in a _override.tf file
#------------------------------------------------------------------------------------------------------
  custom_service_connector_name = null
  custom_service_connector_target_bucket_name = null
  custom_service_connector_target_object_name_prefix = null
  custom_service_connector_target_stream_name = null
  custom_service_connector_target_log_group_name = null
  custom_service_connector_target_policy_name = null

  custom_service_connector_defined_tags = null
  custom_service_connector_freeform_tags = null

  custom_target_defined_tags = null
  custom_target_freeform_tags = null

  custom_policy_defined_tags = null
  custom_policy_freeform_tags = null

  audit_logs_sources = !var.extend_landing_zone_to_new_region ? [for cmp in data.oci_identity_compartments.all.compartments : {
    compartment_id = cmp.id
    log_group_id = "_Audit"
    log_id = ""
  }] : []
  oss_logs_sources = [for k, v in module.lz_oss_logs.logs : {
    compartment_id = local.security_compartment_id
    log_group_id = module.lz_oss_logs.log_group.id
    log_id = v.id
  }]
  flow_logs_sources = [for k, v in module.lz_flow_logs.logs : {
    compartment_id = local.security_compartment_id
    log_group_id = module.lz_flow_logs.log_group.id
    log_id = v.id
  }] 
}  

module "lz_service_connector" {
  source         = "../modules/monitoring/service-connector-v2"
  providers      = {
    oci = oci
    oci.home = oci.home
  }
  depends_on     = [null_resource.wait_on_service_connector_keys_policy]
  count          = var.enable_service_connector ? 1 : 0
  tenancy_id     = var.tenancy_ocid
  display_name   = local.service_connector_name
  compartment_id = local.security_compartment_id
  activate       = var.activate_service_connector
  defined_tags   = local.service_connector_defined_tags
  freeform_tags  = local.service_connector_freeform_tags
  cis_level      = var.cis_level

  logs_sources = concat(local.audit_logs_sources, local.oss_logs_sources, local.flow_logs_sources)
    
  target_kind           = var.service_connector_target_kind
  target_compartment_id = local.security_compartment_id

  target_bucket_name        = local.service_connector_target_bucket_name
  target_bucket_namespace   = data.oci_objectstorage_namespace.this.namespace
  target_object_name_prefix = local.service_connector_target_object_name_prefix
  target_bucket_kms_key_id  = var.existing_service_connector_bucket_key_id != null ? var.existing_service_connector_bucket_key_id : (length(module.lz_service_connector_keys) > 0 ? module.lz_service_connector_keys[0].keys[local.sch_key_mapkey].id : null) 
    
  target_stream = var.existing_service_connector_target_stream_id != null ? var.existing_service_connector_target_stream_id : local.service_connector_target_stream_name

  target_function_id = var.existing_service_connector_target_function_id

  #target_log_group_name = local.service_connector_target_log_group_name
  target_log_group_id = length(module.lz_logging_analytics) > 0 ? module.lz_logging_analytics[0].log_group.id : null
  
  target_policy_name = local.service_connector_target_policy_name

  target_defined_tags  = local.target_defined_tags
  target_freeform_tags = local.target_freeform_tags

  policy_defined_tags  = local.policy_defined_tags
  policy_freeform_tags = local.policy_freeform_tags
}

resource "null_resource" "wait_on_service_connector_keys_policy" {
   depends_on = [ module.lz_service_connector_keys ]
   provisioner "local-exec" {
     interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
     command     = local.is_windows ? "Start-Sleep ${local.delay_in_secs * 2}" : "sleep ${local.delay_in_secs * 2}"
   }
}

locals {
#------------------------------------------------------------------------------------------------------
#-- These variables are not meant to be overriden
#------------------------------------------------------------------------------------------------------
#-- Service Connector tags 
  default_service_connector_defined_tags = null
  default_service_connector_freeform_tags = local.landing_zone_tags
  service_connector_defined_tags = local.custom_service_connector_defined_tags != null ? merge(local.custom_service_connector_defined_tags, local.default_service_connector_defined_tags) : local.default_service_connector_defined_tags
  service_connector_freeform_tags = local.custom_service_connector_freeform_tags != null ? merge(local.custom_service_connector_freeform_tags, local.default_service_connector_freeform_tags) : local.default_service_connector_freeform_tags

#-- Service Connector Target tags 
  default_target_defined_tags = null
  default_target_freeform_tags = local.landing_zone_tags  
  target_defined_tags = local.custom_target_defined_tags != null ? merge(local.custom_target_defined_tags, local.default_target_defined_tags) : local.default_target_defined_tags
  target_freeform_tags = local.custom_target_freeform_tags != null ? merge(local.custom_target_freeform_tags, local.default_target_freeform_tags) : local.default_target_freeform_tags

#-- Service Connector Policy tags 
  default_policy_defined_tags = null
  default_policy_freeform_tags = local.landing_zone_tags  
  policy_defined_tags = local.custom_policy_defined_tags != null ? merge(local.custom_policy_defined_tags, local.default_policy_defined_tags) : local.default_policy_defined_tags
  policy_freeform_tags = local.custom_policy_freeform_tags != null ? merge(local.custom_policy_freeform_tags, local.default_policy_freeform_tags) : local.default_policy_freeform_tags

#-- Service Connector resources naming 
  default_service_connector_name = "${var.service_label}-service-connector"
  service_connector_name = local.custom_service_connector_name != null ? local.custom_service_connector_name : local.default_service_connector_name

  default_service_connector_target_bucket_name = "${var.service_label}-service-connector-bucket"
  service_connector_target_bucket_name = local.custom_service_connector_target_bucket_name != null ? local.custom_service_connector_target_bucket_name : local.default_service_connector_target_bucket_name

  default_service_connector_target_stream_name = "${var.service_label}-service-connector-stream"
  service_connector_target_stream_name = local.custom_service_connector_target_stream_name != null ? local.custom_service_connector_target_stream_name : local.default_service_connector_target_stream_name
  
  default_service_connector_target_log_group_name = "${var.service_label}-service-connector-log-group"
  service_connector_target_log_group_name = local.custom_service_connector_target_log_group_name != null ? local.custom_service_connector_target_log_group_name : local.default_service_connector_target_log_group_name

  default_service_connector_target_object_name_prefix = "sch"
  service_connector_target_object_name_prefix = local.custom_service_connector_target_object_name_prefix != null ? local.custom_service_connector_target_object_name_prefix : local.default_service_connector_target_object_name_prefix

  default_service_connector_target_policy_name = "${var.service_label}-service-connector-target-${local.region_key}-policy"
  service_connector_target_policy_name = local.custom_service_connector_target_policy_name != null ? local.custom_service_connector_target_policy_name : local.default_service_connector_target_policy_name
}