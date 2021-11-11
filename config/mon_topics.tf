# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals  {
  #If you have an existing topic you want to use enter the OCID(s) below
  security_topic_id   = ""
  network_topic_id    = ""
  compute_topic_id    = "s"
  database_topic_id   = "s"
  storage_topic_id    = ""
  governance_topic_id = ""

  # Topic Names
  security_topic_name = "${var.service_label}-security-topic"
  network_topic_name  = "${var.service_label}-network-topic"
  compute_topic_name  = "${var.service_label}-compute-topic"
  database_topic_name  = "${var.service_label}-database-topic"
  storage_topic_name  = "${var.service_label}-storage-topic"
  governance_topic_name  = "${var.service_label}-governance-topic"

  topics = {
  (local.security_topic_name) = local.security_topic_id == "" ? { 
      compartment_id                 = module.lz_compartments.compartments[local.security_compartment.key].id
      notification_topic_name        = local.security_topic_name
      notification_topic_description = "Landing Zone topic for security related notifications."
      defined_tags                   = null
      freeform_tags                  = null
  } : {},
  (local.network_topic_name) = local.network_topic_id == "" ? {
      compartment_id                 = module.lz_compartments.compartments[local.network_compartment.key].id
      notification_topic_name        = local.network_topic_name
      notification_topic_description = "Landing Zone topic for network related notifications."
      defined_tags                   = null
      freeform_tags                  = null
  } : {},
  (local.compute_topic_name) = local.compute_topic_id == "" ? {
      compartment_id                 = module.lz_compartments.compartments[local.appdev_compartment.key].id
      notification_topic_name        = local.compute_topic_name
      notification_topic_description = "Landing Zone topic for compute performance related notifications."
      defined_tags                   = null
      freeform_tags                  = null
  } : {},
  (local.database_topic_name) = local.database_topic_id == "" ? {
      compartment_id                 = module.lz_compartments.compartments[local.database_compartment.key].id
      notification_topic_name        = local.database_topic_name
      notification_topic_description = "Landing Zone topic for database performance related notifications."
      defined_tags                   = null
      freeform_tags                  = null
  } : {},
  (local.storage_topic_name)  = local.storage_topic_id == "" ? {
      compartment_id                 = module.lz_compartments.compartments[local.appdev_compartment.key].id
      notification_topic_name        = local.storage_topic_name
      notification_topic_description = "Landing Zone topic for storage performance related notifications."
      defined_tags                   = null
      freeform_tags                  = null
  } : {}, 
  (local.governance_topic_name) = local.governance_topic_id == "" ? {
      compartment_id                 = module.lz_compartments.compartments[local.security_compartment.key].id
      notification_topic_name        = local.governance_topic_name
      notification_topic_description = "Landing Zone topic for governance related notifications."
      defined_tags                   = null
      freeform_tags                  = null
  } : {}
  }


}
  




module "lz_topics" {
  source                          = "../modules/monitoring/topics-v2/topics"
  depends_on                      = [ null_resource.slow_down_topics ]
  topics = {
  (local.security_topic_name) = local.security_topic_id == "" ? { 
      compartment_id                 = module.lz_compartments.compartments[local.security_compartment.key].id
      notification_topic_name        = local.security_topic_name
      notification_topic_description = "Landing Zone topic for security related notifications."
      defined_tags                   = null
      freeform_tags                  = null
  } : {},
  (local.network_topic_name) = local.network_topic_id == "" ? {
      compartment_id                 = module.lz_compartments.compartments[local.network_compartment.key].id
      notification_topic_name        = local.network_topic_name
      notification_topic_description = "Landing Zone topic for network related notifications."
      defined_tags                   = null
      freeform_tags                  = null
  } : {},
  (local.compute_topic_name) = local.compute_topic_id == "" && len(var.compute_admin_email_endpoints) > 0 ? {
      compartment_id                 = module.lz_compartments.compartments[local.appdev_compartment.key].id
      notification_topic_name        = local.compute_topic_name
      notification_topic_description = "Landing Zone topic for compute performance related notifications."
      defined_tags                   = null
      freeform_tags                  = null
  } : {},
  (local.database_topic_name) = local.database_topic_id == "" ? {
      compartment_id                 = module.lz_compartments.compartments[local.database_compartment.key].id
      notification_topic_name        = local.database_topic_name
      notification_topic_description = "Landing Zone topic for database performance related notifications."
      defined_tags                   = null
      freeform_tags                  = null
  } : {},
  (local.storage_topic_name)  = local.storage_topic_id == "" ? {
      compartment_id                 = module.lz_compartments.compartments[local.appdev_compartment.key].id
      notification_topic_name        = local.storage_topic_name
      notification_topic_description = "Landing Zone topic for storage performance related notifications."
      defined_tags                   = null
      freeform_tags                  = null
  } : {}, 
  (local.governance_topic_name) = local.governance_topic_id == "" ? {
      compartment_id                 = module.lz_compartments.compartments[local.security_compartment.key].id
      notification_topic_name        = local.governance_topic_name
      notification_topic_description = "Landing Zone topic for governance related notifications."
      defined_tags                   = null
      freeform_tags                  = null
  } : {}
  }
}

