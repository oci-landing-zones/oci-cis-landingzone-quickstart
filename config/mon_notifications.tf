# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
    all_notifications_defined_tags = {}
    all_notifications_freeform_tags = {}

    notify_on_iam_changes_rule          = {key:"${var.service_label}-notify-on-iam-changes-rule",           name:"${var.service_label}-notify-on-iam-changes-rule" }
    notify_on_network_changes_rule      = {key:"${var.service_label}-notify-on-network-changes-rule",       name:"${var.service_label}-notify-on-network-changes-rule"}
    notify_on_storage_changes_rule      = {key:"${var.service_label}-notify-on-storage-changes-rule",       name:"${var.service_label}-notify-on-storage-changes-rule"}
    notify_on_database_changes_rule     = {key:"${var.service_label}-notify-on-database-changes-rule",      name:"${var.service_label}-notify-on-database-changes-rule"}
    notify_on_exainfra_changes_rule     = {key:"${var.service_label}-notify-on-exainfra-changes-rule",      name:"${var.service_label}-notify-on-exainfra-changes-rule"}
    notify_on_budget_changes_rule       = {key:"${var.service_label}-notify-on-budget-changes-rule",        name:"${var.service_label}-notify-on-budget-changes-rule"}
    notify_on_compute_changes_rule      = {key:"${var.service_label}-notify-on-compute-changes-rule",       name:"${var.service_label}-notify-on-compute-changes-rule"}
    notify_on_cloudguard_events_rule    = {key:"${var.service_label}-notify-on-cloudguard-events-rule",     name:"${var.service_label}-notify-on-cloudguard-events-rule"}

    default_database_events = ["com.oraclecloud.databaseservice.autonomous.database.critical","com.oraclecloud.databaseservice.dbsystem.critical"]
    exainfra_events = ["com.oraclecloud.databaseservice.exadatainfrastructure.critical","com.oraclecloud.databaseservice.autonomous.cloudautonomousvmcluster.critical"]
    database_events = var.deploy_exainfra_cmp == true ?  concat(local.default_database_events,local.exainfra_events) : local.default_database_events
    
    cloudguard_risk_levels = {
    critical = ["CRITICAL"]
    high     = ["CRITICAL","HIGH"]
    medium   = ["CRITICAL","HIGH","MEDIUM"]
    minor    = ["CRITICAL","HIGH","MEDIUM","MINOR"]
    low      = ["CRITICAL","HIGH","MEDIUM","MINOR","LOW"]
  }
    
    
  home_region_notifications = merge(
   {for i in [1] :     (local.notify_on_iam_changes_rule.key) => {
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
      defined_tags        = local.notifications_defined_tags
      freeform_tags       = local.notifications_freeform_tags
    } if var.extend_landing_zone_to_new_region == false
   },
   {for i in [1] : (local.notify_on_cloudguard_events_rule.key) => {
      compartment_id      = var.tenancy_ocid
      description         = "Landing Zone events rule to notify when Cloud Guard problems are Detected, Dismissed or Resolved."
      is_enabled          = true
      condition           = jsonencode(
           {"eventType":["com.oraclecloud.cloudguard.problemdetected","com.oraclecloud.cloudguard.problemdismissed","com.oraclecloud.cloudguard.problemremediated"],
            "data":{"additionalDetails": {"riskLevel":local.cloudguard_risk_levels[lower(var.cloud_guard_risk_level_threshold)]}}
           }
      )
      actions_action_type = "ONS"
      actions_is_enabled  = true
      actions_description = "Sends notification via ONS"
      topic_id            = local.cloudguard_topic.id != null ? local.cloudguard_topic.id : module.lz_home_region_topics.topics[local.cloudguard_topic.key].id
      defined_tags        = local.notifications_defined_tags
      freeform_tags       = local.notifications_freeform_tags
    } if (var.extend_landing_zone_to_new_region == false && length(var.cloud_guard_admin_email_endpoints)  > 0) }
  )
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
          "com.oraclecloud.virtualnetwork.deletelocalpeeringgateway.end",
          "com.oraclecloud.virtualnetwork.updatelocalpeeringgateway",
          "com.oraclecloud.virtualnetwork.changelocalpeeringgatewaycompartment",
          "com.oraclecloud.natgateway.createnatgateway",
          "com.oraclecloud.natgateway.deletenatgateway",
          "com.oraclecloud.natgateway.updatenatgateway",
          "com.oraclecloud.natgateway.changenatgatewaycompartment",
          "com.oraclecloud.servicegateway.createservicegateway",
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
      defined_tags        = local.notifications_defined_tags
      freeform_tags       = local.notifications_freeform_tags
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
      defined_tags        = local.notifications_defined_tags
      freeform_tags       = local.notifications_freeform_tags
    } if length(var.storage_admin_email_endpoints) > 0},
    
    {for i in [1] : (local.notify_on_database_changes_rule.key) => {
      compartment_id      = local.database_topic.cmp_id       
      description         = "Landing Zone events rule to detect when database resources are created, updated or deleted in the database compartment."
      is_enabled          = var.create_events_as_enabled
      condition           = jsonencode({"eventType": local.database_events})
      actions_action_type = "ONS"
      actions_is_enabled  = true
      actions_description = "Sends notification via ONS"
      topic_id            = local.database_topic.id == null ? module.lz_topics.topics[local.database_topic.key].id : local.database_topic.id
      defined_tags        = local.notifications_defined_tags
      freeform_tags       = local.notifications_freeform_tags
    } if length(var.database_admin_email_endpoints) > 0},

     
     {for i in [1] : (local.notify_on_exainfra_changes_rule.key) => {     
      compartment_id      = local.exainfra_topic.cmp_id
      description         = "Landing Zone events rule to detect Exadata infrastructure events."
      is_enabled          = var.create_events_as_enabled
      condition           = jsonencode({"eventType": local.exainfra_events})
      actions_action_type = "ONS"
      actions_is_enabled  = true
      actions_description = "Sends notification via ONS"
      topic_id            = local.exainfra_topic.id == null ? module.lz_topics.topics[local.exainfra_topic.key].id : local.exainfra_topic.id
      defined_tags        = local.notifications_defined_tags
      freeform_tags       = local.notifications_freeform_tags
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
      defined_tags        = local.notifications_defined_tags
      freeform_tags       = local.notifications_freeform_tags
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
      defined_tags        = local.notifications_defined_tags
      freeform_tags       = local.notifications_freeform_tags
    } if length(var.compute_admin_email_endpoints) > 0 }
  )

  ### DON'T TOUCH THESE ###
  default_notifications_defined_tags = null
  default_notifications_freeform_tags = local.landing_zone_tags

  notifications_defined_tags = length(local.all_notifications_defined_tags) > 0 ? local.all_notifications_defined_tags : local.default_notifications_defined_tags
  notifications_freeform_tags = length(local.all_notifications_freeform_tags) > 0 ? merge(local.all_notifications_freeform_tags, local.default_notifications_freeform_tags) : local.default_notifications_freeform_tags

}


module "lz_notifications" {
  depends_on = [null_resource.wait_on_compartments]
  source     = "../modules/monitoring/notifications"
  rules = local.regional_notifications
}

module "lz_home_region_notifications" {
  depends_on = [null_resource.wait_on_compartments]
  source     = "../modules/monitoring/notifications"
  providers  = { oci = oci.home }
  rules = local.home_region_notifications
}
