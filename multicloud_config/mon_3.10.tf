# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "cis_notification_route_table_changes" {
  source            = "../modules/monitoring/notifications"
  compartment_id    = var.tenancy_ocid
  rule_display_name = "${var.service_label}-notify-on-route-table-changes"
  rule_description  = "Sends notification when route tables are created, updated, deleted or moved."
  rule_is_enabled   = true
  rule_condition    = <<EOT
  {"eventType":
    ["com.oraclecloud.virtualnetwork.createroutetable",
     "com.oraclecloud.virtualnetwork.deleteroutetable",
     "com.oraclecloud.virtualnetwork.updateroutetable",
     "com.oraclecloud.virtualnetwork.changeroutetablecompartment"]
  }
  EOT

  rule_actions_actions_action_type = "ONS"
  rule_actions_actions_is_enabled  = true
  rule_actions_actions_description = "Sends notification via ONS"

  topic_id = module.cis_network_topic.topic_id
}  