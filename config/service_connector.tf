# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "lz_sch_audit_bucket" {
    depends_on = [ null_resource.slow_down_buckets ]
    count = (var.create_service_connector_audit  == true && lower(var.service_connector_audit_target) == "objectstorage") ? 1 : 0
    source       = "../modules/object-storage/bucket"
    kms_key_id   = module.lz_keys.keys[local.oss_key_name].id
    buckets = { 
        (local.sch_audit_bucket_name) = {
            compartment_id = module.lz_compartments.compartments[local.security_compartment.key].id
            name = local.sch_audit_bucket_name
            namespace = data.oci_objectstorage_namespace.this.namespace
        }
    }
}


module "lz_sch_vcnFlowLogs_bucket" {
    depends_on = [ null_resource.slow_down_buckets ]
    count = (var.create_service_connector_vcnFlowLogs  == true && lower(var.service_connector_vcnFlowLogs_target) == "objectstorage") ? 1 : 0
    source       = "../modules/object-storage/bucket"
    kms_key_id   = module.lz_keys.keys[local.oss_key_name].id
    buckets = { 
        (local.sch_vcnFlowLogs_bucket_name) = {
            compartment_id = module.lz_compartments.compartments[local.security_compartment.key].id
            name = local.sch_vcnFlowLogs_bucket_name
            namespace = data.oci_objectstorage_namespace.this.namespace
        }
    }
}


module "lz_service_connector_hub_audit" {
    count = (var.create_service_connector_audit  == true ) ? 1 : 0
    source = "../modules/monitoring/service-connector"
    service_connector = {
        compartment_id = module.lz_compartments.compartments[local.security_compartment.key].id
        service_connector_display_name = local.sch_audit_display_name
        #service_connector_source_kind = var.service_connector_audit_target
        service_connector_source_kind = "logging"
        service_connector_state = upper(var.service_connector_audit_state)
        log_sources = [for k, v in module.lz_compartments.compartments : {
            compartment_id = v.id
            log_group_id = "_Audit"
            log_id = ""
        }]
        target = {
            target_kind = lower(var.service_connector_audit_target)
            compartment_id = module.lz_compartments.compartments[local.security_compartment.key].id
            object_store_details = var.service_connector_audit_target == "objectstorage" ? {
                namespace = data.oci_objectstorage_namespace.this.namespace
                bucket_name = module.lz_sch_audit_bucket[0].oci_objectstorage_buckets[local.sch_audit_bucket_name].name
                object_name_prefix = var.sch_audit_objStore_objNamePrefix
                batch_rollover_size_in_mbs = local.sch_audit_target_rollover_MBs
                batch_rollover_time_in_ms = local.sch_audit_target_rollover_MSs
            } : null
            stream_id = var.service_connector_audit_target == "streaming"? var.service_connector_audit_target_OCID : null
            function_id = var.service_connector_audit_target == "functions"? var.service_connector_audit_target_OCID : null
        }
    }
}

module "lz_service_connector_hub_vcnFlowLogs" {
    count = (var.create_service_connector_vcnFlowLogs  == true ) ? 1 : 0
    source = "../modules/monitoring/service-connector"
    service_connector = {
        compartment_id = module.lz_compartments.compartments[local.security_compartment.key].id
        service_connector_display_name = local.sch_vcnFlowLogs_display_name
        #service_connector_source_kind = var.service_connector_vcnFlowLogs_target
        service_connector_source_kind = "logging"
        service_connector_state = upper(var.service_connector_vcnFlowLogs_state)
        log_sources = [for k, v in module.lz_flow_logs.logs : {
            compartment_id = module.lz_compartments.compartments[local.security_compartment.key].id
            log_group_id = module.lz_flow_logs.log_group.id
            log_id = v.id
        }]
        target = {
            target_kind = lower(var.service_connector_vcnFlowLogs_target)
            compartment_id = module.lz_compartments.compartments[local.security_compartment.key].id
            object_store_details = var.service_connector_vcnFlowLogs_target == "objectstorage" ? {
                namespace = data.oci_objectstorage_namespace.this.namespace
                bucket_name = module.lz_sch_vcnFlowLogs_bucket[0].oci_objectstorage_buckets[local.sch_vcnFlowLogs_bucket_name].name
                object_name_prefix = var.sch_vcnFlowLogs_objStore_objNamePrefix
                batch_rollover_size_in_mbs = local.sch_vcnFlowLogs_target_rollover_MBs
                batch_rollover_time_in_ms = local.sch_vcnFlowLogs_target_rollover_MSs
            } : null
            stream_id = var.service_connector_vcnFlowLogs_target == "streaming"? var.service_connector_vcnFlowLogs_target_OCID : null
            function_id = var.service_connector_vcnFlowLogs_target == "functions"? var.service_connector_vcnFlowLogs_target_OCID : null
        }
    }
}

