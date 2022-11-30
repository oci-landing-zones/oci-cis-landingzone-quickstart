# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  cg_target_name = "${var.service_label}-cloud-guard-root-target"

  all_cloud_guard_target_defined_tags = null
  all_cloud_guard_target_freeform_tags = null

  #### DON'T THOUCH THE LINES BELOW ####
  default_cloud_guard_target_defined_tags = null
  default_cloud_guard_target_freeform_tags = local.landing_zone_tags
  
  cloud_guard_target_defined_tags = local.all_cloud_guard_target_defined_tags != null ? merge(local.all_cloud_guard_target_defined_tags, local.default_cloud_guard_target_defined_tags)  : local.default_cloud_guard_target_defined_tags
  cloud_guard_target_freeform_tags = local.all_cloud_guard_target_freeform_tags != null ? merge(local.all_cloud_guard_target_freeform_tags, local.default_cloud_guard_target_freeform_tags) : local.default_cloud_guard_target_freeform_tags

}

module "lz_cloud_guard" {
  count                 = var.enable_cloud_guard ? 1 : 0
  depends_on            = [null_resource.wait_on_services_policy]
  source                = "github.com/andrecorreaneto/terraform-oci-cis-landing-zone-cloud-guard"
  providers             = { oci = oci.home }
  enable_cloud_guard    = var.enable_cloud_guard
  enable_cloned_recipes = var.enable_cloud_guard_cloned_recipes
  reporting_region      = var.cloud_guard_reporting_region != null ? var.cloud_guard_reporting_region : local.regions_map[local.home_region_key]
  tenancy_id            = var.tenancy_ocid
  compartment_id        = var.tenancy_ocid
  target_resource_id    = var.tenancy_ocid
  name_prefix           = var.service_label
  defined_tags          = local.cloud_guard_target_defined_tags
  freeform_tags         = local.cloud_guard_target_freeform_tags
}