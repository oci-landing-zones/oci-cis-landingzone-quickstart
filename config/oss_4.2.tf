# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### Creates a bucket in the specified compartment 
module "cis_buckets" {
    depends_on   = [ null_resource.slow_down_oss ]
    source       = "../modules/object-storage/bucket"
    region       = var.region
    tenancy_ocid = var.tenancy_ocid
    kms_key_id   = module.cis_keys.keys[local.oss_key_name].id
    buckets      = { 
        "${var.service_label}-AppDevBucket" = {
            compartment_id = module.cis_compartments.compartments[local.appdev_compartment_name].id
        }
    }
}

### We've observed that policies, even when created before the bucket, may take some time to be available for consumption. Hence the delay introduced here.
resource "null_resource" "slow_down_oss" {
   depends_on = [ module.cis_keys_policies ]
   provisioner "local-exec" {
     command = "sleep 30" # Wait 30 seconds for policies to be available.
   }
}

