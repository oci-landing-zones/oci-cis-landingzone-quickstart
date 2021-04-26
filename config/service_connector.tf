# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Getting Object Storage Namespace
data "oci_objectstorage_namespace" "bucket_namespace" {
    compartment_id = var.tenancy_ocid
}

module "sch_audit_bucket" {
    count = (var.create_service_connector_audit  == true && var.service_connector_audit_target == "objectStorage") ? 1 : 0
    source       = "../modules/object-storage/bucket"
    region       = var.region
    tenancy_ocid = var.tenancy_ocid
    kms_key_id   = module.cis_keys.keys[local.oss_key_name].id
    buckets = { 
        (local.sch_audit_bucket_name) = {
            compartment_id = module.cis_compartments.compartments[local.security_compartment_name].id
        }
    }
}


module "sch_vcnFlowLogs_bucket" {
    count = (var.create_service_connector_vcnFlowLogs  == true && var.service_connector_vcnFlowLogs_target == "objectStorage") ? 1 : 0
    source       = "../modules/object-storage/bucket"
    region       = var.region
    tenancy_ocid = var.tenancy_ocid
    kms_key_id   = module.cis_keys.keys[local.oss_key_name].id
    buckets = { 
        (local.sch_vcnFlowLogs_bucket_name) = {
            compartment_id = module.cis_compartments.compartments[local.security_compartment_name].id
        }
    }
}


module "service_connector_hub_audit" {
    count = (var.create_service_connector_audit  == true ) ? 1 : 0
    source = "../modules/monitoring/service-connector"
    service_connector = {
        compartment_id = module.cis_compartments.compartments[local.security_compartment_name].id
        service_connector_display_name = local.sch_audit_display_name
        #service_connector_source_kind = var.service_connector_audit_target
        service_connector_source_kind = "logging"
        service_connector_state = var.service_connector_audit_state
        log_sources = [for k, v in module.cis_compartments.compartments : {
            compartment_id = v.id
            log_group_id = "_Audit"
            log_id = ""
        }]
        target = {
            target_kind = var.service_connector_audit_target
            compartment_id = module.cis_compartments.compartments[local.security_compartment_name].id
            batch_rollover_size_in_mbs = var.service_connector_audit_target == "objectStorage"? var.sch_audit_target_rollover_MBs : null
            batch_rollover_time_in_ms = var.service_connector_audit_target == "objectStorage"? var.sch_audit_target_rollover_MBs : null
            object_store_details = var.service_connector_audit_target == "objectStorage" ? {
                namespace = data.oci_objectstorage_namespace.bucket_namespace.namespace
                bucket_name = module.sch_audit_bucket[0].oci_objectstorage_buckets[local.sch_audit_bucket_name].name
                object_name_prefix = var.sch_audit_objStore_objNamePrefix 
            } : null
            stream_id = var.service_connector_audit_target == "streaming"? var.service_connector_audit_target_OCID : null
            function_id = var.service_connector_audit_target == "functions"? var.service_connector_audit_target_OCID : null
        }
    }
}

module "service_connector_hub_vcnFlowLogs" {
    count = (var.create_service_connector_vcnFlowLogs  == true ) ? 1 : 0
    source = "../modules/monitoring/service-connector"
    service_connector = {
        compartment_id = module.cis_compartments.compartments[local.security_compartment_name].id
        service_connector_display_name = local.sch_vcnFlowLogs_display_name
        #service_connector_source_kind = var.service_connector_vcnFlowLogs_target
        service_connector_source_kind = "logging"
        service_connector_state = var.service_connector_vcnFlowLogs_state
        log_sources = [for k, v in module.cis_flow_logs.logs : {
            compartment_id = module.cis_compartments.compartments[local.security_compartment_name].id
            log_group_id = module.cis_flow_logs.log_group.id
            log_id = v.id
        }]
        target = {
            target_kind = var.service_connector_vcnFlowLogs_target
            compartment_id = module.cis_compartments.compartments[local.security_compartment_name].id
            batch_rollover_size_in_mbs = var.service_connector_vcnFlowLogs_target == "objectStorage"? var.sch_vcnFlowLogs_target_rollover_MBs : null
            batch_rollover_time_in_ms = var.service_connector_vcnFlowLogs_target == "objectStorage"? var.sch_vcnFlowLogs_target_rollover_MBs : null
            object_store_details = var.service_connector_vcnFlowLogs_target == "objectStorage" ? {
                namespace = data.oci_objectstorage_namespace.bucket_namespace.namespace
                bucket_name = module.sch_vcnFlowLogs_bucket[0].oci_objectstorage_buckets[local.sch_vcnFlowLogs_bucket_name].name
                object_name_prefix = var.sch_vcnFlowLogs_objStore_objNamePrefix 
            } : null
            stream_id = var.service_connector_vcnFlowLogs_target == "streaming"? var.service_connector_vcnFlowLogs_target_OCID : null
            function_id = var.service_connector_vcnFlowLogs_target == "functions"? var.service_connector_vcnFlowLogs_target_OCID : null
        }
    }
}