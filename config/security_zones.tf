# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



module "lz_sch_vcnFlowLogs_bucket" {
    depends_on = [ null_resource.slow_down_buckets ]
    count = (var.create_service_connector_vcnFlowLogs  == true && lower(var.service_connector_vcnFlowLogs_target) == "objectstorage") ? 1 : 0
    source       = "../modules/object-storage/bucket"
    kms_key_id   = module.lz_keys.keys[local.oss_key_name].id
    buckets = { 
        (local.sch_vcnFlowLogs_bucket_name) = {
            compartment_id = local.security_compartment_id #module.lz_compartments.compartments[local.security_compartment.key].id
            name = local.sch_vcnFlowLogs_bucket_name
            namespace = data.oci_objectstorage_namespace.this.namespace
            defined_tags = local.service_connector_defined_tags
            freeform_tags = local.service_connector_freeform_tags
        }
    }
}