module "lz_sch_audit_objStore_policy" {
  count                 = (var.create_service_connector_audit  == true && lower(var.service_connector_audit_target) == "objectstorage") ? 1 : 0
  source                = "../modules/iam/iam-policy"
  providers             = { oci = oci.home }
  depends_on            = [module.lz_service_connector_hub_audit]
  policies = {
    (local.sch_audit_policy_name) = {
      compartment_id         = local.parent_compartment_id
      description            = "Landing Zone policy for Service Connector Hub to manage objects in the target bucket."
      statements = [
                    <<EOF
                        Allow any-user to manage objects in compartment id ${module.lz_compartments.compartments[local.security_compartment.key].id} where all {
                        request.principal.type='serviceconnector',
                        target.bucket.name= '${module.lz_sch_audit_bucket[0].oci_objectstorage_buckets[local.sch_audit_bucket_name].name}',
                        request.principal.compartment.id='${module.lz_compartments.compartments[local.security_compartment.key].id}' }
                    EOF
                ]
    }
  }
}

module "lz_sch_audit_streaming_policy" {
  count                 = (var.create_service_connector_audit  == true && lower(var.service_connector_audit_target) == "streaming") ? 1 : 0
  source                = "../modules/iam/iam-policy"
  providers             = { oci = oci.home }
  depends_on            = [module.lz_service_connector_hub_audit]
  policies = {
    (local.sch_audit_policy_name) = {
      compartment_id         = local.parent_compartment_id
      description            = "Landing Zone policy for Service Connector Hub to manage messages in stream."
      statements = [
                    <<EOF
                        Allow any-user to use stream-push in compartment id ${var.service_connector_audit_target_cmpt_OCID} where all {
                        request.principal.type='serviceconnector',
                        target.stream.id='${var.service_connector_audit_target_OCID}',
                        request.principal.compartment.id='${module.lz_compartments.compartments[local.security_compartment.key].id}' }
                    EOF
                ]
    }
  }
}

module "lz_sch_audit_functions_policy" {
  count                 = (var.create_service_connector_audit  == true && lower(var.service_connector_audit_target) == "functions") ? 1 : 0
  source                = "../modules/iam/iam-policy"
  providers             = { oci = oci.home }
  depends_on            = [module.lz_service_connector_hub_audit]
  policies = {
    (local.sch_audit_policy_name) = {
      compartment_id         = local.parent_compartment_id
      description            = "Landing Zone policy for Service Connector Hub to use functions."
      statements = [
                    <<EOF
                        Allow any-user to use fn-function in compartment id ${var.service_connector_audit_target_cmpt_OCID} where all {
                        request.principal.type='serviceconnector',     
                        request.principal.compartment.id='${module.lz_compartments.compartments[local.security_compartment.key].id}'}
                    EOF
                    ,
                    <<EOF2
                        Allow any-user to use fn-invocation in compartment id ${var.service_connector_audit_target_cmpt_OCID} where all {
                        request.principal.type='serviceconnector',     
                        request.principal.compartment.id='${module.lz_compartments.compartments[local.security_compartment.key].id}' }
                    EOF2
                ]
    }
  }
}

