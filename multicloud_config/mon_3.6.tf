# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "cis_notification_iam_group_changes" {
  source            = "../modules/monitoring/notifications"
  compartment_id    = var.tenancy_ocid
  rule_display_name = "${var.service_label}-notify-on-iam-group-changes"
  rule_description  = "Sends notification when IAM groups are created, updated or deleted."
  rule_is_enabled   = true
  rule_condition    = <<EOT
  {"eventType": 
    ["com.oraclecloud.identitycontrolplane.addusertogroup",
     "com.oraclecloud.identitycontrolplane.creategroup",
     "com.oraclecloud.identitycontrolplane.deletegroup",
     "com.oraclecloud.identitycontrolplane.removeuserfromgroup",
     "com.oraclecloud.identitycontrolplane.updategroup"]
  }
  EOT

  rule_actions_actions_action_type = "ONS"
  rule_actions_actions_is_enabled  = true
  rule_actions_actions_description = "Sends notification via ONS"

  topic_id = module.cis_security_topic.topic_id
}  