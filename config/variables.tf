# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Environment
variable "service_label" {
  validation {
    condition     = length(regexall("^[A-Za-z][A-Za-z0-9]{1,7}$", var.service_label)) > 0
    error_message = "Validation failed for service_label: value is required and must contain alphanumeric characters only, starting with a letter up to a maximum of 8 characters."
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
    condition     = length(trim(var.region, "")) > 0
    error_message = "Validation failed for region: value is required."
  }
}

#Enclosing Compartment
variable "use_enclosing_compartment" {
  type        = bool
  default     = false
  description = "Whether the Landing Zone compartments are created within an enclosing compartment. If false, the Landing Zone compartments are created under the root compartment."
}
variable "existing_enclosing_compartment_ocid" {
  type        = string
  default     = null
  description = "The enclosing compartment OCID where Landing Zone compartments will be created. If not provided and use_enclosing_compartment is true, an enclosing compartment is created under the root compartment."
}
variable "policies_in_root_compartment" {
  type        = string
  default     = "CREATE"
  description = "Whether required policies at the root compartment should be created or simply used. If \"CREATE\", you must be sure the user executing this stack has permissions to create policies in the root compartment. If \"USE\", policies must have been created previously."
  validation {
    condition     = contains(["CREATE", "USE"], var.policies_in_root_compartment)
    error_message = "Validation failed for policies_in_root_compartment: valid values are CREATE or USE."
  }
}
variable "use_existing_groups" {
  type        = bool
  default     = false
  description = "Whether existing groups are to be reused for this Landing Zone. If false, one set of groups is created. If true, existing group names must be provided and this set will be able to manage resources in this Landing Zone."
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
variable "existing_exainfra_admin_group_name" {
  type    = string
  default = ""
}

# Networking
variable "no_internet_access" {
  default     = false
  type        = bool
  description = "Determines if the network will have direct access to the internet. If false, an Internet Gateway and NAT Gateway are created. If true, Internet Gateway and NAT Gateway are NOT created and both is_vcn_onprem_connected and onprem_cidr become required."
}
 variable "is_vcn_onprem_connected" {
  type        = bool
  default     = false
  description = "Whether the VCNs are connected to the on-premises network, in which case a DRG is created and attached to the VCNs. This must be true if 'no_internet_access' is true and 'existing_drg_id' is not provided."
}

variable "existing_drg_id" {
  type        = string
  default     = ""
  description = "The DRG OCID of an existing DRG, if using an existing DRG."
}

variable "onprem_cidrs" {
  type        = list(string)
  description = "List of on-premises CIDR blocks allowed to connect to the Landing Zone network via a DRG."
  default     = []
  validation {
    condition     = length([for c in var.onprem_cidrs : c if length(regexall("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))?$", c)) > 0]) == length(var.onprem_cidrs)
    error_message = "Validation failed for onprem_cidrs: values must be in CIDR notation."
  }
}

variable "onprem_src_ssh_cidrs" {
  type        = list(string)
  description = "List of on-premises CIDR blocks allowed to connect to the Landing Zone network over SSH. They must be a subset of onprem_cidrs."
  default     = []
  validation {
    condition     = length([for c in var.onprem_src_ssh_cidrs : c if length(regexall("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))?$", c)) > 0]) == length(var.onprem_src_ssh_cidrs)
    error_message = "Validation failed for onprem_src_ssh_cidrs: values must be in CIDR notation."
  }
}

variable "vcn_cidrs" {
  type        = list(string)
  default     = ["10.0.0.0/20"]
  description = "List of CIDR blocks for the VCNs to be created in CIDR notation. If hub_spoke_architecture is true, these VCNs are turned into spoke VCNs. You can create up to nine VCNs."
  validation {
    condition     = length(var.vcn_cidrs) > 0 && (length(var.vcn_cidrs) < 10 && length([for c in var.vcn_cidrs : c if length(regexall("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))?$", c)) > 0]) == length(var.vcn_cidrs))
    error_message = "Validation failed for vcn_cidrs: values must be in CIDR notation. Minimum of one required and maximum of nine allowed."
  }
}

variable "vcn_names" {
  type        = list(string)
  default     = []
  description = "List of custom names to be given to the VCNs, overriding the default VCN names (<service-label>-<index>-vcn). The list length and elements order must match vcn_cidrs'."
  validation {
    condition     = length(var.vcn_names) < 10
    error_message = "Validation failed for vcn_names: maximum of nine allowed."
  }
}

variable "hub_spoke_architecture" {
  type        = bool
  default     = false
  description = "Determines if a Hub & Spoke network architecture is to be deployed.  Allows for inter-spoke routing."
}

variable "dmz_vcn_cidr" {
  type        = string
  default     = ""
  description = "CIDR block for the DMZ VCN. DMZ VCNs are commonly used for network appliance deployments. All traffic will be routed through the DMZ. Required if hub_spoke_architecture is true."
  validation {
    condition     = length(var.dmz_vcn_cidr) == 0 || length(regexall("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))$", var.dmz_vcn_cidr)) > 0
    error_message = "Validation failed for dmz_vcn_cidr: value must be in CIDR notation."
  }
}

variable "dmz_for_firewall" {
  type        = bool
  default     = false
  description = "Will a supported 3rd Party Firewall be deployed in the DMZ."
}

variable "dmz_number_of_subnets" {
  type        = number
  default     = 2
  description = "The number of subnets to be created in the DMZ VCN. If using the DMZ VCN for a network appliance deployment, please see the vendor's documentation or OCI reference architecture to determine the number of subnets required."
  validation {
    condition     = var.dmz_number_of_subnets > 0 && var.dmz_number_of_subnets < 6
    error_message = "Validation failed for dmz_number_of_subnets: Minimum of one required and maximum of five allowed."
  }
}
variable "dmz_subnet_size" {
  type        = number
  default     = 4
  description = "The number of additional bits with which to extend the DMZ VCN CIDR prefix. For instance, if the dmz_vcn_cidr's prefix is 20 (/20) and dmz_subnet_size is 4, subnets are going to be /24."
}

variable "public_src_bastion_cidrs" {
  type        = list(string)
  default     = []
  description = "External IP ranges in CIDR notation allowed to make SSH inbound connections. 0.0.0.0/0 is not allowed in the list."
  validation {
    condition     = !contains(var.public_src_bastion_cidrs, "0.0.0.0/0") && length([for c in var.public_src_bastion_cidrs : c if length(regexall("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))?$", c)) > 0]) == length(var.public_src_bastion_cidrs)
    error_message = "Validation failed for public_src_bastion_cidrs: values must be in CIDR notation, all different than 0.0.0.0/0."
  }
}

variable "public_src_lbr_cidrs" {
  # default = "0.0.0.0/0"
  type        = list(string)
  default     = []
  description = "External IP ranges in CIDR notation allowed to make HTTPS inbound connections."
  validation {
    condition     = length([for c in var.public_src_lbr_cidrs : c if length(regexall("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))?$", c)) > 0]) == length(var.public_src_lbr_cidrs)
    error_message = "Validation failed for public_src_lbr_cidrs: values must be in CIDR notation."
  }
}

variable "public_dst_cidrs" {
  type        = list(string)
  default     = []
  description = "External IP ranges in CIDR notation for HTTPS outbound connections."
  validation {
    condition     = length([for c in var.public_dst_cidrs : c if length(regexall("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))?$", c)) > 0]) == length(var.public_dst_cidrs)
    error_message = "Validation failed for public_dst_cidrs: values must be in CIDR notation."
  }
}

variable "exacs_vcn_cidrs" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks for the Exadata Cloud Service VCNs to be created in CIDR notation. If hub_spoke_architecture is true, these VCNs are turned into spoke VCNs. You can provider up to nine CIDRs."
  validation {
    condition     = length(var.exacs_vcn_cidrs) == 0 || (length(var.exacs_vcn_cidrs) < 10 && length(var.exacs_vcn_cidrs) > 0 && length([for c in var.exacs_vcn_cidrs : c if length(regexall("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))?$", c)) > 0]) == length(var.exacs_vcn_cidrs))
    error_message = "Validation failed for exacs_vcn_cidrs: values must be in CIDR notation."
  }
}

