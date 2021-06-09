# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Environment
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

#Enclosing Compartment
variable "use_enclosing_compartment" {
    type    = bool
    default = false
    description = "Whether or not the Landing Zone compartments are created within an enclosing compartment. If unchecked, the Landing Zone compartments are created under the root compartment."
}
variable "existing_enclosing_compartment_ocid" {
    type    = string
    default = null
    description = "The enclosing compartment where Landing Zone compartments will be created. If not provided and use_enclosing_compartment is true, an enclosing compartment is created under the root compartment."
}
variable "policies_in_root_compartment" {
    type    = string
    default = "CREATE"
    description = "Whether or not required policies at the root compartment should be created or simply used. If \"CREATE\", you must be sure the user executing this stack has permissions to create policies in the root compartment. If \"USE\", policies must have been created previously."
    validation {
      condition = var.policies_in_root_compartment == "CREATE" || var.policies_in_root_compartment == "USE"
      error_message = "Invalid value provided for policies_in_root_compartment. Valid values: CREATE or USE."
  }
}
variable "use_existing_iam_groups" {
    type    = bool
    default = false
    description = "Whether or not existing groups are to be reused for this Landing Zone. If unchecked, one set of groups is created. If checked, existing group names must be provided and this set will be able to manage resources in this Landing Zone."
}
variable "existing_iam_admin_group_name" {
    type    = string
    default = ""
}
variable "existing_cred_admin_group_name" {
    type    = string
    default = ""
}
variable "existing_security_admin_group_name" {
    type    = string
    default = ""
}
variable "existing_network_admin_group_name" {
    type    = string
    default = ""
}
variable "existing_appdev_admin_group_name" {
    type    = string
    default = ""
}
variable "existing_database_admin_group_name" {
    type    = string
    default = ""
}
variable "existing_auditor_group_name" {
    type    = string
    default = ""
}
variable "existing_announcement_reader_group_name" {
    type    = string
    default = ""
}

# Networking
variable "hub_spoke_architecture" {
  type        = bool
  default     = true
  description = "Determines if a Hub and Spoke Architecture is deployed"
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
variable "no_internet_access" {
  default = false
  type = bool
  description = "Determines if the network will have direct access to the internet. Default is false which creates an Internet Gateway and NAT Gateway, true will not create an Internet Gateway or NAT Gateway"
}
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
## DMZ VCN 
variable "dmz_vcn_cidr" {
  default = "10.2.0.0/20"
  validation {
    condition     = length(regexall("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))$", var.dmz_vcn_cidr)) > 0
    error_message = "Invalid cidr block value provided for hub_vcn_cidr variable."
  }
}
variable "dmz_bastion_subnet_cidr" {
  default = "10.2.1.0/24"
  validation {
    condition     = length(regexall("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))$", var.dmz_bastion_subnet_cidr)) > 0
    error_message = "Invalid cidr block value provided for hub_bastion_subnet_cidr variable."
  }
}
variable "dmz_services_subnet_cidr" {
  default = "10.2.2.0/24"
  validation {
    condition     = length(regexall("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))$", var.dmz_services_subnet_cidr)) > 0
    error_message = "Invalid cidr block value provided for hub_services_subnet_cidr variable."
  }
}
## Spoke 2 VCN 
variable "spoke2_vcn_cidr" {
  default = "10.3.0.0/20"
  validation {
    condition     = length(regexall("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))$", var.spoke2_vcn_cidr)) > 0
    error_message = "Invalid cidr block value provided for spoke2_vcn_cidr variable."
  }
}
variable "spoke2_private_subnet_web_cidr" {
  default = "10.3.1.0/24"
  validation {
    condition     = length(regexall("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))$", var.spoke2_private_subnet_web_cidr)) > 0
    error_message = "Invalid cidr block value provided for spoke2_private_subnet_web_cidr variable."
  }
}
variable "spoke2_private_subnet_app_cidr" {
  default = "10.3.2.0/24"
  validation {
    condition     = length(regexall("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))$", var.spoke2_private_subnet_app_cidr)) > 0
    error_message = "Invalid cidr block value provided for spoke2_private_subnet_app_cidr variable."
  }
}
variable "spoke2_private_subnet_db_cidr" {
  default = "10.3.3.0/24"
  validation {
    condition     = length(regexall("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))$", var.spoke2_private_subnet_db_cidr)) > 0
    error_message = "Invalid cidr block value provided for spoke2_private_subnet_db_cidr variable."
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
