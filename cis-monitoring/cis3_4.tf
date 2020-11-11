# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "cis_notification_idp_changes" {
  source             = "../modules/monitoring/notifications"
  compartment_id     = data.terraform_remote_state.iam.outputs.security_compartment_id
  rule_display_name  = "${var.service_label}-notify-on-idp-changes"    
  rule_description   = "Sends notification when Identity Providers are created, updated or deleted."
  rule_is_enabled    = true
  #rule_condition     = "{\"eventType\": [\"com.oraclecloud.identityControlPlane.CreateIdentityProvider\",\"com.oraclecloud.identityControlPlane.DeleteIdentityProvider\",\"com.oraclecloud.identityControlPlane.UpdateIdentityProvider\"]}"
  rule_condition     = <<EOT
  {"eventType": 
    ["com.oraclecloud.identityControlPlane.CreateIdentityProvider",
     "com.oraclecloud.identityControlPlane.DeleteIdentityProvider",
     "com.oraclecloud.identityControlPlane.UpdateIdentityProvider"]
  }
  EOT
  
  rule_actions_actions_action_type = "ONS"
  rule_actions_actions_is_enabled  = true
  rule_actions_actions_description = "Sends notification via ONS"

  topic_id = module.cis_security_topic.topic_id
}  