module "lz_subscriptions" {
  source                         = "../modules/monitoring/topics-v2/subscriptions"
  depends_on                     = [ module.lz_topics ]
  subscriptions = merge(
    { for e in var.security_admin_email_endpoints: e => {
        topic_id = local.security_topic_id != "" ? local.security_topic_id : module.lz_topics[local.security_topic_name].id,
        protocol      = "EMAIL", 
        endpoint      = e
        defined_tags  = {}
        freeform_tags = {}
        }
    /* 
    {protocol = "CUSTOM_HTTPS", endpoint = "https://www.oracle.com"},
    {protocol = "CUSTOM_HTTPS", endpoint = "https://www.google.com"}
    {protocol = "PAGER_DUTY", endpoint = "https://your.pagerduty.endpoint.url"}
    {protocol = "SLACK", endpoint = "https://your.slack.endpoint.url"}
    {protocol = "ORACLE_FUNCTIONS", endpoint = "<function_ocid>"} 
    */
    },
  { for e in var.network_admin_email_endpoints: e => {
    topic_id = local.network_topic_id != "" ? local.network_topic_id : module.lz_topics[local.network_topic_name].id,
    protocol = "EMAIL", 
    endpoint = e,
    defined_tags  = {},
    freeform_tags = {}
    }

    ### Examples of other subscription methods:
    /* 
    {protocol = "CUSTOM_HTTPS", endpoint = "https://www.oracle.com"},
    {protocol = "CUSTOM_HTTPS", endpoint = "https://www.google.com"}
    {protocol = "PAGER_DUTY", endpoint = "https://your.pagerduty.endpoint.url"}
    {protocol = "SLACK", endpoint = "https://your.slack.endpoint.url"}
    {protocol = "ORACLE_FUNCTIONS", endpoint = "<function_ocid>"} 
    */
  },
  
 { for e in var.compute_admin_email_endpoints: e => {
    topic_id = local.compute_topic_id != "" ? local.compute_topic_id : module.lz_topics[local.compute_topic_name].id,
    protocol = "EMAIL", 
    endpoint = e,
    defined_tags  = {},
    freeform_tags = {}
    }

    ### Examples of other subscription methods:
    /* 
    {protocol = "CUSTOM_HTTPS", endpoint = "https://www.oracle.com"},
    {protocol = "CUSTOM_HTTPS", endpoint = "https://www.google.com"}
    {protocol = "PAGER_DUTY", endpoint = "https://your.pagerduty.endpoint.url"}
    {protocol = "SLACK", endpoint = "https://your.slack.endpoint.url"}
    {protocol = "ORACLE_FUNCTIONS", endpoint = "<function_ocid>"} 
    */
  },

  { for e in var.database_admin_email_endpoints: e => {
    topic_id = local.database_topic_id != "" ? local.database_topic_id : module.lz_topics[local.database_topic_name].id,
    protocol = "EMAIL", 
    endpoint = e,
    defined_tags  = {},
    freeform_tags = {}
    }

    ### Examples of other subscription methods:
    /* 
    {protocol = "CUSTOM_HTTPS", endpoint = "https://www.oracle.com"},
    {protocol = "CUSTOM_HTTPS", endpoint = "https://www.google.com"}
    {protocol = "PAGER_DUTY", endpoint = "https://your.pagerduty.endpoint.url"}
    {protocol = "SLACK", endpoint = "https://your.slack.endpoint.url"}
    {protocol = "ORACLE_FUNCTIONS", endpoint = "<function_ocid>"} 
    */
  },
  { for e in var.storage_admin_email_endpoints: e => {
    topic_id = local.storage_topic_id != "" ? local.storage_topic_id : module.lz_topics[local.security_topic_name].id,
    protocol = "EMAIL", 
    endpoint = e,
    defined_tags  = {},
    freeform_tags = {}
    }

    ### Examples of other subscription methods:
    /* 
    {protocol = "CUSTOM_HTTPS", endpoint = "https://www.oracle.com"},
    {protocol = "CUSTOM_HTTPS", endpoint = "https://www.google.com"}
    {protocol = "PAGER_DUTY", endpoint = "https://your.pagerduty.endpoint.url"}
    {protocol = "SLACK", endpoint = "https://your.slack.endpoint.url"}
    {protocol = "ORACLE_FUNCTIONS", endpoint = "<function_ocid>"} 
    */
  },
  { for e in var.governance_admin_email_endpoints: e => {
    topic_id = local.governance_topic_id != "" ? local.governance_topic_id : module.lz_topics[local.governance_topic_name].id,
    protocol = "EMAIL", 
    endpoint = e,
    defined_tags  = {},
    freeform_tags = {}
    }

    ### Examples of other subscription methods:
    /* 
    {protocol = "CUSTOM_HTTPS", endpoint = "https://www.oracle.com"},
    {protocol = "CUSTOM_HTTPS", endpoint = "https://www.google.com"}
    {protocol = "PAGER_DUTY", endpoint = "https://your.pagerduty.endpoint.url"}
    {protocol = "SLACK", endpoint = "https://your.slack.endpoint.url"}
    {protocol = "ORACLE_FUNCTIONS", endpoint = "<function_ocid>"} 
    */
  }
  )
}
  


