# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Environment
variable "service_label" {
  validation {
    condition     = length(regexall("^[A-Za-z][A-Za-z0-9]{1,7}$", var.service_label)) > 0
    error_message = "Validation failed for service_label: value is required and must contain alphanumeric characters only, starting with a letter up to a maximum of 8 characters."
  }
}

variable "cis_level" {
  type = string
  default = "1"
  description = "Determines CIS OCI Benchmark Level of services deployed by the CIS Landing Zone in the tenancy will be configured. Level 1 is be practical and prudent. Level 2 is intended for environments where security is more critical than manageability and usability. More info: https://www.cisecurity.org/benchmark/oracle_cloud"
  validation {
     condition     = contains(["1", "2"], upper(var.cis_level))
      error_message = "Validation failed for cis_level: valid values are 1 or 2."
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

#Advanced options check boxes used in schema.yml
variable "env_advanced_options" {
  type = bool
  default = false
} 
variable "net_advanced_options" {
  type = bool
  default = false
} 
variable "exa_advanced_options" {
  type = bool
  default = false
} 
variable "hs_advanced_options" {
  type = bool
  default = false
}
variable "notifications_advanced_options" {
  type = bool
  default = false
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
  description = "Whether required grants at the root compartment should be created or simply used. Valid values: 'CREATE' and 'USE'. If 'CREATE', make sure the user executing this stack has permissions to create grants in the root compartment. If 'USE', no grants are created."
  validation {
    condition     = contains(["CREATE", "USE"], var.policies_in_root_compartment)
    error_message = "Validation failed for policies_in_root_compartment: valid values are CREATE or USE."
  }
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
variable "existing_cost_admin_group_name" {
  type    = string
  default = ""
}
variable "existing_storage_admin_group_name" {
  type    = string
  default = ""
}
variable "existing_security_fun_dyn_group_name" {
  type    = string
  default = ""
  description = "Existing security dynamic group."
}
variable "existing_appdev_fun_dyn_group_name" {
  type    = string
  default = ""
  description = "Existing appdev dynamic group."
}
variable "existing_compute_agent_dyn_group_name" {
  type    = string
  default = ""
  description = "Existing compute agent dynamic group for management agent access."
}
variable "existing_database_kms_dyn_group_name" {
  type    = string
  default = ""
  description = "Existing database dynamic group for database to access keys."
}
variable "extend_landing_zone_to_new_region" {
  default = false
  type    = bool
  description = "Whether Landing Zone is being extended to another region. When set to true, compartments, groups, policies and resources at the home region are not provisioned. Use this when you want provision a Landing Zone in a new region, but reuse existing Landing Zone resources in the home region."
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
  description = "The OCID of an existing DRG, used in Hub/Spoke and when connecting to On-Premises network. Provide a value if you want the Landing Zone to not deploy a DRG."
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
  description = "List of on-premises CIDR blocks allowed to connect to the Landing Zone network over SSH and RDP. They must be a subset of onprem_cidrs."
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
    condition     = length(var.vcn_cidrs) == 0 || (length(var.vcn_cidrs) < 10 && length([for c in var.vcn_cidrs : c if length(regexall("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))?$", c)) > 0]) == length(var.vcn_cidrs))
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

variable "subnets_names" {
  type = list(string)
  default = []
  description = "List of subnet names to be used in each of the spoke(s) subnet names, each subnet name must have a bit size below, the first subnet will be public if var.no_internet_access is false. Overriding the default subnet names (*service_label*-*index*-web-subnet). The list length and elements order must match subnets_sizes."
}

variable "subnets_sizes" {
  type = list(string)
  default = []
  description = "List of subnet sizes in bits that will be added to the VCN CIDR size. Overriding the default subnet size of /4. The list length and elements order must match subnets_names"
}

variable "hub_spoke_architecture" {
  type        = bool
  default     = false
  description = "Determines if a Hub/Spoke network architecture is to be deployed.  Allows for inter-spoke routing."
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
  description = "List of external IP ranges in CIDR notation allowed to make SSH and RDP inbound connections to bastion servers that are eventually deployed in public subnets. 0.0.0.0/0 is not allowed in the list."
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
  default     = false
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

variable "cloud_guard_admin_email_endpoints" {
  type        = list(string)
  default     = []
  description = "List of email addresses for Cloud Guard related notifications."
  validation {
    condition     = length([for e in var.cloud_guard_admin_email_endpoints : e if length(regexall("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", e)) > 0]) == length(var.cloud_guard_admin_email_endpoints)
    error_message = "Validation failed cloud_guard_admin_email_endpoints: invalid email address."
  }
}

variable "storage_admin_email_endpoints" {
  type        = list(string)
  default     = []
  description = "List of email addresses for all storage related notifications."
  validation {
    condition     = length([for e in var.storage_admin_email_endpoints : e if length(regexall("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", e)) > 0]) == length(var.storage_admin_email_endpoints)
    error_message = "Validation failed storage_admin_email_endpoints: invalid email address."
  }
}

variable "compute_admin_email_endpoints" {
  type        = list(string)
  default     = []
  description = "List of email addresses for all compute related notifications."
  validation {
    condition     = length([for e in var.compute_admin_email_endpoints : e if length(regexall("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", e)) > 0]) == length(var.compute_admin_email_endpoints)
    error_message = "Validation failed compute_admin_email_endpoints: invalid email address."
  }
}

variable "budget_admin_email_endpoints" {
  type        = list(string)
  default     = []
  description = "List of email addresses for all budget related notifications."
  validation {
    condition     = length([for e in var.budget_admin_email_endpoints : e if length(regexall("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", e)) > 0]) == length(var.budget_admin_email_endpoints)
    error_message = "Validation failed budget_admin_email_endpoints: invalid email address."
  }
}

variable "database_admin_email_endpoints" {
  type        = list(string)
  default     = []
  description = "List of email addresses for all database related notifications."
  validation {
    condition     = length([for e in var.database_admin_email_endpoints : e if length(regexall("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", e)) > 0]) == length(var.database_admin_email_endpoints)
    error_message = "Validation failed database_admin_email_endpoints: invalid email address."
  }
}

variable "exainfra_admin_email_endpoints" {
  type        = list(string)
  default     = []
  description = "List of email addresses for all Exadata infrastrcture related notifications. Only applicable if deploy_exainfra_cmp is true."
  validation {
    condition     = length([for e in var.exainfra_admin_email_endpoints : e if length(regexall("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", e)) > 0]) == length(var.exainfra_admin_email_endpoints)
    error_message = "Validation failed exainfra_admin_email_endpoints: invalid email address."
  }
}

variable "create_alarms_as_enabled" {
  type        = bool
  default     = false
  description = "Creates alarm artifacts in disabled state when set to false"
}

variable "create_events_as_enabled" {
  type        = bool
  default     = false
  description = "Creates event rules artifacts in disabled state when set to false"
}

variable "alarm_message_format" {
  type    = string
  default = "PRETTY_JSON"
  description = "Format of the message sent by Alarms"
  validation {
    condition = contains(["PRETTY_JSON", "ONS_OPTIMIZED", "RAW"], upper(var.alarm_message_format))
    error_message = "Validation failed for alarm_message_format: valid values (case insensitive) are PRETTY_JSON, RAW, or ONS_OPTIMIZED."
  }
}

# Cloud Guard related configuration
variable "cloud_guard_configuration_status" {
  default     = "ENABLE"
  description = "Determines whether a Cloud Guard target should be created for the Root compartment. If 'ENABLE', Cloud Guard is enabled and a target is created for the Root compartment. Make sure there is no pre-existing Cloud Guard target for the Root compartment or target creation will fail. If there's a pre-existing Cloud Guard target for the Root compartment, use 'DISABLE'. In this case, any pre-existing Cloud Guard Root target is left intact. However, keep in mind that once you use 'ENABLE', the Root target becomes managed by Landing Zone. If later on you switch to 'DISABLE', Cloud Guard remains enabled but the Root target is deleted."
  validation {
    condition     = contains(["ENABLE", "DISABLE"], upper(var.cloud_guard_configuration_status))
    error_message = "Validation failed for cloud_guard_configuration_status: valid values (case insensitive) are ENABLE or DISABLE."
  }
}

variable "cloud_guard_risk_level_threshold" {
  default     = "High"
  description = "Determines the minimum Risk level that triggers sending Cloud Guard problems to the defined Cloud Guard Email Endpoint. E.g. a setting of High will send notifications for Critical and High problems."
  validation {
    condition     = contains(["CRITICAL", "HIGH","MEDIUM","MINOR","LOW"], upper(var.cloud_guard_risk_level_threshold))
    error_message = "Validation failed for cloud_guard_risk_level_threshold: valid values (case insensitive) are CRITICAL, HIGH, MEDIUM, MINOR, LOW."
  }
}

# Security Zones related configurations
variable "enable_security_zones" {
  type        = bool
  default     = false
  description = "Determines if Security Zones are enabled in Landing Zone compartments."
}

variable "sz_security_policies" {
  type = list
  default = []
  description =  "Security Zones Policy OCIDs to add to security zone recipe."
    
}


# Service Connector Hub related configuration
variable "enable_service_connector" {
  description = "Whether Service Connector Hub should be enabled."
  type = bool
  default = false
}

variable "service_connector_name" {
  description = "The Service Connector display name."
  type        = string
  default     = "service-connector"
}

variable "service_connector_target_kind" {
  type        = string
  default     = "objectstorage"
  description = "Service Connector Hub target resource. Valid values are 'objectstorage', 'streaming' or 'functions'. In case of 'streaming', provide the stream name or ocid in 'service_connector_target_stream'. If a name is provided, a new stream is created. If an ocid is provided, the stream is used. In case of 'functions', you must provide the function ocid in 'service_connector_target_function_id'."
  validation {
    condition     = contains(["objectstorage", "streaming", "functions"], var.service_connector_target_kind)
    error_message = "Validation failed for service_connector_target_kind: valid values are objectstorage, streaming or functions."
  }
}

variable "service_connector_target_bucket_name" {
  description = "The Service Connector target Object Storage bucket name to be created. The bucket is created in Landing Zone's Security compartment."
  type        = string
  default     = "service-connector-bucket"
}

variable "service_connector_target_object_name_prefix" {
    description = "The Service Connector target Object Storage object name prefix."
    type = string
    default = "sch"
}

variable "service_connector_target_stream" {
    description = "The Service Connector target stream name or ocid. If a name is given, a new stream is created in Landing Zone's Security compartment. If an ocid is given, the existing stream is used (it's assumed to be available in Landing Zone's Security compartment)."
    type = string
    default = "service-connector-stream"
}

variable "service_connector_target_function_id" {
    description = "The Service Connector target function ocid in Landing Zone's Security compartment."
    type = string
    default = null
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

# Cost Management
variable "budget_alert_threshold" {
  type        = number
  default     = 100
  description = "The threshold for triggering the alert expressed as a percentage. 100% is the default."
  validation {
    condition     = var.budget_alert_threshold > 0 && var.budget_alert_threshold < 10000
    error_message = "Validation failed for budget_alert_threshold: The threshold percentage should be greater than 0 and less than or equal to 10,000, with no leading zeros and a maximum of 2 decimal places."
   }
}

variable "budget_amount" {
  type        = number
  default     = 1000
  description = "The amount of the budget expressed as a whole number in the currency of the customer's rate card"
}

variable "create_budget" {
  type        = bool
  default     = false
  description = "Create a budget."
}

variable "budget_alert_email_endpoints" {
  type        = list(string)
  default     = []
  description = "List of email addresses for all cost related notifications."
  validation {
    condition     = length([for e in var.budget_alert_email_endpoints : e if length(regexall("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", e)) > 0]) == length(var.budget_alert_email_endpoints)
    error_message = "Validation failed budget_alert_email_endpoints: invalid email address."
  }
}
