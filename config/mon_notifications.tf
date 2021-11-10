# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "lz_notifications" {
  depends_on = [null_resource.slow_down_notifications]
  source     = "../modules/monitoring/notifications"
  rules = {
    ("${var.service_label}-notify-on-iam-changes-rule") = {
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
      topic_id            = module.lz_security_topic.topic.id
      defined_tags        = null
    },
    
("${var.service_label}-notify-on-security-changes-rule") = {
      compartment_id      = var.tenancy_ocid
      description         = "Landing Zone events rule to detect when security related resources are created, updated or deleted."
      is_enabled          = true
      condition           = <<EOT
            {"eventType": 
            ["com.oraclecloud.virtualnetwork.changesecuritylistcompartment",
            "com.oraclecloud.virtualnetwork.createsecuritylist",
            "com.oraclecloud.virtualnetwork.deletesecuritylist",
            "com.oraclecloud.virtualnetwork.updatesecuritylist",
            "com.oraclecloud.virtualnetwork.changenetworksecuritygroupcompartment",
            "com.oraclecloud.virtualnetwork.createnetworksecuritygroup",
            "com.oraclecloud.virtualnetwork.deletenetworksecuritygroup",
            "com.oraclecloud.virtualnetwork.updatenetworksecuritygroup"

            ]
            }
            EOT
      actions_action_type = "ONS"
      actions_is_enabled  = true
      actions_description = "Sends notification via ONS"
      topic_id            = module.lz_security_topic.topic.id
      defined_tags        = null
    },

("${var.service_label}-notify-on-storage-changes-rule") = {
      compartment_id      = module.lz_compartments.compartments[local.appdev_compartment.key].id
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
      topic_id            = module.lz_storage_topic.topic.id
      defined_tags        = null
    },

    ("${var.service_label}-notify-on-database-changes-rule") = {
      compartment_id      = module.lz_compartments.compartments[local.database_compartment.key].id
      description         = "Landing Zone events rule to detect when database resources are created, updated or deleted."
      is_enabled          = var.create_events_as_enabled
      condition           = <<EOT
            {"eventType": 
            ["com.oraclecloud.databaseservice.autonomous.database.critical",
             "com.oraclecloud.databaseservice.autonomous.exadata.infrastructure.critical",
             "com.oraclecloud.databaseservice.dbsystem.critical",
             "com.oraclecloud.databaseservice.cloudexadatainfrastructure.critical"
            ]
            }
            EOT
      actions_action_type = "ONS"
      actions_is_enabled  = true
      actions_description = "Sends notification via ONS"
      topic_id            = module.lz_database_topic.topic.id
      defined_tags        = null
    },

    ("${var.service_label}-notify-on-governance-changes-rule") = {
      compartment_id      = module.lz_compartments.compartments[local.security_compartment.key].id
      description         = "Landing Zone events rule to detect when governance resources such as budgets and financial tracking constructs are created, updated or deleted."
      is_enabled          = var.create_events_as_enabled
      condition           = <<EOT
            {"eventType": 
            ["com.oraclecloud.budgets.updatealertrule",
             "com.oraclecloud.budgets.deletealertrule",
             "com.oraclecloud.budgets.updatebudget",
             "com.oraclecloud.budgets.deletebudget",
             "com.oraclecloud.budgets.createtriggeredalert"
            ]
            }
            EOT
      actions_action_type = "ONS"
      actions_is_enabled  = true
      actions_description = "Sends notification via ONS"
      topic_id            = module.lz_governance_topic.topic.id
      defined_tags        = null
    },

    ("${var.service_label}-notify-on-compute-changes-rule") = {
      compartment_id      = module.lz_compartments.compartments[local.appdev_compartment.key].id
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
      topic_id            = module.lz_compute_topic.topic.id
      defined_tags        = null
    },

    ("${var.service_label}-notify-on-network-changes-rule") = {
      compartment_id      = module.lz_compartments.compartments[local.network_compartment.key].id
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
      topic_id            = module.lz_network_topic.topic.id
      defined_tags        = null
    },
  }
}

resource "null_resource" "slow_down_notifications" {
  depends_on = [module.lz_compartments]
  provisioner "local-exec" {
    command = "sleep ${local.delay_in_secs}" # Wait for compartments to be available.
  }
}