# module "lz_security_topic" {
#   source                         = "../modules/monitoring/topics"
#   depends_on                     = [ null_resource.slow_down_topics ]
#   compartment_id                 = module.lz_compartments.compartments[local.security_compartment.key].id
#   notification_topic_name        = "${var.service_label}-security-topic"
#   notification_topic_description = "Landing Zone topic for security related notifications."
#   subscriptions = { for e in var.security_admin_email_endpoints: e => {protocol = "EMAIL", endpoint = e}
    
#     ### Examples of other subscription methods:
#     /* 
#     {protocol = "CUSTOM_HTTPS", endpoint = "https://www.oracle.com"},
#     {protocol = "CUSTOM_HTTPS", endpoint = "https://www.google.com"}
#     {protocol = "PAGER_DUTY", endpoint = "https://your.pagerduty.endpoint.url"}
#     {protocol = "SLACK", endpoint = "https://your.slack.endpoint.url"}
#     {protocol = "ORACLE_FUNCTIONS", endpoint = "<function_ocid>"} 
#     */
#   }
# }

# module "lz_compute_topic" {
#   source                         = "../modules/monitoring/topics-v2"
#   depends_on                     = [ null_resource.slow_down_topics ]
#   topics = ("security" = { compartment_id                 = module.lz_compartments.compartments[local.appdev_compartment.key].id,
#           notification_topic_name        = "${var.service_label}-compute-topic",
#              })
#   subscriptions = { for e in var.compute_admin_email_endpoints: e => {protocol = "EMAIL", endpoint = e}
    
#     ### Examples of other subscription methods:
#     /* 
#     {protocol = "CUSTOM_HTTPS", endpoint = "https://www.oracle.com"},
#     {protocol = "CUSTOM_HTTPS", endpoint = "https://www.google.com"}
#     {protocol = "PAGER_DUTY", endpoint = "https://your.pagerduty.endpoint.url"}
#     {protocol = "SLACK", endpoint = "https://your.slack.endpoint.url"}
#     {protocol = "ORACLE_FUNCTIONS", endpoint = "<function_ocid>"} 
#     */
#   }
# }

