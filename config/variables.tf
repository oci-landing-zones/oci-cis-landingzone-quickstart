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
variable "home_region" {
    validation {
        condition     = length(trim(var.home_region,"")) > 0
        error_message = "The home_region variable is required for IAM resources."
  }
}
variable "region" {
    validation {
        condition     = length(trim(var.region,"")) > 0
        error_message = "The region variable is required."
  }
}  
variable "region_key" {
  validation {
    condition     = length(regexall("^[a-z]{1,3}$", var.region_key)) > 0
    error_message = "The region_key variable is required and must be a 3 letter string, lowercase."
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
      condition = var.cloud_guard_configuration_status == "ENABLED" || var.cloud_guard_configuration_status == "DISABLED"
      error_message = "Invalid value provided for cloud_guard_configuration_status. Valid values: ENABLED or DISABLED."
  }
}
# Setting this variable to true lets the user seed the oracle managed entities with minimal changes to the original entities.
# False will delegate this responsibility to CloudGuard for seeding the oracle managed entities.
variable "cloud_guard_configuration_self_manage_resources" {
    default = false
    validation {
      condition = can(tobool(var.cloud_guard_configuration_self_manage_resources))
      error_message = "Invalid value provided for cloud_guard_configuration_self_manage_resources. Valid values: true or false."
  }
}

# Service Connector Hub related configuration
variable "create_service_connector_audit" {
    type = bool
    default = false
    description = "create service connector for audit logs"
}

variable "create_service_connector_vcnFlowLogs" {
    type = bool
    default = false
    description = "create service connector for vcn flow logs"
}

variable "service_connector_audit_target" {
    type = string
    default = "objectStorage"
    description = "destination for audit logs service connector. Valid values are 'objectStorage', 'streaming' and functions. In case of streaming/functions provide stream/function OCID in the variable below"
}

variable "service_connector_audit_state" {
    type = string
    default = "INACTIVE"
    description = "state in which to create the service connector for audit logs. valid values are 'ACTIVE' and 'INACTIVE'"
}

variable "service_connector_vcnFlowLogs_state" {
    type = string
    default = "INACTIVE"
    description = "state in which to create the service connector for vcn flow logs. valid values are 'ACTIVE' and 'INACTIVE'"
}

variable "service_connector_vcnFlowLogs_target" {
    type = string
    default = "objectStorage"
    description = "destination for vcn flow logs service connector. Valid values are 'objectStorage', 'streaming' and functions. In case of streaming/functions provide stream/function OCID in the variable below"
}

variable "service_connector_audit_target_OCID" {
    type = string
    default = ""
    description = "OCID of stream/function target for the audit logs service connector"
}

variable "service_connector_audit_target_cmpt_OCID" {
    type = string
    default = ""
    description = "OCID of compartment containing the stream/function target for the audit logs service connector"
}

variable "service_connector_vcnFlowLogs_target_OCID" {
    type =string
    default = ""
    description = "OCID of stream/function target for the vcn flowLogs logs service connector"
}

variable "service_connector_vcnFlowLogs_target_cmpt_OCID" {
    type =string
    default = ""
    description = "OCID of comartment containing the stream/function target for the vcn flowLogs logs service connector"
}

variable "sch_audit_target_rollover_MBs" {
    type = number
    default = 100
    description = "target rollover size in MBs for audit logs"
}

variable "sch_audit_target_rollover_MSs" {
    type = number
    default = 7 * 60 * 1000 // 7 minutes
    description = "target rollover time in MBs for audit logs"
}

variable "sch_vcnFlowLogs_target_rollover_MBs" {
    type = number
    default = 100
    description = "target rollover size in MBs for audit logs"
}

variable "sch_vcnFlowLogs_target_rollover_MSs" {
    type = number
    default = 7 * 60 * 1000 // 7 minutes
    description = "target rollover time in MBs for audit logs"
}

variable "sch_audit_objStore_objNamePrefix" {
    type = string
    default = "sch-audit"
    description = "The prefix of the objects"
}

variable "sch_vcnFlowLogs_objStore_objNamePrefix" {
    type = string
    default = "sch-vcnFlowLogs"
    description = "The prefix of the objects"
}

