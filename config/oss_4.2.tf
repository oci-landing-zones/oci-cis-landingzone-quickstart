# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### Creates a bucket in the specified compartment 
module "cis_buckets" {
    source       = "../modules/object-storage/bucket"
    region       = var.region
    tenancy_ocid = var.tenancy_ocid
    kms_key_id   = module.cis_keys.keys[local.oss_key_name].id
    buckets      = {
        "${var.service_label}-ComputeBucket" = {
            compartment_id = module.cis_compartments.compartments[local.compute_storage_compartment_name].id
        },
        "${var.service_label}-AppDevBucket" = {
            compartment_id = module.cis_compartments.compartments[local.appdev_compartment_name].id
        }
    }
}  

