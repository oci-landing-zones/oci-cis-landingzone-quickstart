# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "cis_notification_network_gateways_changes" {
  source            = "../modules/monitoring/notifications"
  compartment_id    = var.tenancy_ocid
  rule_display_name = "${var.service_label}-notify-on-network-gateways-changes"
  rule_description  = "Sends notification when network gateways are created, updated, deleted, attached, detached, or moved."
  rule_is_enabled   = true
  rule_condition    = <<EOT
  {"eventType":
    ["com.oraclecloud.virtualnetwork.createdrg",
     "com.oraclecloud.virtualnetwork.deletedrg",
     "com.oraclecloud.virtualnetwork.updatedrg",
     "com.oraclecloud.virtualnetwork.createdrgattachment",
     "com.oraclecloud.virtualnetwork.deletedrgattachment",
     "com.oraclecloud.virtualnetwork.updatedrgattachment",
     "com.oraclecloud.virtualnetwork.createinternetgateway",
     "com.oraclecloud.virtualnetwork.deleteinternetgateway",
     "com.oraclecloud.virtualnetwork.updateinternetgateway",
     "com.oraclecloud.virtualnetwork.changeinternetgatewaycompartment",
     "com.oraclecloud.virtualnetwork.createlocalpeeringgateway",
     "com.oraclecloud.virtualnetwork.deletelocalpeeringgateway",
     "com.oraclecloud.virtualnetwork.updatelocalpeeringgateway",
     "com.oraclecloud.virtualnetwork.changelocalpeeringgatewaycompartment",
     "com.oraclecloud.natgateway.createnatgateway",
     "com.oraclecloud.natgateway.deletenatgateway",
     "com.oraclecloud.natgateway.updatenatgateway",
     "com.oraclecloud.natgateway.changenatgatewaycompartment",
     "com.oraclecloud.servicegateway.createservicegateway",
     "com.oraclecloud.servicegateway.deleteservicegateway.begin",
     "com.oraclecloud.servicegateway.deleteservicegateway.end",
     "com.oraclecloud.servicegateway.attachserviceid",
     "com.oraclecloud.servicegateway.detachserviceid",
     "com.oraclecloud.servicegateway.updateservicegateway",
     "com.oraclecloud.servicegateway.changeservicegatewaycompartment"]
  }
  EOT

  rule_actions_actions_action_type = "ONS"
  rule_actions_actions_is_enabled  = true
  rule_actions_actions_description = "Sends notification via ONS"

  topic_id = module.cis_network_topic.topic_id
}  