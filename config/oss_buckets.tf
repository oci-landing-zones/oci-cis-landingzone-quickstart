# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

#------------------------------------------------------------------------------------------------------
#-- Any of these local vars before ### DON'T TOUCH THESE ### can be overriden in a _override.tf file
#------------------------------------------------------------------------------------------------------
locals { 

  custom_bucket_name = null
  all_buckets_defined_tags = null
  all_buckets_freeform_tags = null

  ### DON'T TOUCH THESE ###
  default_bucket_name = "${var.service_label}-appdev-bucket"
  default_buckets_defined_tags = null
  default_buckets_freeform_tags = local.landing_zone_tags

  bucket_name = local.custom_bucket_name != null ? local.custom_bucket_name : local.default_bucket_name
  buckets_defined_tags = local.all_buckets_defined_tags != null ? local.all_buckets_defined_tags : local.default_buckets_defined_tags
  buckets_freeform_tags = local.all_buckets_freeform_tags != null ? merge(local.all_buckets_freeform_tags, local.default_buckets_freeform_tags) : local.default_buckets_freeform_tags
  ###

  bucket_key = "${var.service_label}-appdev-bucket"

  buckets = { 
    (local.bucket_key) = {
      compartment_id = local.appdev_compartment_id
      name = local.bucket_name
      namespace = data.oci_objectstorage_namespace.this.namespace
      kms_key_id = var.existing_bucket_key_id != null ? var.existing_bucket_key_id : (length(module.lz_keys) > 0 ? module.lz_keys[0].keys[local.appdev_key_mapkey].id : null)
      defined_tags = local.buckets_defined_tags
      freeform_tags = local.buckets_freeform_tags
    }
  }
}

module "lz_buckets" {
  source     = "../modules/object-storage/bucket"
  count      = var.enable_oss_bucket ? 1 : 0
  depends_on = [null_resource.wait_on_keys_policy]
  buckets    = local.buckets
  cis_level  = var.cis_level
}

resource "null_resource" "wait_on_keys_policy" {
   depends_on = [ module.lz_keys ]
   provisioner "local-exec" {
     interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
     command     = local.is_windows ? "Start-Sleep ${local.delay_in_secs * 2}" : "sleep ${local.delay_in_secs * 2}"
   }
}
