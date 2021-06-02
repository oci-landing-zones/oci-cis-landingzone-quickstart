# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# General
variable "service_label" {
    validation {
        condition     = length(regexall("^[A-Za-z][A-Za-z0-9]{1,7}$", var.service_label)) > 0
        error_message = "The service_label variable is required and must contain alphanumeric characters only, start with a letter and 8 character max."
  }
}

variable "tenancy_ocid" {}
variable "user_ocid" {
    default = ""
}
variable "fingerprint" {
    default = ""
}
variable "private_key_path" {
    default = ""
}
variable "private_key_password" {
    default = ""
}
variable "region" {
    validation {
        condition     = length(trim(var.region,"")) > 0
        error_message = "The region variable is required."
  }
}  

# Networking
variable "vcn_cidr" {
    default = "10.0.0.0/16"
    validation { 
        condition = length(regexall("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))$",var.vcn_cidr)) > 0
        error_message = "Invalid cidr block value provided for vcn_cidr variable."
    }
}
variable "public_subnet_cidr" {
    default = "10.0.1.0/24"
    validation { 
        condition = length(regexall("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))$",var.public_subnet_cidr)) > 0
        error_message = "Invalid cidr block value provided for public_subnet_cidr variable."
    }
}
variable "private_subnet_app_cidr" {
    default = "10.0.2.0/24"
    validation { 
        condition = length(regexall("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))$",var.private_subnet_app_cidr)) > 0
        error_message = "Invalid cidr block value provided for private_subnet_app_cidr variable."
    }
}
variable "private_subnet_db_cidr" {
    default = "10.0.3.0/24"
    validation { 
        condition = length(regexall("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))$",var.private_subnet_db_cidr)) > 0
        error_message = "Invalid cidr block value provided for private_subnet_db_cidr variable."
    }
}
variable "public_src_bastion_cidr" {
    validation {
        condition     = var.public_src_bastion_cidr != "0.0.0.0/0" && length(regexall("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))?$",var.public_src_bastion_cidr)) > 0
        error_message = "The public_src_bastion_cidr variable value must be different than 0.0.0.0/0."
    }
}
variable "public_src_lbr_cidr" {
    default = "0.0.0.0/0"
    validation { 
        condition = length(regexall("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))$",var.public_src_lbr_cidr)) > 0
        error_message = "Invalid cidr block value provided for public_src_lbr_cidr variable."
    }
}
variable "is_vcn_onprem_connected" {
    default = false
    validation {
      condition = can(tobool(var.is_vcn_onprem_connected))
      error_message = "Invalid value provided for is_vcn_onprem_connected. Valid values: true or false."
    }
}
variable "onprem_cidr" {
    default = "0.0.0.0/0"
    validation { 
        condition = length(regexall("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))$",var.onprem_cidr)) > 0
        error_message = "Invalid cidr block value provided for onprem_cidr variable."
    }
}

# Monitoring
variable "network_admin_email_endpoint" {
    validation { 
        condition = length(regexall("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",var.network_admin_email_endpoint)) > 0
        error_message = "Invalid email address value provided for network_admin_email_endpoint variable."
    }
}
variable "security_admin_email_endpoint" {
    validation { 
        condition = length(regexall("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",var.security_admin_email_endpoint)) > 0
        error_message = "Invalid email address value provided for security_admin_email_endpoint variable."
    }
}
variable "cloud_guard_configuration_status" {
  default = "ENABLED"
  validation {
      condition = contains(["ENABLED","DISABLED"], upper(var.cloud_guard_configuration_status))
      error_message = "Invalid value provided for cloud_guard_configuration_status. Valid values (case insensitive): ENABLED or DISABLED."
  }
}

# Service Connector Hub related configuration
variable "create_service_connector_audit" {
    type = bool
    default = false
    description = "Create Service Connector Hub for Audit logs. This may incur some charges."
}

variable "service_connector_audit_target" {
    type = string
    default = "objectstorage"
    description = "Destination for Service Connector Hub for Audit Logs. Valid values are 'objectStorage', 'streaming' and 'functions'. In case of streaming/functions provide stream/function OCID and compartment OCID in the variables below"
    validation {
      condition = var.service_connector_audit_target == "objectstorage" || var.service_connector_audit_target == "streaming" || var.service_connector_audit_target == "functions"
      error_message = "Invalid value provided for service_connector_audit_target. Valid values: objectStorage, streaming, functions."
    }
}

