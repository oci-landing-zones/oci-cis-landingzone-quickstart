# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals  {

  all_topics_defined_tags = {}
  all_topics_freeform_tags = {}

  # Topics
  # If you have an existing topic you want to use enter the OCID(s) in the id property.
  security_topic    = {key: "SECURITY-TOPIC",   name: "${var.service_label}-security-topic",   cmp_id: local.security_compartment_id, id: null}
  network_topic     = {key: "NETWORK-TOPIC",    name: "${var.service_label}-network-topic",    cmp_id: local.network_compartment_id,  id: null}
  compute_topic     = {key: "COMPUTE-TOPIC",    name: "${var.service_label}-compute-topic",    cmp_id: local.appdev_compartment_id,   id: null}
  database_topic    = {key: "DATABASE-TOPIC",   name: "${var.service_label}-database-topic",   cmp_id: local.database_compartment_id, id: null}
  storage_topic     = {key: "STORAGE-TOPIC",    name: "${var.service_label}-storage-topic",    cmp_id: local.appdev_compartment_id,   id: null}
  budget_topic      = {key: "BUDGET-TOPIC",     name: "${var.service_label}-budget-topic",     cmp_id: var.tenancy_ocid, id : null }
  exainfra_topic    = {key: "EXAINFRA-TOPIC",   name: "${var.service_label}-exainfra-topic",   cmp_id: local.exainfra_compartment_id, id : null }
  cloudguard_topic  = {key: "CLOUDGUARD-TOPIC", name: "${var.service_label}-cloudguard-topic", cmp_id: local.security_compartment_id, id: null}

  
  home_region_topics = merge(
    {for i in [1] : (local.security_topic.key) => {
      compartment_id = local.security_topic.cmp_id
      name           = local.security_topic.name
      description    = "Landing Zone topic for security related notifications."
      defined_tags   = local.topics_defined_tags
      freeform_tags  = local.topics_freeform_tags
    } if local.security_topic.id == null && length(var.security_admin_email_endpoints) > 0 && var.extend_landing_zone_to_new_region == false
    },
    
    {for i in [1] : (local.cloudguard_topic.key) => {
      compartment_id = local.cloudguard_topic.cmp_id
      name           = local.cloudguard_topic.name
      description    = "Landing Zone topic for Cloud Guard related notifications."
      defined_tags   = local.topics_defined_tags
      freeform_tags  = local.topics_freeform_tags
    } if local.cloudguard_topic.id == null && length(var.cloud_guard_admin_email_endpoints) > 0 && var.extend_landing_zone_to_new_region == false
    }
  )  

  regional_topics = merge(
      {for i in [1] :  (local.network_topic.key) => {
        compartment_id = local.network_topic.cmp_id
        name           = local.network_topic.name
        description    = "Landing Zone topic for network related notifications."
        defined_tags   = local.topics_defined_tags
        freeform_tags  = local.topics_freeform_tags
      } if local.network_topic.id == null && length(var.network_admin_email_endpoints) > 0},

      {for i in [1]: (local.compute_topic.key) => {
        compartment_id = local.compute_topic.cmp_id
        name           = local.compute_topic.name
        description    = "Landing Zone topic for compute performance related notifications."
        defined_tags   = local.topics_defined_tags
        freeform_tags  = local.topics_freeform_tags
      } if local.compute_topic.id == null && length(var.compute_admin_email_endpoints) > 0},

      {for i in [1]: (local.database_topic.key) => {
        compartment_id = local.database_topic.cmp_id
        name           = local.database_topic.name
        description    = "Landing Zone topic for database performance related notifications."
        defined_tags   = local.topics_defined_tags
        freeform_tags  = local.topics_freeform_tags
      } if local.database_topic.id == null && length(var.database_admin_email_endpoints) > 0},
    
      {for i in [1]: (local.storage_topic.key) => {
        compartment_id = local.storage_topic.cmp_id
        name           = local.storage_topic.name
        description    = "Landing Zone topic for storage performance related notifications."
        defined_tags   = local.topics_defined_tags
        freeform_tags  = local.topics_freeform_tags
      } if local.storage_topic.id == null && length(var.storage_admin_email_endpoints) > 0},

      {for i in [1]: (local.budget_topic.key) => {
        compartment_id = var.tenancy_ocid
        name           = local.budget_topic.name
        description    = "Landing Zone topic for budget related notifications."
        defined_tags   = local.topics_defined_tags
        freeform_tags  = local.topics_freeform_tags
      } if length(var.budget_admin_email_endpoints) > 0},

      {for i in [1]: (local.exainfra_topic.key) => {
        compartment_id = local.exainfra_topic.cmp_id
        name           = local.exainfra_topic.name
        description    = "Landing Zone topic for Exadata infrastructure notifications."
        defined_tags   = local.topics_defined_tags
        freeform_tags  = local.topics_freeform_tags
      } if length(var.exainfra_admin_email_endpoints) > 0 && var.deploy_exainfra_cmp == true}
  )  

  ### DON'T TOUCH THESE ###
  default_topics_defined_tags = null
  default_topics_freeform_tags = local.landing_zone_tags

  topics_defined_tags = length(local.all_topics_defined_tags) > 0 ? local.all_topics_defined_tags : local.default_topics_defined_tags
  topics_freeform_tags = length(local.all_topics_freeform_tags) > 0 ? merge(local.all_topics_freeform_tags, local.default_topics_freeform_tags) : local.default_topics_freeform_tags

}

