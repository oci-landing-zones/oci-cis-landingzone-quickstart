# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals  {
  # Topics
  # id is for future use
  security_topic    = {key: "SECURITY-TOPIC",   name: "${var.service_label}-security-topic",   cmp_id: module.lz_compartments.compartments[local.security_compartment.key].id, id : null}
  network_topic     = {key: "NETWORK-TOPIC",    name: "${var.service_label}-network-topic",    cmp_id: module.lz_compartments.compartments[local.network_compartment.key].id, id : null}
  compute_topic     = {key: "COMPUTE-TOPIC",    name: "${var.service_label}-compute-topic",    cmp_id: module.lz_compartments.compartments[local.appdev_compartment.key].id, id : null}
  database_topic    = {key: "DATABASE-TOPIC",   name: "${var.service_label}-database-topic",   cmp_id: module.lz_compartments.compartments[local.database_compartment.key].id, id : null }
  storage_topic     = {key: "STORAGE-TOPIC",    name: "${var.service_label}-storage-topic",    cmp_id: module.lz_compartments.compartments[local.appdev_compartment.key].id, id : null }
  budget_topic      = {key: "BUDGET-TOPIC",     name: "${var.service_label}-budget-topic",     cmp_id: var.tenancy_ocid, id : null }
  exainfra_topic    = {key: "EXAINFRA-TOPIC",   name: "${var.service_label}-exainfra-topic",   cmp_id: var.deploy_exainfra_cmp == true ? module.lz_compartments.compartments[local.exainfra_compartment.key].id : null, id : null }

  home_region_topics = {
    for i in [1] : (local.security_topic.key) => {
      compartment_id = local.security_topic.cmp_id
      name           = local.security_topic.name
      description    = "Landing Zone topic for security related notifications."
      defined_tags   = null
      freeform_tags  = null  
    } #if length(var.security_admin_email_endpoints) > 0 && var.extend_landing_zone_to_new_region == false
  }  

  regional_topics = merge(
      {for i in [1] :  (local.network_topic.key) => {
        compartment_id = local.network_topic.cmp_id
        name           = local.network_topic.name
        description    = "Landing Zone topic for network related notifications."
        defined_tags   = null
        freeform_tags  = null
      } if length(var.network_admin_email_endpoints) > 0},

      {for i in [1]: (local.compute_topic.key) => {
        compartment_id = local.compute_topic.cmp_id
        name           = local.compute_topic.name
        description    = "Landing Zone topic for compute performance related notifications."
        defined_tags   = null
        freeform_tags  = null 
      } if length(var.compute_admin_email_endpoints) > 0},

      {for i in [1]: (local.database_topic.key) => {
        compartment_id = local.database_topic.cmp_id
        name           = local.database_topic.name
        description    = "Landing Zone topic for database performance related notifications."
        defined_tags   = null
        freeform_tags  = null
      } if length(var.database_admin_email_endpoints) > 0},
    
      {for i in [1]: (local.storage_topic.key) => {
        compartment_id = local.storage_topic.cmp_id
        name           = local.storage_topic.name
        description    = "Landing Zone topic for storage performance related notifications."
        defined_tags   = null
        freeform_tags  = null
      } if length(var.storage_admin_email_endpoints) > 0},

      {for i in [1]: (local.budget_topic.key) => {
        compartment_id = var.tenancy_ocid
        name           = local.budget_topic.name
        description    = "Landing Zone topic for budget related notifications."
        defined_tags   = null
        freeform_tags  = null
      } if length(var.budget_admin_email_endpoints) > 0},

      {for i in [1]: (local.exainfra_topic.key) => {
        compartment_id = local.exainfra_topic.cmp_id
        name           = local.exainfra_topic.name
        description    = "Landing Zone topic for Exadata infrastructure notifications."
        defined_tags   = null
        freeform_tags  = null
      } if length(var.exainfra_admin_email_endpoints) > 0 && var.deploy_exainfra_cmp == true}
  )  
}

