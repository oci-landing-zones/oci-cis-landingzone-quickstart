# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "cis_cloud_guard" {
  source                = "../modules/monitoring/cloud-guard"
  compartment_id        = var.tenancy_ocid
  reporting_region      = var.region
  status                = var.cloud_guard_configuration_status
  self_manage_resources = var.cloud_guard_configuration_self_manage_resources
  service_label         = var.service_label 
}