variable "exacs_vcn_names" {
  type        = list(string)
  default     = []
  description = "List of Exadata VCNs custom names, overriding the default Exadata VCNs names. Each provided name relates to one and only one VCN, the 'nth' value applying to the 'nth' value in 'exacs_vcn_cidrs'. You can provide up to nine names."
  validation {
    condition     = length(var.exacs_vcn_names) == 0 || length(var.exacs_vcn_names) < 10
    error_message = "Validation failed for exacs_vcn_names: maximum of nine allowed."
  }
}
variable "exacs_client_subnet_cidrs" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks for the client subnets of Exadata Cloud Service VCNs, in CIDR notation. Each provided CIDR value relates to one and only one VCN, the 'nth' value applying to the 'nth' value in 'exacs_vcn_cidrs'. CIDRs must not overlap with 192.168.128.0/20. You can provide up to nine CIDRs."
  validation {
    condition     = length(var.exacs_client_subnet_cidrs) == 0 || (length(var.exacs_client_subnet_cidrs) < 10 && length(var.exacs_client_subnet_cidrs) > 0 && length([for c in var.exacs_client_subnet_cidrs : c if length(regexall("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))?$", c)) > 0]) == length(var.exacs_client_subnet_cidrs))
    error_message = "Validation failed for exacs_client_subnet_cidrs: values must be in CIDR notation."
  }
}

