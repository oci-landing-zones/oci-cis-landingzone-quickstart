# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

#--------------------------------------------------------------------------------------------------------------
# The compartments variable defines a Terraform object describing a compartments topology with divisions (HR),
# lifecycle environments (DEV, PROD) and workloads (WORKLOAD-1, WORKLOAD-2).
# This object is passed into a generic Terraform module that creates any compartments topology in OCI.
# The object defines sub-objects indexed by uppercased strings, like SHARED-CMP, HR-CMP, DEV-CMP, etc.
# These strings can actually be any random strings, but once defined they MUST NOT BE CHANGED, 
# or Terraform will try to destroy and recreate the compartments.
#---------------------------------------------------------------------------------------------------------------


# ------------------------------------------------------
# ----- General
# ------------------------------------------------------

parent_compartment_id = "ocid1.compartment.oc1..aaaaaaaaazpbxtunsnblbdefwuxnmu5z7t7wgrfn4fp74g7ymfhfvnthf3ia" # Required
create_database_compartment = true
landing_zone_prefix = "iss216"
workload_compartment_user_group_name = "iss216-appdev-admin-group"
database_workload_compartment_user_group_name = "iss216-database-admin-group"
# compartments = {
#   WORKLOAD-CMP : {
#     # name : var.workload_compartment_name,
#     description : "Application Workload compartment",
#     #parent_id : "<ENTER THE OCID OF THE PARENT COMPARTMENT>", 
#     # parent_id : var.parent_compartment_id,
#     defined_tags : null,
#     freeform_tags : { "cislz" : "workload-example",
#       "cislz-cmp-type" : "network,security",
#       "cislz-consumer-groups-network" : "shared-net-admin-group",
#       "cislz-consumer-groups-security" : "shared-sec-admin-group",
#       "cislz-consumer-groups-application" : "hr-dev-app-admin-group,hr-prd-app-admin-group",
#     "cislz-consumer-groups-database" : "hr-dev-db-admin-group,hr-prd-db-admin-group" },
#     children : {}
#   }
# }
#   { for i in [1] : WORKLOAD-DB-CMP => {
#     name : var.database_compartment_name,
#     description : "Application Workload Database compartment",
#     #parent_id : "<ENTER THE OCID OF THE PARENT COMPARTMENT>", 
#     parent_id : var.parent_compartment_id,
#     defined_tags : null,
#     freeform_tags : { "cislz" : "workload-example",
#       "cislz-cmp-type" : "network,security",
#       "cislz-consumer-groups-network" : "shared-net-admin-group",
#       "cislz-consumer-groups-security" : "shared-sec-admin-group",
#       "cislz-consumer-groups-application" : "hr-dev-app-admin-group,hr-prd-app-admin-group",
#     "cislz-consumer-groups-database" : "hr-dev-db-admin-group,hr-prd-db-admin-group" },
#     children : {}
#     } if var.create_database_compartment
# })


#    {for i in [1] :     (local.notify_on_iam_changes_rule.key) => {
#       compartment_id      = var.tenancy_ocid
#       description         = "Landing Zone CIS related events rule to detect when IAM resources are created, updated or deleted."
#       is_enabled          = true
#       actions_action_type = "ONS"
#       actions_is_enabled  = true
#       actions_description = "Sends notification via ONS"
#       topic_id            = local.security_topic.id != null ? local.security_topic.id : module.lz_home_region_topics.topics[local.security_topic.key].id
#       defined_tags        = local.notifications_defined_tags
#       freeform_tags       = local.notifications_freeform_tags
#     } if var.extend_landing_zone_to_new_region == false
#    },

