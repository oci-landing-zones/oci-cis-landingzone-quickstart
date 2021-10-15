# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration provisions alarms for the cis tenancy.

### Reference module example
# module "lz_compute_alarms" {
#     source    = "../modules/monitoring/alarms"
#     alarms = {
#         ("${var.service_label}-high-cpu-alarm") = {
#            compartment_id = var.tenancy_ocid
#            destinations = [module.lz_compute_topic.topic.id]
#            display_name = "${var.service_label}-high-cpu-alarm"
#            is_enabled = var.create_alarms_as_enabled
#            metric_compartment_id = var.tenancy_ocid
#            namespace = "oci_computeagent"
#            query = "CpuUtilization[5m].mean() > 80"
#            severity = "critical"

        
#         }



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
        }
        
    }
}


# module "lz_storage_alarms" {
#     source    = "../modules/monitoring/alarms"
#     alarms = {
#         ("${var.service_label}-oss-failed-upload-alarm") = {
#            compartment_id = local.appdev_compartment.name
#            destinations = [module.lz_storage_topic.topic.id] 
#            display_name = "${var.service_label}-oss-failed-upload-alarm"
#            is_enabled = var.create_alarms_as_enabled
#            metric_compartment_id = local.appdev_compartment.name
#            namespace = "oci_objectstorage"
#            query = "UncommittedParts[1m].bytes() > 5000"
#            severity = "warning"
#            metric_compartment_id_in_subtree = true
#         }
        
#     }
# }

# module "lz_security_alarms" {
#     source    = "../modules/monitoring/alarms"
#     alarms = {
       
#         ("${var.service_label}-vulnerability-scanning-alarm") = {
#            compartment_id = var.tenancy_ocid
#            destinations = [oci_ons_notification_topic.test_notification_topic.id] 
#            display_name = var.alarm_display_name
#            is_enabled = var.alarm_is_enabled
#            metric_compartment_id = var.alarm_metric_compartment_id
#            namespace = var.alarm_namespace
#            query = var.alarm_query
#            severity = var.alarm_severity
#         }
        
#     }
# }

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
        }
        
    }
} 
