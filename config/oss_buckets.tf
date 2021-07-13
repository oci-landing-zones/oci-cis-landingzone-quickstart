# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### Creates a bucket in the specified compartment 
module "lz_buckets" {
    depends_on   = [ null_resource.slow_down_oss ]
    source       = "../modules/object-storage/bucket"
    region       = var.region
    tenancy_ocid = var.tenancy_ocid
    kms_key_id   = module.lz_keys.keys[local.oss_key_name].id
    buckets      = { 
        "${var.service_label}-appdev-bucket" = {
            compartment_id = module.lz_compartments.compartments[local.appdev_compartment_name].id
        }
    }
}

### We've observed that policies, even when created before the bucket, may take some time to be available for consumption. Hence the delay introduced here.
resource "null_resource" "slow_down_oss" {
   depends_on = [ module.lz_keys_policies ]
   provisioner "local-exec" {
     command = "sleep ${local.delay_in_secs}" # Wait for policies to be available.
   }
}