variable "service_connector_audit_state" {
    type = string
    default = "INACTIVE"
    description = "State in which to create the Service Connector Hub for Audit logs. Valid values are 'ACTIVE' and 'INACTIVE'"
    validation {
      condition = var.service_connector_audit_state == "ACTIVE" || var.service_connector_audit_state == "INACTIVE"
      error_message = "Invalid value provided for service_connector_audit_target. Valid values: ACTIVE, INACTIVE."
    }
}

variable "service_connector_audit_target_OCID" {
    type = string
    default = ""
    description = "Applicable only for streaming/functions target types. OCID of stream/function target for the Service Connector Hub for Audit logs"
}

variable "service_connector_audit_target_cmpt_OCID" {
    type = string
    default = ""
    description = "Applicable only for streaming/functions target types. OCID of compartment containing the stream/function target for the Service Connector Hub for Audit logs"
}

variable "sch_audit_objStore_objNamePrefix" {
    type = string
    default = "sch-audit"
    description = "Applicable only for objectStorage target type. The prefix for the objects for Audit logs"
}

variable "create_service_connector_vcnFlowLogs" {
    type = bool
    default = false
    description = "Create Service Connector Hub for VCN Flow logs. This may incur some charges."
}

variable "service_connector_vcnFlowLogs_target" {
    type = string
    default = "objectstorage"
    description = "Destination for Service Connector Hub for VCN Flow Logs. Valid values are 'objectStorage', 'streaming' and functions. In case of streaming/functions provide stream/function OCID and compartment OCID in the variables below"
    validation {
      condition = var.service_connector_vcnFlowLogs_target == "objectstorage" || var.service_connector_vcnFlowLogs_target == "streaming" || var.service_connector_vcnFlowLogs_target == "functions"
      error_message = "Invalid value provided for service_connector_vcnFlowLogs_target. Valid values: objectStorage, streaming, functions."
    }
}

variable "service_connector_vcnFlowLogs_state" {
    type = string
    default = "INACTIVE"
    description = "State in which to create the Service Connector Hub for VCN Flow logs. Valid values are 'ACTIVE' and 'INACTIVE'"
    validation {
      condition = var.service_connector_vcnFlowLogs_state == "ACTIVE" || var.service_connector_vcnFlowLogs_state == "INACTIVE"
      error_message = "Invalid value provided for service_connector_vcnFlowLogs_state. Valid values: ACTIVE, INACTIVE."
    }
}

variable "service_connector_vcnFlowLogs_target_OCID" {
    type = string
    default = ""
    description = "Applicable only for streaming/functions target types. OCID of stream/function target for the Service Connector Hub for VCN Flow logs"
}

variable "service_connector_vcnFlowLogs_target_cmpt_OCID" {
    type = string
    default = ""
    description = "Applicable only for streaming/functions target types. OCID of compartment containing the stream/function target for the Service Connector Hub for VCN Flow logs"
}

variable "sch_vcnFlowLogs_objStore_objNamePrefix" {
    type = string
    default = "sch-vcnFlowLogs"
    description = "Applicable only for objectStorage target type. The prefix for the objects for VCN Flow logs"
}

# Vulnerability Scanning Service
variable "vss_create" {
    description = "Whether or not Vulnerability Scanning Service recipes and targets are to be created in the Landing Zone."
    type = bool
    default = true
}
variable "vss_scan_schedule" {
    description = "The scan schedule for the Vulnerability Scanning Service recipe, if enabled. Valid values are WEEKLY or DAILY."
    type = string
    default = "WEEKLY"
    validation {
        condition = contains(["WEEKLY","DAILY"], upper(var.vss_scan_schedule))
        error_message = "Invalid value for provided for vss_scan_schedule. Valid values (case insensitive): WEEKLY or DAILY."
    }
}
variable "vss_scan_day" {
    description = "The week day for the Vulnerability Scanning Service recipe, if enabled. Only applies if vss_scan_schedule is WEEKLY."
    type = string
    default = "SUNDAY"
    validation {
        condition = contains(["SUNDAY","MONDAY","TUESDAY","WEDNESDAY","THURSDAY","FRIDAY","SATURDAY"], upper(var.vss_scan_day))
        error_message = "Invalid value for provided for vss_scan_day. Valid values (case insensitive): SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY."
    }
}
