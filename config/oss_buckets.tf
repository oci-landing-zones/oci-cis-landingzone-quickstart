# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### Creates a bucket in the specified compartment 
locals {
  all_buckets = {}
  all_buckets_defined_tags = {}
  all_buckets_freeform_tags = {}

  # Names
  appdev_bucket_name = "${var.service_label}-appdev-bucket"

  default_buckets = { 
    (local.appdev_bucket_name) = {
      compartment_id = local.appdev_compartment_id
      name = local.appdev_bucket_name
      namespace = data.oci_objectstorage_namespace.this.namespace
      defined_tags = local.buckets_defined_tags
      freeform_tags = local.buckets_freeform_tags
    }
  }

  ### DON'T TOUCH THESE ###
  default_buckets_defined_tags = null
  default_buckets_freeform_tags = local.landing_zone_tags

  buckets_defined_tags = length(local.all_buckets_defined_tags) > 0 ? local.all_buckets_defined_tags : local.default_buckets_defined_tags
  buckets_freeform_tags = length(local.all_buckets_freeform_tags) > 0 ? merge(local.all_buckets_freeform_tags, local.default_buckets_freeform_tags) : local.default_buckets_freeform_tags

}

module "lz_buckets" {
  depends_on = [ null_resource.wait_on_keys_policy ]
  source     = "../modules/object-storage/bucket"
  kms_key_id = module.lz_keys.keys[local.oss_key_name].id
  buckets    = length(local.all_buckets) > 0 ? local.all_buckets : local.default_buckets
}

