# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration provisions alarms for the cis tenancy.

module "lz_compute_alarms" {
    source    = "../modules/monitoring/alarms"
    alarms = {
        ("${var.service_label}-high-cpu-alarm") = {
           compartment_id = var.tenancy_ocid
           destinations = [module.lz_compute_topic.topic.id]
           display_name = "${var.service_label}-high-cpu-alarm"
           is_enabled = var.create_alarms_as_enabled
           metric_compartment_id = var.tenancy_ocid
           namespace = "oci_computeagent"
           query = "CpuUtilization[5m].mean() > 80"
           severity = "critical"

        
        }
        /*,

       ("${var.service_label}-instance-status-alarm") = {
           compartment_id = var.tenancy_ocid
           destinations = [oci_ons_notification_topic.test_notification_topic.id] 
           display_name = var.alarm_display_name
           is_enabled = var.alarm_is_enabled
           metric_compartment_id = var.alarm_metric_compartment_id
           namespace = var.alarm_namespace
           query = var.alarm_query
           severity = var.alarm_severity
        },
        ("${var.service_label}-vm-maintenance-alarm") = {
           compartment_id = var.tenancy_ocid
           destinations = [oci_ons_notification_topic.test_notification_topic.id] 
           display_name = var.alarm_display_name
           is_enabled = var.alarm_is_enabled
           metric_compartment_id = var.alarm_metric_compartment_id
           namespace = var.alarm_namespace
           query = var.alarm_query
           severity = var.alarm_severity
        },
        ("${var.service_label}-bare-metal-unhealthy-alarm") = {
           compartment_id = var.tenancy_ocid
           destinations = [oci_ons_notification_topic.test_notification_topic.id] 
           display_name = var.alarm_display_name
           is_enabled = var.alarm_is_enabled
           metric_compartment_id = var.alarm_metric_compartment_id
           namespace = var.alarm_namespace
           query = var.alarm_query
           severity = var.alarm_severity
        },
        ("${var.service_label}-high-memory-alarm") = {
           compartment_id = var.tenancy_ocid
           destinations = [oci_ons_notification_topic.test_notification_topic.id] 
           display_name = var.alarm_display_name
           is_enabled = var.alarm_is_enabled
           metric_compartment_id = var.alarm_metric_compartment_id
           namespace = var.alarm_namespace
           query = var.alarm_query
           severity = var.alarm_severity
        }
    }
}

   Enable this later
module "lz_database_alarms" {
    source    = "../modules/monitoring/alarms"
    alarms = {
        ("${var.service_label}-adb-cpu-alarm") = {
           compartment_id = var.tenancy_ocid
           destinations = [oci_ons_notification_topic.test_notification_topic.id] 
           display_name = var.alarm_display_name
           is_enabled = var.alarm_is_enabled
           metric_compartment_id = var.alarm_metric_compartment_id
           namespace = var.alarm_namespace
           query = var.alarm_query
           severity = var.alarm_severity
        },

       ("${var.service_label}-adb-storage-alarm") = {
           compartment_id = var.tenancy_ocid
           destinations = [oci_ons_notification_topic.test_notification_topic.id] 
           display_name = var.alarm_display_name
           is_enabled = var.alarm_is_enabled
           metric_compartment_id = var.alarm_metric_compartment_id
           namespace = var.alarm_namespace
           query = var.alarm_query
           severity = var.alarm_severity
        }
        
    }
}


module "lz_storage_alarms" {
    source    = "../modules/monitoring/alarms"
    alarms = {
        ("${var.service_label}-oss-failed-upload-alarm") = {
           compartment_id = var.tenancy_ocid
           destinations = [oci_ons_notification_topic.test_notification_topic.id] 
           display_name = var.alarm_display_name
           is_enabled = var.alarm_is_enabled
           metric_compartment_id = var.alarm_metric_compartment_id
           namespace = var.alarm_namespace
           query = var.alarm_query
           severity = var.alarm_severity
        }
        
    }
}

module "lz_security_alarms" {
    source    = "../modules/monitoring/alarms"
    alarms = {
        ("${var.service_label}-osms-package-updates-alarm") = {
           compartment_id = var.tenancy_ocid
           destinations = [oci_ons_notification_topic.test_notification_topic.id] 
           display_name = var.alarm_display_name
           is_enabled = var.alarm_is_enabled
           metric_compartment_id = var.alarm_metric_compartment_id
           namespace = var.alarm_namespace
           query = var.alarm_query
           severity = var.alarm_severity
        },

       ("${var.service_label}-osms-security-udpates-alarm") = {
           compartment_id = var.tenancy_ocid
           destinations = [oci_ons_notification_topic.test_notification_topic.id] 
           display_name = var.alarm_display_name
           is_enabled = var.alarm_is_enabled
           metric_compartment_id = var.alarm_metric_compartment_id
           namespace = var.alarm_namespace
           query = var.alarm_query
           severity = var.alarm_severity
        },

        ("${var.service_label}-vulnerability-scanning-alarm") = {
           compartment_id = var.tenancy_ocid
           destinations = [oci_ons_notification_topic.test_notification_topic.id] 
           display_name = var.alarm_display_name
           is_enabled = var.alarm_is_enabled
           metric_compartment_id = var.alarm_metric_compartment_id
           namespace = var.alarm_namespace
           query = var.alarm_query
           severity = var.alarm_severity
        }
        
    }
}

module "lz_network_alarms" {
    source    = "../modules/monitoring/alarms"
    alarms = {
        ("${var.service_label}-vpn-status-alarm") = {
           compartment_id = var.tenancy_ocid
           destinations = [oci_ons_notification_topic.test_notification_topic.id] 
           display_name = var.alarm_display_name
           is_enabled = var.alarm_is_enabled
           metric_compartment_id = var.alarm_metric_compartment_id
           namespace = var.alarm_namespace
           query = var.alarm_query
           severity = var.alarm_severity
        },

       ("${var.service_label}-fast-connect-status-alarm") = {
           compartment_id = var.tenancy_ocid
           destinations = [oci_ons_notification_topic.test_notification_topic.id] 
           display_name = var.alarm_display_name
           is_enabled = var.alarm_is_enabled
           metric_compartment_id = var.alarm_metric_compartment_id
           namespace = var.alarm_namespace
           query = var.alarm_query
           severity = var.alarm_severity
        }
        
    }
} */}
}