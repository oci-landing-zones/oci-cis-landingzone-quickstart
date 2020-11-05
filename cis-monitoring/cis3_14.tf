### This Terraform configuration provisions flow logs for all subnets provisioned in the cis-network configuration.
locals {
    flow_logs = {for k,v in data.terraform_remote_state.network.outputs.subnets : k => 
        {
            log_display_name              = "${k}-FlowLog",
            log_type                      = "SERVICE",
            log_config_source_resource    = v.id,
            log_config_source_category    = "all",
            log_config_source_service     = "flowlogs",
            log_config_source_source_type = "OCISERVICE",
            log_config_compartment        = data.terraform_remote_state.iam.outputs.security_compartment_id,
            log_is_enabled                = true,
            log_retention_duration        = 30,
            defined_tags                  = null,
            freeform_tags                 = null
        }
    }
}
module "cis_flow_logs" {
  source                 = "../modules/monitoring/logs"
  compartment_id         = data.terraform_remote_state.iam.outputs.security_compartment_id
  log_group_display_name = "${var.service_label}-FlowLogsGroup"
  log_group_description  = "${var.service_label} flow logs group."
  target_resources = local.flow_logs 
}  