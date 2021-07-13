# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "lz_cloud_guard" {
  count                 = var.cloud_guard_configuration_status == "ENABLE" ? (data.oci_cloud_guard_cloud_guard_configuration.this != null ? (data.oci_cloud_guard_cloud_guard_configuration.this.status != "ENABLED" ? 1 : 0) :  1) : 0
  depends_on            = [null_resource.slow_down_cloud_guard]
  source                = "../modules/monitoring/cloud-guard"
  providers             = { oci = oci.home }
  compartment_id        = var.tenancy_ocid
  reporting_region      = local.regions_map[local.home_region_key]
  status                = var.cloud_guard_configuration_status == "ENABLE" ? "ENABLED" : "DISABLED"
  self_manage_resources = false
  default_target        = { name : local.cg_target_name, type : "COMPARTMENT", id : var.tenancy_ocid }
}

resource "null_resource" "slow_down_cloud_guard" {
  depends_on = [module.lz_services_policy]
  provisioner "local-exec" {
    command = "sleep ${local.delay_in_secs}" # Wait for policies to be available.
  }
}