variable "exacs_backup_subnet_cidrs" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks for the backup subnets of Exadata Cloud Service VCNs, in CIDR notation. Each provided CIDR value relates to one and only one VCN, the 'nth' value applying to the 'nth' value in 'exacs_vcn_cidrs'. CIDRs must not overlap with 192.168.128.0/20. You can provide up to nine CIDRs"
  validation {
    condition     = length(var.exacs_backup_subnet_cidrs) == 0 || (length(var.exacs_backup_subnet_cidrs) < 10 && length(var.exacs_backup_subnet_cidrs) > 0 && length([for c in var.exacs_backup_subnet_cidrs : c if length(regexall("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))?$", c)) > 0]) == length(var.exacs_backup_subnet_cidrs))
    error_message = "Validation failed for exacs_backup_subnet_cidrs: values must be in CIDR notation."
  }
}

variable "deploy_exainfra_cmp" {
  type        = bool
  default     = true
  description = "Whether a compartment for Exadata infrastructure should be created. If false, Exadata infrastructure should be created in the database compartment."
}

variable "network_admin_email_endpoints" {
  type        = list(string)
  default     = []
  description = "List of email addresses for all network related notifications."
  validation {
    condition     = length([for e in var.network_admin_email_endpoints : e if length(regexall("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", e)) > 0]) == length(var.network_admin_email_endpoints)
    error_message = "Validation failed network_admin_email_endpoints: invalid email address."
  }
}
variable "security_admin_email_endpoints" {
  type        = list(string)
  default     = []
  description = "List of email addresses for all security related notifications."
  validation {
    condition     = length([for e in var.security_admin_email_endpoints : e if length(regexall("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", e)) > 0]) == length(var.security_admin_email_endpoints)
    error_message = "Validation failed security_admin_email_endpoints: invalid email address."
  }
}
variable "cloud_guard_configuration_status" {
  default     = "ENABLE"
  description = "Determines whether Cloud Guard should be enabled in the tenancy. If 'ENABLE', a target is created for the Root compartment."
  validation {
    condition     = contains(["ENABLE", "DISABLE"], upper(var.cloud_guard_configuration_status))
    error_message = "Validation failed for cloud_guard_configuration_status: valid values (case insensitive) are ENABLE or DISABLE."
  }
}