module "lz_sch_vcnFlowLogs_objStore_policy" {
  count                 = (var.create_service_connector_vcnFlowLogs  == true && lower(var.service_connector_vcnFlowLogs_target) == "objectstorage") ? 1 : 0
  source                = "../modules/iam/iam-policy"
  providers             = { oci = oci.home }
  depends_on            = [module.lz_service_connector_hub_vcnFlowLogs]
  policies = {
    (local.sch_vcnFlowLogs_policy_name) = {
      compartment_id         = local.parent_compartment_id
      description            = "Landing Zone policy for Service Connector Hub to manage objects in the target bucket."
      statements = [
                    <<EOF
                        Allow any-user to manage objects in compartment id ${module.lz_compartments.compartments[local.security_compartment.key].id} where all {
                        request.principal.type='serviceconnector',
                        target.bucket.name= '${module.lz_sch_vcnFlowLogs_bucket[0].oci_objectstorage_buckets[local.sch_vcnFlowLogs_bucket_name].name}',
                        request.principal.compartment.id='${module.lz_compartments.compartments[local.security_compartment.key].id}' }
                    EOF
                ]
    }
  }
}

module "lz_sch_vcnFlowLogs_streaming_policy" {
  count                 = (var.create_service_connector_vcnFlowLogs  == true && lower(var.service_connector_vcnFlowLogs_target) == "streaming") ? 1 : 0
  source                = "../modules/iam/iam-policy"
  providers             = { oci = oci.home }
  depends_on            = [module.lz_service_connector_hub_vcnFlowLogs]
  policies = {
    (local.sch_vcnFlowLogs_policy_name) = {
      compartment_id         = local.parent_compartment_id
      description            = "Landing Zone policy for Service Connector Hub to manage messages in stream."
      statements = [
                    <<EOF
                        Allow any-user to use stream-push in compartment id ${var.service_connector_vcnFlowLogs_target_cmpt_OCID} where all {
                        request.principal.type='serviceconnector',
                        target.stream.id='${var.service_connector_vcnFlowLogs_target_OCID}',
                        request.principal.compartment.id='${module.lz_compartments.compartments[local.security_compartment.key].id}' }
                    EOF
                ]
    }
  }
}

module "lz_sch_vcnFlowLogs_functions_policy" {
  count                 = (var.create_service_connector_vcnFlowLogs  == true && lower(var.service_connector_vcnFlowLogs_target) == "functions") ? 1 : 0
  source                = "../modules/iam/iam-policy"
  providers             = { oci = oci.home }
  depends_on            = [module.lz_service_connector_hub_vcnFlowLogs]
  policies = {
    (local.sch_vcnFlowLogs_policy_name) = {
      compartment_id         = local.parent_compartment_id
      description            = "Landing Zone policy for Service Connector Hub to use functions."
      statements = [
                    <<EOF
                        Allow any-user to use fn-function in compartment id ${var.service_connector_vcnFlowLogs_target_cmpt_OCID} where all {
                        request.principal.type='serviceconnector',     
                        request.principal.compartment.id='${module.lz_compartments.compartments[local.security_compartment.key].id}'}
                    EOF
                    ,
                    <<EOF2
                        Allow any-user to use fn-invocation in compartment id ${var.service_connector_vcnFlowLogs_target_cmpt_OCID} where all {
                        request.principal.type='serviceconnector',     
                        request.principal.compartment.id='${module.lz_compartments.compartments[local.security_compartment.key].id}' }
                    EOF2
                ]
    }
  }
}

resource "null_resource" "slow_down_buckets" {
   depends_on = [ module.lz_keys_policies ]
   provisioner "local-exec" {
     command = "sleep ${local.delay_in_secs}" # Wait for policies to be available.
   }
}
