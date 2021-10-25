# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration provisions alarms for the tenancy.

module "lz_compute_alarms" {
    source    = "../modules/monitoring/alarms"
    alarms = {
        ("${var.service_label}-high-cpu-alarm") = {
           compartment_id = module.lz_compartments.compartments[local.appdev_compartment.key].id
           destinations = [module.lz_compute_topic.topic.id]
           display_name = "${var.service_label}-high-cpu-alarm"
           is_enabled = var.create_alarms_as_enabled
           metric_compartment_id = module.lz_compartments.compartments[local.appdev_compartment.key].id
           namespace = "oci_computeagent"
           query = "CpuUtilization[1m].mean() > 80"
           severity = "critical"
           metric_compartment_id_in_subtree = true
           message_format = "PRETTY_JSON"
           pending_duration = "PT5M"
           
        },

       ("${var.service_label}-instance-status-alarm") = {
           compartment_id = module.lz_compartments.compartments[local.appdev_compartment.key].id
           destinations = [module.lz_compute_topic.topic.id]
           display_name = "${var.service_label}-instance-status-alarm"
           is_enabled = var.create_alarms_as_enabled
           metric_compartment_id = module.lz_compartments.compartments[local.appdev_compartment.key].id
           namespace = "oci_compute_infrastructure_health"
           query = "instance_status[1m].count() == 1"
           severity = "critical"
           metric_compartment_id_in_subtree = true
           message_format = "PRETTY_JSON"
           pending_duration = "PT5M"
        },

        ("${var.service_label}-vm-maintenance-alarm") = {
           compartment_id = module.lz_compartments.compartments[local.appdev_compartment.key].id
           destinations = [module.lz_compute_topic.topic.id] 
           display_name = "${var.service_label}-vm-maintenance-alarm"
           is_enabled = var.create_alarms_as_enabled
           metric_compartment_id = module.lz_compartments.compartments[local.appdev_compartment.key].id
           namespace = "oci_compute_infrastructure_health"
           query = "maintenance_status[1m].count() == 1"
           severity = "critical"
           metric_compartment_id_in_subtree = true
           message_format = "PRETTY_JSON"
           pending_duration = "PT5M"
        },

        ("${var.service_label}-bare-metal-unhealthy-alarm") = {
           compartment_id = module.lz_compartments.compartments[local.appdev_compartment.key].id
           destinations = [module.lz_compute_topic.topic.id] 
           display_name = "${var.service_label}-bare-metal-unhealthy-alarm"
           is_enabled = var.create_alarms_as_enabled
           metric_compartment_id = module.lz_compartments.compartments[local.appdev_compartment.key].id
           namespace = "oci_compute_infrastructure_health"
           query = "health_status[1m].count() == 1"
           severity = "critical"
           metric_compartment_id_in_subtree = true
           message_format = "PRETTY_JSON"
           pending_duration = "PT5M"
        },

        ("${var.service_label}-high-memory-alarm") = {
           compartment_id = module.lz_compartments.compartments[local.appdev_compartment.key].id
           destinations = [module.lz_compute_topic.topic.id] 
           display_name = "${var.service_label}-high-memory-alarm"
           is_enabled = var.create_alarms_as_enabled
           metric_compartment_id = module.lz_compartments.compartments[local.appdev_compartment.key].id
           namespace = "oci_computeagent"
           query = "MemoryUtilization[1m].mean() > 80"
           severity = "critical"
           metric_compartment_id_in_subtree = true
           message_format = "PRETTY_JSON"
           pending_duration = "PT5M"
        }
    }
}

   
module "lz_database_alarms" {
    source    = "../modules/monitoring/alarms"
    alarms = {
        ("${var.service_label}-adb-cpu-alarm") = {
           compartment_id = module.lz_compartments.compartments[local.database_compartment.key].id
           destinations = [module.lz_database_topic.topic.id]
           display_name = "${var.service_label}-adb-cpu-alarm"
           is_enabled = var.create_alarms_as_enabled
           metric_compartment_id = module.lz_compartments.compartments[local.database_compartment.key].id
           namespace = "oci_autonomous_database"
           query = "CpuUtilization[1m].mean() > 80"
           severity = "critical"
           metric_compartment_id_in_subtree = true
           message_format = "PRETTY_JSON"
           pending_duration = "PT5M"
        },

       ("${var.service_label}-adb-storage-alarm") = {
           compartment_id = module.lz_compartments.compartments[local.database_compartment.key].id
           destinations = [module.lz_database_topic.topic.id] 
           display_name = "${var.service_label}-adb-storage-alarm"
           is_enabled = var.create_alarms_as_enabled
           metric_compartment_id = module.lz_compartments.compartments[local.database_compartment.key].id
           namespace = "oci_autonomous_database"
           query = "StorageUtilization[1m].mean() > 80"
           severity = "critical"
           metric_compartment_id_in_subtree = true
           message_format = "PRETTY_JSON"
           pending_duration = "PT5M"
        }
        
    }
}

module "lz_network_alarms" {
    source    = "../modules/monitoring/alarms"
    alarms = {
        ("${var.service_label}-vpn-status-alarm") = {
           compartment_id = module.lz_compartments.compartments[local.network_compartment.key].id
           destinations = [module.lz_network_topic.topic.id]  
           display_name = "${var.service_label}-vpn-status-alarm"
           is_enabled = var.create_alarms_as_enabled
           metric_compartment_id = module.lz_compartments.compartments[local.network_compartment.key].id
           namespace = "oci_vpn"
           query = "TunnelState[1m].mean() == 0"
           severity = "critical"
           metric_compartment_id_in_subtree = true
           message_format = "PRETTY_JSON"
           pending_duration = "PT5M"
        },

       ("${var.service_label}-fast-connect-status-alarm") = {
           compartment_id = module.lz_compartments.compartments[local.network_compartment.key].id
           destinations = [module.lz_network_topic.topic.id] 
           display_name = "${var.service_label}-fast-connect-status-alarm"
           is_enabled = var.create_alarms_as_enabled
           metric_compartment_id = module.lz_compartments.compartments[local.network_compartment.key].id
           namespace = "oci_fastconnect"
           query = "ConnectionState[1m].mean() == 0"
           severity = "critical"
           metric_compartment_id_in_subtree = true
           message_format = "PRETTY_JSON"
           pending_duration = "PT5M"
        }
        
    }
} 
