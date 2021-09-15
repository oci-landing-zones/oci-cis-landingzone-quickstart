# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration provisions flow logs for all subnets provisioned in the cis-network configuration.
locals {
  all_lz_subnets = merge(module.lz_vcn_spokes.subnets, module.lz_vcn_dmz.subnets, module.lz_exacs_vcns.subnets)  

  flow_logs = { for k, v in local.all_lz_subnets : k =>
    {
      log_display_name              = "${k}-flow-log",
      log_type                      = "SERVICE",
      log_config_source_resource    = v.id,
      log_config_source_category    = "all",
      log_config_source_service     = "flowlogs",
      log_config_source_source_type = "OCISERVICE",
      log_config_compartment        = module.lz_compartments.compartments[local.security_compartment.key].id,
      log_is_enabled                = true,
      log_retention_duration        = 30,
      defined_tags                  = null,
      freeform_tags                 = null
    }
  }
}
module "lz_flow_logs" {
  depends_on             = [module.lz_vcn_spokes, module.lz_vcn_dmz, module.lz_exacs_vcns]
  source                 = "../modules/monitoring/logs"
  compartment_id         = module.lz_compartments.compartments[local.security_compartment.key].id
  log_group_display_name = "${var.service_label}-flow-logs-group"
  log_group_description  = "Landing Zone ${var.service_label} flow logs group."
  target_resources       = local.flow_logs
}  