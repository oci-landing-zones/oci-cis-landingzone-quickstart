# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
    audit_logs_sources = !var.extend_landing_zone_to_new_region ? [for k, v in module.lz_compartments.compartments : {
        compartment_id = v.id
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
    source = "../modules/monitoring/service-connector"
    tenancy_ocid             = var.tenancy_ocid
    service_label            = var.service_label
    display_name             = var.service_connector_name
    compartment_id           = local.security_compartment_id
    enable_service_connector = var.enable_service_connector

    logs_sources = concat(local.audit_logs_sources, local.oss_logs_sources, local.flow_logs_sources)
    
    target_kind = var.service_connector_target_kind
    target_compartment_id = local.security_compartment_id

    target_bucket_name = var.service_connector_target_bucket_name
    target_object_name_prefix = var.service_connector_target_object_name_prefix
    target_bucket_kms_key_id = module.lz_keys.keys[local.oss_key_name].id

    target_stream = var.service_connector_target_stream

    target_function_id = var.service_connector_target_function_id
} 