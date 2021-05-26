# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "cis_cloud_guard" {
  depends_on            = [ module.lz_cloud_guard_policies ]
  source                = "../modules/monitoring/cloud-guard"
  providers             = { oci = oci.home }
  compartment_id        = var.tenancy_ocid
  reporting_region      = local.regions_map[local.home_region_key]
  status                = var.cloud_guard_configuration_status
  self_manage_resources = false
  default_target        = {name:local.cg_target_name, type:"COMPARTMENT", id:var.tenancy_ocid} 
}
