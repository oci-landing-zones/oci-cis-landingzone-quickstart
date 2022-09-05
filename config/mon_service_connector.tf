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

    all_service_connector_defined_tags = {}
    all_service_connector_freeform_tags = {}

    all_target_defined_tags = {}
    all_target_freeform_tags = {}

    all_policy_defined_tags = {}
    all_policy_freeform_tags = {}

    ### DON'T TOUCH THESE ###
    #---------------------------------------------
    #--- Service Connector tags ------------------
    #---------------------------------------------
    default_service_connector_defined_tags = null
    default_service_connector_freeform_tags = local.landing_zone_tags
    service_connector_defined_tags = length(local.all_service_connector_defined_tags) > 0 ? local.all_service_connector_defined_tags : local.default_service_connector_defined_tags
    service_connector_freeform_tags = length(local.all_service_connector_freeform_tags) > 0 ? merge(local.all_service_connector_freeform_tags, local.default_service_connector_freeform_tags) : local.default_service_connector_freeform_tags

    #---------------------------------------------
    #--- Service Connector Target tags -----------
    #---------------------------------------------
    default_target_defined_tags = null
    default_target_freeform_tags = local.landing_zone_tags  
    target_defined_tags = length(local.all_target_defined_tags) > 0 ? local.all_target_defined_tags : local.default_target_defined_tags
    target_freeform_tags = length(local.all_target_freeform_tags) > 0 ? merge(local.all_target_freeform_tags, local.default_target_freeform_tags) : local.default_target_freeform_tags

    #---------------------------------------------
    #--- Service Connector Policy tags -----------
    #---------------------------------------------
    default_policy_defined_tags = null
    default_policy_freeform_tags = local.landing_zone_tags  
    policy_defined_tags = length(local.all_policy_defined_tags) > 0 ? local.all_policy_defined_tags : local.default_policy_defined_tags
    policy_freeform_tags = length(local.all_policy_freeform_tags) > 0 ? merge(local.all_policy_freeform_tags, local.default_policy_freeform_tags) : local.default_policy_freeform_tags
  

}
module "lz_service_connector" {
    source = "../modules/monitoring/service-connector-v2"
    providers = {
        oci = oci
        oci.home = oci.home
    }
    depends_on = [null_resource.wait_on_keys_policy]
    tenancy_ocid             = var.tenancy_ocid
    service_label            = var.service_label
    display_name             = var.service_connector_name
    compartment_id           = local.security_compartment_id
    enable_service_connector = var.enable_service_connector
    defined_tags             = local.service_connector_defined_tags
    freeform_tags            = local.service_connector_freeform_tags

    logs_sources = concat(local.audit_logs_sources, local.oss_logs_sources, local.flow_logs_sources)
    
    target_kind           = var.service_connector_target_kind
    target_compartment_id = local.security_compartment_id

    target_bucket_name          = var.service_connector_target_bucket_name
    target_object_name_prefix   = var.service_connector_target_object_name_prefix
    target_bucket_kms_key_id    = module.lz_keys.keys[local.oss_key_name].id
    
    target_stream = var.service_connector_target_stream

    target_function_id = var.service_connector_target_function_id

    target_defined_tags  = local.target_defined_tags
    target_freeform_tags = local.target_freeform_tags

    policy_defined_tags  = local.policy_defined_tags
    policy_freeform_tags = local.policy_freeform_tags
} 