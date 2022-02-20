# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration provisions alarms for the tenancy.

locals {
    all_alarms_defined_tags = {}
    all_alarms_freeform_tags = {}

    # Default alarms names
    compute_high_compute_alarm          = {key:"${var.service_label}-high-cpu-alarm",               name:"${var.service_label}-high-cpu-alarm"}
    compute_instance_status_alarm       = {key:"${var.service_label}-instance-status-alarm",        name:"${var.service_label}-instance-status-alarm"}
    compute_vm_instance_status_alarm    = {key:"${var.service_label}-vm-maintenance-alarm",         name:"${var.service_label}-vm-maintenance-alarm"}
    compute_bare_metal_unhealthy_alarm  = {key:"${var.service_label}-bare-metal-unhealthy-alarm",   name:"${var.service_label}-bare-metal-unhealthy-alarm"}
    compute_high_memory_alarm           = {key:"${var.service_label}-high-memory-alarm",            name:"${var.service_label}-high-memory-alarm"}
    database_adb_cpu_alarm              = {key:"${var.service_label}-adb-cpu-alarm",                name:"${var.service_label}-adb-cpu-alarm"}
    database_adb_storage_alarm          = {key:"${var.service_label}-adb-storage-alarm",            name:"${var.service_label}-adb-storage-alarm"}
    network_vpn_status_alarm            = {key:"${var.service_label}-vpn-status-alarm",             name:"${var.service_label}-vpn-status-alarm"}
    network_fast_connect_status_alarm   = {key:"${var.service_label}-fast-connect-status-alarm",    name:"${var.service_label}-fast-connect-status-alarm"}

    compute_alarms = merge(
        {for i in [1] : (local.compute_high_compute_alarm.key) => {
           compartment_id = local.compute_topic.cmp_id
           destinations = [module.lz_topics.topics[local.compute_topic.key].id]
           display_name = local.compute_high_compute_alarm.name
           defined_tags = local.alarms_defined_tags
           freeform_tags = local.alarms_freeform_tags
           is_enabled = var.create_alarms_as_enabled
           metric_compartment_id = local.compute_topic.cmp_id
           namespace = "oci_computeagent"
           query = "CpuUtilization[1m].mean() > 80"
           severity = "CRITICAL"
           metric_compartment_id_in_subtree = true
           message_format = var.alarm_message_format
           pending_duration = "PT5M"
        } if length(var.compute_admin_email_endpoints) > 0},
        
        {for i in [1] : (local.compute_instance_status_alarm.key) => {
           compartment_id = local.compute_topic.cmp_id
           destinations = [module.lz_topics.topics[local.compute_topic.key].id]
           display_name = local.compute_instance_status_alarm.name
           defined_tags = local.alarms_defined_tags
           freeform_tags = local.alarms_freeform_tags
           is_enabled = var.create_alarms_as_enabled
           metric_compartment_id = local.compute_topic.cmp_id
           namespace = "oci_compute_infrastructure_health"
           query = "instance_status[1m].count() == 1"
           severity = "CRITICAL"
           metric_compartment_id_in_subtree = true
           message_format = var.alarm_message_format
           pending_duration = "PT5M"
        } if length(var.compute_admin_email_endpoints) > 0},

        {for i in [1] :  (local.compute_vm_instance_status_alarm.key) => {
           compartment_id = local.compute_topic.cmp_id
           destinations = [module.lz_topics.topics[local.compute_topic.key].id]
           display_name = local.compute_vm_instance_status_alarm.name
           defined_tags = local.alarms_defined_tags
           freeform_tags = local.alarms_freeform_tags
           is_enabled = var.create_alarms_as_enabled
           metric_compartment_id = local.compute_topic.cmp_id
           namespace = "oci_compute_infrastructure_health"
           query = "maintenance_status[1m].count() == 1"
           severity = "CRITICAL"
           metric_compartment_id_in_subtree = true
           message_format = var.alarm_message_format
           pending_duration = "PT5M"
        } if length(var.compute_admin_email_endpoints) > 0},

        {for i in [1] : (local.compute_bare_metal_unhealthy_alarm.key) => {
           compartment_id = local.compute_topic.cmp_id
           destinations = [module.lz_topics.topics[local.compute_topic.key].id]
           display_name = local.compute_bare_metal_unhealthy_alarm.name
           defined_tags = local.alarms_defined_tags
           freeform_tags = local.alarms_freeform_tags
           is_enabled = var.create_alarms_as_enabled
           metric_compartment_id = local.compute_topic.cmp_id
           namespace = "oci_compute_infrastructure_health"
           query = "health_status[1m].count() == 1"
           severity = "CRITICAL"
           metric_compartment_id_in_subtree = true
           message_format = var.alarm_message_format
           pending_duration = "PT5M"
        } if length(var.compute_admin_email_endpoints) > 0},

        {for i in [1] : (local.compute_high_memory_alarm.key) => {
           compartment_id = local.compute_topic.cmp_id
           destinations = [module.lz_topics.topics[local.compute_topic.key].id]
           display_name = local.compute_high_memory_alarm.name
           defined_tags = local.alarms_defined_tags
           freeform_tags = local.alarms_freeform_tags
           is_enabled = var.create_alarms_as_enabled
           metric_compartment_id = local.compute_topic.cmp_id
           namespace = "oci_computeagent"
           query = "MemoryUtilization[1m].mean() > 80"
           severity = "CRITICAL"
           metric_compartment_id_in_subtree = true
           message_format = var.alarm_message_format
           pending_duration = "PT5M"
        } if length(var.compute_admin_email_endpoints) > 0}
        )

    database_alarms = merge(
        {for i in [1] : (local.database_adb_cpu_alarm.key) => {
           compartment_id = local.database_topic.cmp_id
           destinations = [module.lz_topics.topics[local.database_topic.key].id]
           display_name = local.database_adb_cpu_alarm.name
           defined_tags = local.alarms_defined_tags
           freeform_tags = local.alarms_freeform_tags
           is_enabled = var.create_alarms_as_enabled
           metric_compartment_id = local.database_topic.cmp_id
           namespace = "oci_autonomous_database"
           query = "CpuUtilization[1m].mean() > 80"
           severity = "CRITICAL"
           metric_compartment_id_in_subtree = true
           message_format = var.alarm_message_format
           pending_duration = "PT5M"
        } if length(var.database_admin_email_endpoints) > 0},

        {for i in [1] : (local.database_adb_storage_alarm.key) => {
           compartment_id = local.database_topic.cmp_id
           destinations = [module.lz_topics.topics[local.database_topic.key].id]
           display_name = local.database_adb_storage_alarm.name
           defined_tags = local.alarms_defined_tags
           freeform_tags = local.alarms_freeform_tags
           is_enabled = var.create_alarms_as_enabled
           metric_compartment_id = local.database_topic.cmp_id
           namespace = "oci_autonomous_database"
           query = "StorageUtilization[1m].mean() > 80"
           severity = "CRITICAL"
           metric_compartment_id_in_subtree = true
           message_format = var.alarm_message_format
           pending_duration = "PT5M"
        } if length(var.database_admin_email_endpoints) > 0}
    )

    network_alarms = merge(
        {for i in [1] : (local.network_vpn_status_alarm.key) => {
           compartment_id = local.network_topic.cmp_id
           destinations = [module.lz_topics.topics[local.network_topic.key].id]
           display_name = local.network_vpn_status_alarm.name
           defined_tags = local.alarms_defined_tags
           freeform_tags = local.alarms_freeform_tags
           is_enabled = var.create_alarms_as_enabled
           metric_compartment_id = local.network_topic.cmp_id
           namespace = "oci_vpn"
           query = "TunnelState[1m].mean() == 0"
           severity = "CRITICAL"
           metric_compartment_id_in_subtree = true
           message_format = var.alarm_message_format
           pending_duration = "PT5M"
        } if length(var.network_admin_email_endpoints) > 0},

        {for i in [1] : (local.network_fast_connect_status_alarm.key) => {
           compartment_id = local.network_topic.cmp_id
           destinations = [module.lz_topics.topics[local.network_topic.key].id]
           display_name = local.network_fast_connect_status_alarm.name
           defined_tags = local.alarms_defined_tags
           freeform_tags = local.alarms_freeform_tags
           is_enabled = var.create_alarms_as_enabled
           metric_compartment_id = local.network_topic.cmp_id
           namespace = "oci_fastconnect"
           query = "ConnectionState[1m].mean() == 0"
           severity = "CRITICAL"
           metric_compartment_id_in_subtree = true
           message_format = var.alarm_message_format
           pending_duration = "PT5M"
        } if length(var.network_admin_email_endpoints) > 0}
    )

    ### DON'T TOUCH THESE ###
    default_alarms_defined_tags = null
    default_alarms_freeform_tags = local.landing_zone_tags

    alarms_defined_tags = length(local.all_alarms_defined_tags) > 0 ? local.all_alarms_defined_tags : local.default_alarms_defined_tags
    alarms_freeform_tags = length(local.all_alarms_freeform_tags) > 0 ? merge(local.all_alarms_freeform_tags, local.default_alarms_freeform_tags) : local.default_alarms_freeform_tags

}

# Alarms is a regional service. As such, we must not skip provisioning when extending Landing Zone to a new region.
module "lz_compute_alarms" {
    source    = "../modules/monitoring/alarms"
    depends_on = [ module.lz_subscriptions, module.lz_home_region_subscriptions ]
    alarms =  local.compute_alarms
}

   
module "lz_database_alarms" {
    source    = "../modules/monitoring/alarms"
    depends_on = [ module.lz_subscriptions, module.lz_home_region_subscriptions ]
    alarms = local.database_alarms
}

module "lz_network_alarms" {
    source    = "../modules/monitoring/alarms"
    depends_on = [ module.lz_subscriptions, module.lz_home_region_subscriptions ]
    alarms = local.network_alarms
} 