module "lz_home_region_topics" {
  source     = "../modules/monitoring/topics-v2/topics"
  depends_on = [ null_resource.slow_down_topics ]
  providers  = { oci = oci.home }
  topics     = local.home_region_topics
}

module "lz_topics" {
  source     = "../modules/monitoring/topics-v2/topics"
  depends_on = [ null_resource.slow_down_topics ]
  topics     = local.regional_topics
}

module "lz_home_region_subscriptions" {
  source        = "../modules/monitoring/topics-v2/subscriptions"
  subscriptions = { 
      for e in var.security_admin_email_endpoints: "${e}-${local.security_topic.name}" => {
        compartment_id = local.security_topic.cmp_id
        topic_id       = local.security_topic.id != null ? local.security_topic.id : module.lz_home_region_topics.topics[local.security_topic.key].id
        protocol       = "EMAIL" # Other valid protocols: "CUSTOM_HTTPS", "PAGER_DUTY", "SLACK", "ORACLE_FUNCTIONS"
        endpoint       = e       # Protocol matching endpoints: "https://www.oracle.com", "https://your.pagerduty.endpoint.url", "https://your.slack.endpoint.url", "<function_ocid>"
        defined_tags   = null
        freeform_tags  = null
      } # if var.extend_landing_zone_to_new_region == false
    }
}

module "lz_subscriptions" {
  source        = "../modules/monitoring/topics-v2/subscriptions"
  subscriptions = merge(
    { for e in var.network_admin_email_endpoints: "${e}-${local.network_topic.name}" => {
        compartment_id = local.network_topic.cmp_id
        topic_id       = local.network_topic.id == null ? module.lz_topics.topics[local.network_topic.key].id : local.network_topic.id
        protocol       = "EMAIL" 
        endpoint       = e
        defined_tags   = null
        freeform_tags  = null
    }},
    { for e in var.compute_admin_email_endpoints: "${e}-${local.compute_topic.name}" => {
        compartment_id = local.compute_topic.cmp_id
        topic_id = local.compute_topic.id == null ? module.lz_topics.topics[local.compute_topic.key].id : local.compute_topic.id
        protocol = "EMAIL" 
        endpoint = e
        defined_tags  = null
        freeform_tags = null
    }},
    { for e in var.database_admin_email_endpoints: "${e}-${local.database_topic.name}" => {
        compartment_id = local.database_topic.cmp_id
        topic_id = local.database_topic.id == null ? module.lz_topics.topics[local.database_topic.key].id : local.database_topic.id
        protocol = "EMAIL" 
        endpoint = e
        defined_tags  = null
        freeform_tags = null
    }},
    { for e in var.storage_admin_email_endpoints: "${e}-${local.storage_topic.name}" => {
        compartment_id = local.storage_topic.cmp_id
        topic_id = local.storage_topic.id == null ? module.lz_topics.topics[local.storage_topic.key].id : local.storage_topic.id
        protocol = "EMAIL" 
        endpoint = e
        defined_tags  = null
        freeform_tags = null
    }},
    { for e in var.budget_admin_email_endpoints: "${e}-${local.budget_topic.name}" => {
        compartment_id = local.budget_topic.cmp_id
        topic_id = local.budget_topic.id == null ? module.lz_topics.topics[local.budget_topic.key].id : local.budget_topic.id
        protocol = "EMAIL" 
        endpoint = e
        defined_tags  = null
        freeform_tags = null
    }},
    { for e in var.exainfra_admin_email_endpoints: "${e}-${local.exainfra_topic.name}" => {
        compartment_id = local.exainfra_topic.cmp_id
        topic_id = local.exainfra_topic.id == null ? module.lz_topics.topics[local.exainfra_topic.key].id : local.exainfra_topic.id
        protocol = "EMAIL" 
        endpoint = e
        defined_tags  = null
        freeform_tags = null
    } if var.deploy_exainfra_cmp == true}
  )
}

resource "null_resource" "slow_down_topics" {
   depends_on = [ module.lz_compartments ]
   provisioner "local-exec" {
     command = "sleep ${local.delay_in_secs}" # Wait for compartments to be available.
   }
}