# Service Connector Hub related configuration
variable "create_service_connector_audit" {
  type        = bool
  default     = false
  description = "Create Service Connector Hub for Audit logs. This may incur some charges."
}
variable "service_connector_audit_target" {
  type        = string
  default     = "objectstorage"
  description = "Destination for Service Connector Hub for Audit Logs. Valid values are objectstorage, streaming or functions (case insensitive). In case of streaming/functions provide stream/function OCID and compartment OCID in the variables below."
  validation {
    condition     = contains(["objectstorage", "streaming", "functions"], var.service_connector_audit_target)
    error_message = "Validation failed for service_connector_audit_target: valid values are objectstorage, streaming or functions (case insensitive)."
  }
}
variable "service_connector_audit_state" {
  type        = string
  default     = "INACTIVE"
  description = "State in which to create the Service Connector Hub for Audit logs. Valid values are ACTIVE and INACTIVE (case insensitive)."
  validation {
    condition     = contains(["ACTIVE", "INACTIVE"], var.service_connector_audit_state)
    error_message = "Validation failed for for service_connector_audit_target: valid values are ACTIVE or INACTIVE (case insensitive)."
  }
}
variable "service_connector_audit_target_OCID" {
  type        = string
  default     = ""
  description = "Applicable only for streaming/functions target types. OCID of stream/function target for the Service Connector Hub for Audit logs."
}
variable "service_connector_audit_target_cmpt_OCID" {
  type        = string
  default     = ""
  description = "Applicable only for streaming/functions target types. OCID of compartment containing the stream/function target for the Service Connector Hub for Audit logs."
}
variable "sch_audit_objStore_objNamePrefix" {
  type        = string
  default     = "sch-audit"
  description = "Applicable only for objectStorage target type. The prefix for the objects for Audit logs."
}
variable "create_service_connector_vcnFlowLogs" {
  type        = bool
  default     = false
  description = "Create Service Connector Hub for VCN Flow logs. This may incur some charges."
}
variable "service_connector_vcnFlowLogs_target" {
  type        = string
  default     = "objectstorage"
  description = "Destination for Service Connector Hub for VCN Flow Logs. Valid values are objectstorage, streaming or functions (case insensitive). In case of streaming/functions provide stream/function OCID and compartment OCID in the variables below."
  validation {
    condition     = contains(["objectstorage", "streaming", "functions"], var.service_connector_vcnFlowLogs_target)
    error_message = "Validation failed for service_connector_vcnFlowLogs_target: valid values are objectstorage, streaming or functions (case insensitive)."
  }
}
variable "service_connector_vcnFlowLogs_state" {
  type        = string
  default     = "INACTIVE"
  description = "State in which to create the Service Connector Hub for VCN Flow logs. Valid values are ACTIVE or INACTIVE (case insensitive)."
  validation {
    condition     = contains(["ACTIVE", "INACTIVE"], var.service_connector_vcnFlowLogs_state)
    error_message = "Validation failed for service_connector_vcnFlowLogs_state: valid values are ACTIVE or INACTIVE (case insensitive)."
  }
}
variable "service_connector_vcnFlowLogs_target_OCID" {
  type        = string
  default     = ""
  description = "Applicable only for streaming/functions target types. OCID of stream/function target for the Service Connector Hub for VCN Flow logs"
}
variable "service_connector_vcnFlowLogs_target_cmpt_OCID" {
  type        = string
  default     = ""
  description = "Applicable only for streaming/functions target types. OCID of compartment containing the stream/function target for the Service Connector Hub for VCN Flow logs"
}
variable "sch_vcnFlowLogs_objStore_objNamePrefix" {
  type        = string
  default     = "sch-vcnFlowLogs"
  description = "Applicable only for objectStorage target type. The prefix for the objects for VCN Flow logs."
}

# Vulnerability Scanning Service
variable "vss_create" {
  description = "Whether or not Vulnerability Scanning Service recipes and targets are to be created in the Landing Zone."
  type        = bool
  default     = true
}
variable "vss_scan_schedule" {
  description = "The scan schedule for the Vulnerability Scanning Service recipe, if enabled. Valid values are WEEKLY or DAILY (case insensitive)."
  type        = string
  default     = "WEEKLY"
  validation {
    condition     = contains(["WEEKLY", "DAILY"], upper(var.vss_scan_schedule))
    error_message = "Validation failed for vss_scan_schedule: valid values are WEEKLY or DAILY (case insensitive)."
  }
}
variable "vss_scan_day" {
  description = "The week day for the Vulnerability Scanning Service recipe, if enabled. Only applies if vss_scan_schedule is WEEKLY (case insensitive)."
  type        = string
  default     = "SUNDAY"
  validation {
    condition     = contains(["SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"], upper(var.vss_scan_day))
    error_message = "Validation failed for vss_scan_day: valid values are SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY (case insensitive)."
  }
}