module "lz_home_region_topics" {
  source     = "../modules/monitoring/topics-v2/topics"
  depends_on = [ null_resource.wait_on_compartments ]
  providers  = { oci = oci.home }
  topics     = local.home_region_topics
}

module "lz_topics" {
  source     = "../modules/monitoring/topics-v2/topics"
  depends_on = [ null_resource.wait_on_compartments ]
  topics     = local.regional_topics
}

module "lz_home_region_subscriptions" {
  source        = "../modules/monitoring/topics-v2/subscriptions"
  providers  = { oci = oci.home }  
  subscriptions = merge(
    {   for e in var.security_admin_email_endpoints: "${e}-${local.security_topic.name}" => {
        compartment_id = local.security_topic.cmp_id
        topic_id       = local.security_topic.id != null ? local.security_topic.id : module.lz_home_region_topics.topics[local.security_topic.key].id
        protocol       = "EMAIL" # Other valid protocols: "CUSTOM_HTTPS", "PAGER_DUTY", "SLACK", "ORACLE_FUNCTIONS"
        endpoint       = e       # Protocol matching endpoints: "https://www.oracle.com", "https://your.pagerduty.endpoint.url", "https://your.slack.endpoint.url", "<function_ocid>"
        defined_tags   = local.topics_defined_tags
        freeform_tags  = local.topics_freeform_tags
      } if var.extend_landing_zone_to_new_region == false
    },
    {   for e in var.cloud_guard_admin_email_endpoints: "${e}-${local.cloudguard_topic.name}" => {
        compartment_id = local.security_topic.cmp_id
        topic_id       = local.cloudguard_topic.id != null ? local.cloudguard_topic.id : module.lz_home_region_topics.topics[local.cloudguard_topic.key].id
        protocol       = "EMAIL" # Other valid protocols: "CUSTOM_HTTPS", "PAGER_DUTY", "SLACK", "ORACLE_FUNCTIONS"
        endpoint       = e       # Protocol matching endpoints: "https://www.oracle.com", "https://your.pagerduty.endpoint.url", "https://your.slack.endpoint.url", "<function_ocid>"
        defined_tags   = local.topics_defined_tags
        freeform_tags  = local.topics_freeform_tags
      } if var.extend_landing_zone_to_new_region == false
    }
   )
  }
  

module "lz_subscriptions" {
  source        = "../modules/monitoring/topics-v2/subscriptions"
  subscriptions = merge(
    { for e in var.network_admin_email_endpoints: "${e}-${local.network_topic.name}" => {
        compartment_id = local.network_topic.cmp_id
        topic_id       = local.network_topic.id == null ? module.lz_topics.topics[local.network_topic.key].id : local.network_topic.id
        protocol       = "EMAIL" 
        endpoint       = e
        defined_tags   = local.topics_defined_tags
        freeform_tags  = local.topics_freeform_tags
    }},
    { for e in var.compute_admin_email_endpoints: "${e}-${local.compute_topic.name}" => {
        compartment_id = local.compute_topic.cmp_id
        topic_id = local.compute_topic.id == null ? module.lz_topics.topics[local.compute_topic.key].id : local.compute_topic.id
        protocol = "EMAIL" 
        endpoint = e
        defined_tags = local.topics_defined_tags
        freeform_tags = local.topics_freeform_tags
    }},
    { for e in var.database_admin_email_endpoints: "${e}-${local.database_topic.name}" => {
        compartment_id = local.database_topic.cmp_id
        topic_id = local.database_topic.id == null ? module.lz_topics.topics[local.database_topic.key].id : local.database_topic.id
        protocol = "EMAIL" 
        endpoint = e
        defined_tags = local.topics_defined_tags
        freeform_tags = local.topics_freeform_tags
    }},
    { for e in var.storage_admin_email_endpoints: "${e}-${local.storage_topic.name}" => {
        compartment_id = local.storage_topic.cmp_id
        topic_id = local.storage_topic.id == null ? module.lz_topics.topics[local.storage_topic.key].id : local.storage_topic.id
        protocol = "EMAIL" 
        endpoint = e
        defined_tags = local.topics_defined_tags
        freeform_tags = local.topics_freeform_tags
    }},
    { for e in var.budget_admin_email_endpoints: "${e}-${local.budget_topic.name}" => {
        compartment_id = local.budget_topic.cmp_id
        topic_id = local.budget_topic.id == null ? module.lz_topics.topics[local.budget_topic.key].id : local.budget_topic.id
        protocol = "EMAIL" 
        endpoint = e
        defined_tags = local.topics_defined_tags
        freeform_tags = local.topics_freeform_tags
    }},
    { for e in var.exainfra_admin_email_endpoints: "${e}-${local.exainfra_topic.name}" => {
        compartment_id = local.exainfra_topic.cmp_id
        topic_id = local.exainfra_topic.id == null ? module.lz_topics.topics[local.exainfra_topic.key].id : local.exainfra_topic.id
        protocol = "EMAIL" 
        endpoint = e
        defined_tags = local.topics_defined_tags
        freeform_tags = local.topics_freeform_tags
    } if var.deploy_exainfra_cmp == true}
  )
}