# module "lz_database_topic" {
#   source                         = "../modules/monitoring/topics"
#   depends_on                     = [ null_resource.slow_down_topics ]
#   compartment_id                 = module.lz_compartments.compartments[local.database_compartment.key].id
#   notification_topic_name        = "${var.service_label}-database-topic"
#   notification_topic_description = "Landing Zone topic for database performance related notifications."
#   subscriptions = { for e in var.database_admin_email_endpoints: e => {protocol = "EMAIL", endpoint = e}
    
#     ### Examples of other subscription methods:
#     /* 
#     {protocol = "CUSTOM_HTTPS", endpoint = "https://www.oracle.com"},
#     {protocol = "CUSTOM_HTTPS", endpoint = "https://www.google.com"}
#     {protocol = "PAGER_DUTY", endpoint = "https://your.pagerduty.endpoint.url"}
#     {protocol = "SLACK", endpoint = "https://your.slack.endpoint.url"}
#     {protocol = "ORACLE_FUNCTIONS", endpoint = "<function_ocid>"} 
#     */
#   }
# }

# module "lz_storage_topic" {
#   source                         = "../modules/monitoring/topics"
#   depends_on                     = [ null_resource.slow_down_topics ]
#   compartment_id                 = module.lz_compartments.compartments[local.appdev_compartment.key].id
#   notification_topic_name        = "${var.service_label}-storage-topic"
#   notification_topic_description = "Landing Zone topic for storage performance related notifications."
#   subscriptions = { for e in var.storage_admin_email_endpoints: e => {protocol = "EMAIL", endpoint = e}
    
#     ### Examples of other subscription methods:
#     /* 
#     {protocol = "CUSTOM_HTTPS", endpoint = "https://www.oracle.com"},
#     {protocol = "CUSTOM_HTTPS", endpoint = "https://www.google.com"}
#     {protocol = "PAGER_DUTY", endpoint = "https://your.pagerduty.endpoint.url"}
#     {protocol = "SLACK", endpoint = "https://your.slack.endpoint.url"}
#     {protocol = "ORACLE_FUNCTIONS", endpoint = "<function_ocid>"} 
#     */
#   }
# }

# module "lz_governance_topic" {
#   source                         = "../modules/monitoring/topics"
#   depends_on                     = [ null_resource.slow_down_topics ]
#   compartment_id                 = module.lz_compartments.compartments[local.security_compartment.key].id
#   notification_topic_name        = "${var.service_label}-governance-topic"
#   notification_topic_description = "Landing Zone topic for governance related notifications."
#   subscriptions = { for e in var.governance_admin_email_endpoints: e => {protocol = "EMAIL", endpoint = e}
    
#     ### Examples of other subscription methods:
#     /* 
#     {protocol = "CUSTOM_HTTPS", endpoint = "https://www.oracle.com"},
#     {protocol = "CUSTOM_HTTPS", endpoint = "https://www.google.com"}
#     {protocol = "PAGER_DUTY", endpoint = "https://your.pagerduty.endpoint.url"}
#     {protocol = "SLACK", endpoint = "https://your.slack.endpoint.url"}
#     {protocol = "ORACLE_FUNCTIONS", endpoint = "<function_ocid>"} 
#     */
#   }
# }

# module "lz_network_topic" {
#   source                         = "../modules/monitoring/topics"
#   depends_on                     = [ null_resource.slow_down_topics ]
#   compartment_id                 = module.lz_compartments.compartments[local.network_compartment.key].id
#   notification_topic_name        = "${var.service_label}-network-topic"
#   notification_topic_description = "Landing Zone topic for network related notifications."

#   subscriptions = { for e in var.network_admin_email_endpoints: e => {protocol = "EMAIL", endpoint = e}

#     ### Examples of other subscription methods:
#     /* 
#     {protocol = "CUSTOM_HTTPS", endpoint = "https://www.oracle.com"},
#     {protocol = "CUSTOM_HTTPS", endpoint = "https://www.google.com"}
#     {protocol = "PAGER_DUTY", endpoint = "https://your.pagerduty.endpoint.url"}
#     {protocol = "SLACK", endpoint = "https://your.slack.endpoint.url"}
#     {protocol = "ORACLE_FUNCTIONS", endpoint = "<function_ocid>"} 
#     */
#   }
# }

resource "null_resource" "slow_down_topics" {
   depends_on = [ module.lz_compartments ]
   provisioner "local-exec" {
     command = "sleep ${local.delay_in_secs}" # Wait for compartments to be available.
   }
}