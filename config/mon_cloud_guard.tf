# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  cg_target_name = "${var.service_label}-cloud-guard-root-target"

  all_cloud_guard_target_defined_tags = {}
  all_cloud_guard_target_freeform_tags = {}

  #### DON'T THOUCH THE LINES BELOW ####
  default_cloud_guard_target_defined_tags = null
  default_cloud_guard_target_freeform_tags = local.landing_zone_tags
  
  cloud_guard_target_defined_tags = length(local.all_cloud_guard_target_defined_tags) > 0 ? local.all_cloud_guard_target_defined_tags : local.default_cloud_guard_target_defined_tags
  cloud_guard_target_freeform_tags = length(local.all_cloud_guard_target_freeform_tags) > 0 ? merge(local.all_cloud_guard_target_freeform_tags, local.default_cloud_guard_target_freeform_tags) : local.default_cloud_guard_target_freeform_tags

}

module "lz_cloud_guard" {
  count                 = var.cloud_guard_configuration_status == "ENABLE" ? (data.oci_cloud_guard_cloud_guard_configuration.this != null ? (data.oci_cloud_guard_cloud_guard_configuration.this.status != "ENABLED" ? 1 : 0) :  1) : 0
  depends_on            = [null_resource.wait_on_services_policy]
  source                = "../modules/monitoring/cloud-guard"
  providers             = { oci = oci.home }
  compartment_id        = var.tenancy_ocid
  reporting_region      = local.regions_map[local.home_region_key]
  status                = var.cloud_guard_configuration_status == "ENABLE" ? "ENABLED" : "DISABLED"
  self_manage_resources = false
  defined_tags          = local.cloud_guard_target_defined_tags
  freeform_tags         = local.cloud_guard_target_freeform_tags
  default_target        = { name : local.cg_target_name, type : "COMPARTMENT", id : var.tenancy_ocid }
}