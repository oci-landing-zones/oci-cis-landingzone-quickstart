# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration provisions flow logs for all subnets provisioned in the cis-network configuration.
locals {
  all_flow_logs_defined_tags = {}
  all_flow_logs_freeform_tags = {}

  all_lz_subnets = merge(module.lz_vcn_spokes.subnets, module.lz_vcn_dmz.subnets, module.lz_exacs_vcns.subnets)  

  flow_logs = { for k, v in local.all_lz_subnets : k =>
    {
      log_display_name              = "${k}-flow-log",
      log_type                      = "SERVICE",
      log_config_source_resource    = v.id,
      log_config_source_category    = "all",
      log_config_source_service     = "flowlogs",
      log_config_source_source_type = "OCISERVICE",
      log_config_compartment        = local.security_compartment_id #module.lz_compartments.compartments[local.security_compartment.key].id,
      log_is_enabled                = true,
      log_retention_duration        = 30,
      defined_tags                  = local.flow_logs_defined_tags,
      freeform_tags                 = local.flow_logs_freeform_tags
    }
  }

  ### DON'T TOUCH THESE ###
  default_flow_logs_defined_tags = null
  default_flow_logs_freeform_tags = local.landing_zone_tags

  flow_logs_defined_tags = length(local.all_flow_logs_defined_tags) > 0 ? local.all_flow_logs_defined_tags : local.default_flow_logs_defined_tags
  flow_logs_freeform_tags = length(local.all_flow_logs_freeform_tags) > 0 ? merge(local.all_flow_logs_freeform_tags, local.default_flow_logs_freeform_tags) : local.default_flow_logs_freeform_tags

}

module "lz_flow_logs" {
  depends_on             = [module.lz_vcn_spokes, module.lz_vcn_dmz, module.lz_exacs_vcns]
  source                 = "../modules/monitoring/logs"
  compartment_id         = local.security_compartment_id #module.lz_compartments.compartments[local.security_compartment.key].id
  log_group_display_name = "${var.service_label}-flow-logs-group"
  log_group_description  = "Landing Zone ${var.service_label} flow logs group."
  defined_tags           = local.flow_logs_defined_tags
  freeform_tags          = local.flow_logs_freeform_tags
  target_resources       = local.flow_logs
}  