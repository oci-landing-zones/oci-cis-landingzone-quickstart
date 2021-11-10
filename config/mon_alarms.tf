# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration provisions alarms for the tenancy.

locals {
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
}

module "lz_compute_alarms" {
    source    = "../modules/monitoring/alarms"
    alarms =  length(var.compute_admin_email_endpoints) > 0 ? {
        (local.compute_high_compute_alarm.key) = {
           compartment_id = module.lz_compartments.compartments[local.appdev_compartment.key].id
           destinations = [module.lz_compute_topic.topic.id]
           display_name = local.compute_high_compute_alarm.name
           is_enabled = var.create_alarms_as_enabled
           metric_compartment_id = module.lz_compartments.compartments[local.appdev_compartment.key].id
           namespace = "oci_computeagent"
           query = "CpuUtilization[1m].mean() > 80"
           severity = "critical"
           metric_compartment_id_in_subtree = true
           message_format = var.alarm_message_format
           pending_duration = "PT5M"
           
        },

       (local.compute_instance_status_alarm.key) = {
           compartment_id = module.lz_compartments.compartments[local.appdev_compartment.key].id
           destinations = [module.lz_compute_topic.topic.id]
           display_name = local.compute_instance_status_alarm.name
           is_enabled = var.create_alarms_as_enabled
           metric_compartment_id = module.lz_compartments.compartments[local.appdev_compartment.key].id
           namespace = "oci_compute_infrastructure_health"
           query = "instance_status[1m].count() == 1"
           severity = "critical"
           metric_compartment_id_in_subtree = true
           message_format = var.alarm_message_format
           pending_duration = "PT5M"
        },

        (local.compute_vm_instance_status_alarm.key) = {
           compartment_id = module.lz_compartments.compartments[local.appdev_compartment.key].id
           destinations = [module.lz_compute_topic.topic.id] 
           display_name = local.compute_vm_instance_status_alarm.name
           is_enabled = var.create_alarms_as_enabled
           metric_compartment_id = module.lz_compartments.compartments[local.appdev_compartment.key].id
           namespace = "oci_compute_infrastructure_health"
           query = "maintenance_status[1m].count() == 1"
           severity = "critical"
           metric_compartment_id_in_subtree = true
           message_format = var.alarm_message_format
           pending_duration = "PT5M"
        },

        (local.compute_bare_metal_unhealthy_alarm.key) = {
           compartment_id = module.lz_compartments.compartments[local.appdev_compartment.key].id
           destinations = [module.lz_compute_topic.topic.id] 
           display_name = local.compute_bare_metal_unhealthy_alarm.name
           is_enabled = var.create_alarms_as_enabled
           metric_compartment_id = module.lz_compartments.compartments[local.appdev_compartment.key].id
           namespace = "oci_compute_infrastructure_health"
           query = "health_status[1m].count() == 1"
           severity = "critical"
           metric_compartment_id_in_subtree = true
           message_format = var.alarm_message_format
           pending_duration = "PT5M"
        },

        (local.compute_high_memory_alarm.key) = {
           compartment_id = module.lz_compartments.compartments[local.appdev_compartment.key].id
           destinations = [module.lz_compute_topic.topic.id] 
           display_name = local.compute_high_memory_alarm.name
           is_enabled = var.create_alarms_as_enabled
           metric_compartment_id = module.lz_compartments.compartments[local.appdev_compartment.key].id
           namespace = "oci_computeagent"
           query = "MemoryUtilization[1m].mean() > 80"
           severity = "critical"
           metric_compartment_id_in_subtree = true
           message_format = var.alarm_message_format
           pending_duration = "PT5M"
        }
    }:{}
}

   
module "lz_database_alarms" {
    source    = "../modules/monitoring/alarms"
    alarms = length(var.database_admin_email_endpoints) > 0 ?  {
        (local.database_adb_cpu_alarm.key) = {
           compartment_id = module.lz_compartments.compartments[local.database_compartment.key].id
           destinations = [module.lz_database_topic.topic.id]
           display_name = local.database_adb_cpu_alarm.name
           is_enabled = var.create_alarms_as_enabled
           metric_compartment_id = module.lz_compartments.compartments[local.database_compartment.key].id
           namespace = "oci_autonomous_database"
           query = "CpuUtilization[1m].mean() > 80"
           severity = "critical"
           metric_compartment_id_in_subtree = true
           message_format = var.alarm_message_format
           pending_duration = "PT5M"
        },

       (local.database_adb_storage_alarm.key) = {
           compartment_id = module.lz_compartments.compartments[local.database_compartment.key].id
           destinations = [module.lz_database_topic.topic.id] 
           display_name = local.database_adb_storage_alarm.name
           is_enabled = var.create_alarms_as_enabled
           metric_compartment_id = module.lz_compartments.compartments[local.database_compartment.key].id
           namespace = "oci_autonomous_database"
           query = "StorageUtilization[1m].mean() > 80"
           severity = "critical"
           metric_compartment_id_in_subtree = true
           message_format = var.alarm_message_format
           pending_duration = "PT5M"
        }
        
    }:{}
}

module "lz_network_alarms" {
    source    = "../modules/monitoring/alarms"
    alarms = length(var.compute_admin_email_endpoints) > 0 ? {
        (local.network_vpn_status_alarm.key) = {
           compartment_id = module.lz_compartments.compartments[local.network_compartment.key].id
           destinations = [module.lz_network_topic.topic.id]  
           display_name = local.network_vpn_status_alarm.name
           is_enabled = var.create_alarms_as_enabled
           metric_compartment_id = module.lz_compartments.compartments[local.network_compartment.key].id
           namespace = "oci_vpn"
           query = "TunnelState[1m].mean() == 0"
           severity = "critical"
           metric_compartment_id_in_subtree = true
           message_format = var.alarm_message_format
           pending_duration = "PT5M"
        },

       (local.network_fast_connect_status_alarm.key) = {
           compartment_id = module.lz_compartments.compartments[local.network_compartment.key].id
           destinations = [module.lz_network_topic.topic.id] 
           display_name = local.network_fast_connect_status_alarm.name
           is_enabled = var.create_alarms_as_enabled
           metric_compartment_id = module.lz_compartments.compartments[local.network_compartment.key].id
           namespace = "oci_fastconnect"
           query = "ConnectionState[1m].mean() == 0"
           severity = "critical"
           metric_compartment_id_in_subtree = true
           message_format = var.alarm_message_format
           pending_duration = "PT5M"
        }
        
    }:{}
} 
