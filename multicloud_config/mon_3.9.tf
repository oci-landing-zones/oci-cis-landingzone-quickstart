# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "cis_notification_vcn_changes" {
  source            = "../modules/monitoring/notifications"
  compartment_id    = var.tenancy_ocid
  rule_display_name = "${var.service_label}-notify-on-vcn-changes"
  rule_description  = "Sends notification when VCNs are created, updated or deleted."
  rule_is_enabled   = true
  rule_condition    = <<EOT
  {"eventType":
    ["com.oraclecloud.virtualnetwork.createvcn",
     "com.oraclecloud.virtualnetwork.deletevcn",
     "com.oraclecloud.virtualnetwork.updatevcn"]
  }
  EOT

  rule_actions_actions_action_type = "ONS"
  rule_actions_actions_is_enabled  = true
  rule_actions_actions_description = "Sends notification via ONS"

  topic_id = module.cis_network_topic.topic_id
}  