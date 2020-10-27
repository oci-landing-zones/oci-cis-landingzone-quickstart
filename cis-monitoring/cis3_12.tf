module "cis_notification_nsg_changes" {
  source             = "../modules/monitoring/notifications"
  compartment_id     = var.tenancy_ocid
  rule_display_name  = "${var.service_label}-notify-on-nsg-changes"    
  rule_description   = "Sends notification when network security groups are created, updated, deleted, or moved."
  rule_is_enabled    = true
  rule_condition     = <<EOT
  {"eventType":
    ["com.oraclecloud.virtualnetwork.createnetworksecuritygroup",
     "com.oraclecloud.virtualnetwork.deletenetworksecuritygroup",
     "com.oraclecloud.virtualnetwork.updatenetworksecuritygroup",
     "com.oraclecloud.virtualnetwork.changenetworksecuritygroupcompartment"]
  }
  EOT
  
  rule_actions_actions_action_type = "ONS"
  rule_actions_actions_is_enabled  = true
  rule_actions_actions_description = "Sends notification via ONS"

  topic_id = module.cis_topics.topic_id
}  