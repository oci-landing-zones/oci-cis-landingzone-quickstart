# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "lz_notifications" {
  source = "../modules/monitoring/notifications"
  rules = {
    ("${var.service_label}-notify-on-idp-changes") = {
      compartment_id      = var.tenancy_ocid
      description         = "Sends notification when Identity Providers are created, updated or deleted."
      is_enabled          = true
      condition           = <<EOT
            {"eventType": 
              ["com.oraclecloud.identitycontrolplane.createidentityprovider",
              "com.oraclecloud.identitycontrolplane.deleteidentityprovider",
              "com.oraclecloud.identitycontrolplane.updateidentityprovider"]
            }
            EOT
      actions_action_type = "ONS"
      actions_is_enabled  = true
      actions_description = "Sends notification via ONS"
      topic_id            = module.lz_security_topic.topic.id
      defined_tags        = null
    },
    ("${var.service_label}-notify-on-idp-group-mapping-changes") = {
      compartment_id      = var.tenancy_ocid
      description         = "Sends notification when Identity Provider Group Mappings are created, updated or deleted."
      is_enabled          = true
      condition           = <<EOT
        {"eventType": 
          ["com.oraclecloud.identitycontrolplane.createidpgroupmapping",
          "com.oraclecloud.identitycontrolplane.deleteidpgroupmapping",
          "com.oraclecloud.identitycontrolplane.updateidpgroupmapping"]
        }
        EOT
      actions_action_type = "ONS"
      actions_is_enabled  = true
      actions_description = "Sends notification via ONS"
      topic_id            = module.lz_security_topic.topic.id
      defined_tags        = null
    },
    ("${var.service_label}-notify-on-iam-group-changes") = {
      compartment_id      = var.tenancy_ocid
      description         = "Sends notification when IAM groups are created, updated or deleted."
      is_enabled          = true
      condition           = <<EOT
        {"eventType": 
          ["com.oraclecloud.identitycontrolplane.addusertogroup",
          "com.oraclecloud.identitycontrolplane.creategroup",
          "com.oraclecloud.identitycontrolplane.deletegroup",
          "com.oraclecloud.identitycontrolplane.removeuserfromgroup",
          "com.oraclecloud.identitycontrolplane.updategroup"]
        }
        EOT
      actions_action_type = "ONS"
      actions_is_enabled  = true
      actions_description = "Sends notification via ONS"
      topic_id            = module.lz_security_topic.topic.id
      defined_tags        = null
    },
    ("${var.service_label}-notify-on-iam-policy-changes") = {
      compartment_id      = var.tenancy_ocid
      description         = "Sends notification when IAM policies are created, updated or deleted."
      is_enabled          = true
      condition           = <<EOT
        {"eventType":
          ["com.oraclecloud.identitycontrolplane.createpolicy",
          "com.oraclecloud.identitycontrolplane.deletepolicy",
          "com.oraclecloud.identitycontrolplane.updatepolicy"]
        }
        EOT
      actions_action_type = "ONS"
      actions_is_enabled  = true
      actions_description = "Sends notification via ONS"
      topic_id            = module.lz_security_topic.topic.id
      defined_tags        = null
    },
    ("${var.service_label}-notify-on-iam-user-changes") = {
      compartment_id      = var.tenancy_ocid
      description         = "Sends notification when IAM users are created, updated or deleted."
      is_enabled          = true
      condition           = <<EOT
        {"eventType":
          ["com.oraclecloud.identitycontrolplane.createuser",
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
    ("${var.service_label}-notify-on-vcn-changes") = {
      compartment_id      = local.parent_compartment_id
      description         = "Sends notification when VCNs are created, updated or deleted."
      is_enabled          = true
      condition           = <<EOT
        {"eventType":
          ["com.oraclecloud.virtualnetwork.createvcn",
          "com.oraclecloud.virtualnetwork.deletevcn",
          "com.oraclecloud.virtualnetwork.updatevcn"]
        }
        EOT
      actions_action_type = "ONS"
      actions_is_enabled  = true
      actions_description = "Sends notification via ONS"
      topic_id            = module.lz_network_topic.topic.id
      defined_tags        = null
    },
    ("${var.service_label}-notify-on-route-table-changes") = {
      compartment_id      = local.parent_compartment_id
      description         = "Sends notification when route tables are created, updated, deleted or moved."
      is_enabled          = true
      condition           = <<EOT
        {"eventType":
          ["com.oraclecloud.virtualnetwork.createroutetable",
          "com.oraclecloud.virtualnetwork.deleteroutetable",
          "com.oraclecloud.virtualnetwork.updateroutetable",
          "com.oraclecloud.virtualnetwork.changeroutetablecompartment"]
        }
        EOT
      actions_action_type = "ONS"
      actions_is_enabled  = true
      actions_description = "Sends notification via ONS"
      topic_id            = module.lz_network_topic.topic.id
      defined_tags        = null
    },
    ("${var.service_label}-notify-on-security-list-changes") = {
      compartment_id      = local.parent_compartment_id
      display_name        = "${var.service_label}-notify-on-security-list-changes"
      description         = "Sends notification when security lists are created, updated, deleted, or moved."
      is_enabled          = true
      condition           = <<EOT
        {"eventType":
          ["com.oraclecloud.virtualnetwork.createsecuritylist",
          "com.oraclecloud.virtualnetwork.deletesecuritylist",
          "com.oraclecloud.virtualnetwork.updatesecuritylist",
          "com.oraclecloud.virtualnetwork.changesecuritylistcompartment"]
        }
        EOT
      actions_action_type = "ONS"
      actions_is_enabled  = true
      actions_description = "Sends notification via ONS"
      topic_id            = module.lz_network_topic.topic.id
      defined_tags        = null
    },
    ("${var.service_label}-notify-on-nsg-changes") = {
      compartment_id      = local.parent_compartment_id
      description         = "Sends notification when network security groups are created, updated, deleted, or moved."
      is_enabled          = true
      condition           = <<EOT
        {"eventType":
          ["com.oraclecloud.virtualnetwork.createnetworksecuritygroup",
          "com.oraclecloud.virtualnetwork.deletenetworksecuritygroup",
          "com.oraclecloud.virtualnetwork.updatenetworksecuritygroup",
          "com.oraclecloud.virtualnetwork.updatenetworksecuritygroupsecurityrules",
          "com.oraclecloud.virtualnetwork.changenetworksecuritygroupcompartment"]
        }
        EOT
      actions_action_type = "ONS"
      actions_is_enabled  = true
      actions_description = "Sends notification via ONS"
      topic_id            = module.lz_network_topic.topic.id
      defined_tags        = null
    },
    ("${var.service_label}-notify-on-network-gateways-changes") = {
      compartment_id      = local.parent_compartment_id
      description         = "Sends notification when network gateways are created, updated, deleted, attached, detached, or moved."
      is_enabled          = true
      condition           = <<EOT
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
      actions_action_type = "ONS"
      actions_is_enabled  = true
      actions_description = "Sends notification via ONS"
      topic_id            = module.lz_network_topic.topic.id
      defined_tags        = null
    }
  }
}