# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
    notify_on_iam_changes_rule          = {key:"${var.service_label}-notify-on-iam-changes-rule",           name:"${var.service_label}-notify-on-iam-changes-rule" }
    notify_on_network_changes_rule      = {key:"${var.service_label}-notify-on-network-changes-rule",       name:"${var.service_label}-notify-on-network-changes-rule"}
    notify_on_storage_changes_rule      = {key:"${var.service_label}-notify-on-storage-changes-rule",       name:"${var.service_label}-notify-on-storage-changes-rule"}
    notify_on_database_changes_rule     = {key:"${var.service_label}-notify-on-database-changes-rule",      name:"${var.service_label}-notify-on-database-changes-rule"}
    notify_on_exainfra_changes_rule     = {key:"${var.service_label}-notify-on-exainfra-changes-rule",      name:"${var.service_label}-notify-on-exainfra-changes-rule"}
    notify_on_budget_changes_rule       = {key:"${var.service_label}-notify-on-budget-changes-rule",        name:"${var.service_label}-notify-on-budget-changes-rule"}
    notify_on_compute_changes_rule      = {key:"${var.service_label}-notify-on-compute-changes-rule",       name:"${var.service_label}-notify-on-compute-changes-rule"}

    exainfra_events = "\"com.oraclecloud.databaseservice.autonomous.exadata.infrastructure.critical\", \"com.oraclecloud.databaseservice.cloudexadatainfrastructure.critical\""
    default_database_events = "\"com.oraclecloud.databaseservice.autonomous.database.critical\",\"com.oraclecloud.databaseservice.dbsystem.critical\""
    database_events = var.deploy_exainfra_cmp == true ?  local.default_database_events: "${local.exainfra_events},${local.default_database_events}"
    
  home_region_notifications = {
   for i in [1] :     (local.notify_on_iam_changes_rule.key) => {
      compartment_id      = var.tenancy_ocid
      description         = "Landing Zone CIS related events rule to detect when IAM resources are created, updated or deleted."
      is_enabled          = true
      condition           = <<EOT
            {"eventType": 
            ["com.oraclecloud.identitycontrolplane.createidentityprovider",
            "com.oraclecloud.identitycontrolplane.deleteidentityprovider",
            "com.oraclecloud.identitycontrolplane.updateidentityprovider",
            "com.oraclecloud.identitycontrolplane.createidpgroupmapping",
            "com.oraclecloud.identitycontrolplane.deleteidpgroupmapping",
            "com.oraclecloud.identitycontrolplane.updateidpgroupmapping",
            "com.oraclecloud.identitycontrolplane.addusertogroup",
            "com.oraclecloud.identitycontrolplane.creategroup",
            "com.oraclecloud.identitycontrolplane.deletegroup",
            "com.oraclecloud.identitycontrolplane.removeuserfromgroup",
            "com.oraclecloud.identitycontrolplane.updategroup",
            "com.oraclecloud.identitycontrolplane.createpolicy",
            "com.oraclecloud.identitycontrolplane.deletepolicy",
            "com.oraclecloud.identitycontrolplane.updatepolicy",
            "com.oraclecloud.identitycontrolplane.createuser",
            "com.oraclecloud.identitycontrolplane.deleteuser",
            "com.oraclecloud.identitycontrolplane.updateuser",
            "com.oraclecloud.identitycontrolplane.updateusercapabilities",
            "com.oraclecloud.identitycontrolplane.updateuserstate"]
            }
            EOT
      actions_action_type = "ONS"
      actions_is_enabled  = true
      actions_description = "Sends notification via ONS"
      topic_id            = local.security_topic.id != null ? local.security_topic.id : module.lz_home_region_topics.topics[local.security_topic.key].id
      defined_tags        = null
    } # if var.extend_landing_zone_to_new_region == false
  }
  regional_notifications =  merge (
    {for i in [1] : (local.notify_on_network_changes_rule.key) => {
      compartment_id      = var.tenancy_ocid
      description         = "Landing Zone events rule to detect when networking resources are created, updated or deleted."
      is_enabled          = true
      condition           = <<EOT
        {"eventType":
          ["com.oraclecloud.virtualnetwork.createvcn",
          "com.oraclecloud.virtualnetwork.deletevcn",
          "com.oraclecloud.virtualnetwork.updatevcn",
          "com.oraclecloud.virtualnetwork.createroutetable",
          "com.oraclecloud.virtualnetwork.deleteroutetable",
          "com.oraclecloud.virtualnetwork.updateroutetable",
          "com.oraclecloud.virtualnetwork.changeroutetablecompartment",
          "com.oraclecloud.virtualnetwork.createsecuritylist",
          "com.oraclecloud.virtualnetwork.deletesecuritylist",
          "com.oraclecloud.virtualnetwork.updatesecuritylist",
          "com.oraclecloud.virtualnetwork.changesecuritylistcompartment",
          "com.oraclecloud.virtualnetwork.createnetworksecuritygroup",
          "com.oraclecloud.virtualnetwork.deletenetworksecuritygroup",
          "com.oraclecloud.virtualnetwork.updatenetworksecuritygroup",
          "com.oraclecloud.virtualnetwork.updatenetworksecuritygroupsecurityrules",
          "com.oraclecloud.virtualnetwork.changenetworksecuritygroupcompartment",
          "com.oraclecloud.virtualnetwork.createdrg",
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
          "com.oraclecloud.servicegateway.changeservicegatewaycompartment"
          ]
        }
        EOT
      actions_action_type = "ONS"
      actions_is_enabled  = true
      actions_description = "Sends notification via ONS"
      topic_id            = local.network_topic.id == null ? module.lz_topics.topics[local.network_topic.key].id : local.network_topic.id
      defined_tags        = null
    }},
    {for i in [1] : (local.notify_on_storage_changes_rule.key) => {
      compartment_id      = local.storage_topic.cmp_id
      description         = "Landing Zone events rule to detect when storage resources are created, updated or deleted."
      is_enabled          = var.create_events_as_enabled
      condition           = <<EOT
            {"eventType": 
            ["com.oraclecloud.objectstorage.createbucket",
             "com.oraclecloud.objectstorage.deletebucket",
             "com.oraclecloud.blockvolumes.deletevolume.begin",
             "com.oraclecloud.filestorage.deletefilesystem"
            ]
            }
            EOT
      actions_action_type = "ONS"
      actions_is_enabled  = true
      actions_description = "Sends notification via ONS"
      topic_id            = local.storage_topic.id == null ? module.lz_topics.topics[local.storage_topic.key].id : local.storage_topic.id
      defined_tags        = null
    } if length(var.compute_admin_email_endpoints) > 0},
    
    {for i in [1] : (local.notify_on_database_changes_rule.key) => {
      compartment_id      = local.database_topic.cmp_id       
      description         = "Landing Zone events rule to detect when database resources are created, updated or deleted in the database compartment."
      is_enabled          = var.create_events_as_enabled
      condition           = <<EOT
            {"eventType": 
            [${local.database_events}]
            }
            EOT
      actions_action_type = "ONS"
      actions_is_enabled  = true
      actions_description = "Sends notification via ONS"
      topic_id            = local.database_topic.id == null ? module.lz_topics.topics[local.database_topic.key].id : local.database_topic.id
      defined_tags        = null
    } if length(var.database_admin_email_endpoints)  > 0},

     
     {for i in [1] : (local.notify_on_exainfra_changes_rule.key) => {     
      compartment_id      = local.exainfra_topic.cmp_id
      description         = "Landing Zone events rule to detect Exadata infrastructure events."
      is_enabled          = var.create_events_as_enabled
      condition           = <<EOT
            {"eventType": 
            [${local.exainfra_events}]
            }
            EOT
      actions_action_type = "ONS"
      actions_is_enabled  = true
      actions_description = "Sends notification via ONS"
      topic_id            = local.exainfra_topic.id == null ? module.lz_topics.topics[local.exainfra_topic.key].id : local.exainfra_topic.id
      defined_tags        = null
    } if length(var.exainfra_admin_email_endpoints)  > 0 && var.deploy_exainfra_cmp == true},

    {for i in [1] : (local.notify_on_budget_changes_rule.key) => {
      compartment_id      = var.tenancy_ocid
      description         = "Landing Zone events rule to detect when cost resources such as budgets and financial tracking constructs are created, updated or deleted."
      is_enabled          = var.create_events_as_enabled
      condition           = <<EOT
            {"eventType": 
            ["com.oraclecloud.budgets.updatealertrule",
             "com.oraclecloud.budgets.deletealertrule",
             "com.oraclecloud.budgets.updatebudget",
             "com.oraclecloud.budgets.deletebudget"
            ]
            }
            EOT
      actions_action_type = "ONS"
      actions_is_enabled  = true
      actions_description = "Sends notification via ONS"
      topic_id            = local.budget_topic.id == null ? module.lz_topics.topics[local.budget_topic.key].id : local.budget_topic.id
      defined_tags        = null
    } if length(var.budget_admin_email_endpoints) > 0},

    {for i in [1] : (local.notify_on_compute_changes_rule.key) => {
      compartment_id      = local.compute_topic.cmp_id
      description         = "Landing Zone events rule to detect when compute related resources are created, updated or deleted."
      is_enabled          = var.create_events_as_enabled
      condition           = <<EOT
            {"eventType": 
            ["com.oraclecloud.computeapi.terminateinstance.begin"
            ]
            }
            EOT
      actions_action_type = "ONS"
      actions_is_enabled  = true
      actions_description = "Sends notification via ONS"
      topic_id            = local.compute_topic.id == null ? module.lz_topics.topics[local.compute_topic.key].id : local.compute_topic.id
      defined_tags        = null
    } if length(var.compute_admin_email_endpoints) > 0 }
  )
}


module "lz_notifications" {
  depends_on = [null_resource.slow_down_notifications]
  source     = "../modules/monitoring/notifications"
  rules = merge(local.home_region_notifications, local.regional_notifications)
}

resource "null_resource" "slow_down_notifications" {
  depends_on = [module.lz_compartments]
  provisioner "local-exec" {
    command = "sleep ${local.delay_in_secs}" # Wait for compartments to be available.
  }
}
