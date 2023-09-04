# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# ------------------------------------------------------
# ----- Environment
# ------------------------------------------------------
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
variable "service_label" {
  validation {
    condition     = length(regexall("^[A-Za-z][A-Za-z0-9]{1,7}$", var.service_label)) > 0
    error_message = "Validation failed for service_label: value is required and must contain alphanumeric characters only, starting with a letter up to a maximum of 8 characters."
  }
}
variable "cis_level" {
  type = string
  default = "2"
  description = "Determines CIS OCI Benchmark Level to apply on Landing Zone managed resources. Level 1 is be practical and prudent. Level 2 is intended for environments where security is more critical than manageability and usability. Level 2 drives the creation of an OCI Vault, buckets encryption with a customer managed key, write logs for buckets and the usage of specific policies in Security Zones."
}
variable "env_advanced_options" {
  type = bool
  default = false
} 

# ------------------------------------------------------
# ----- Environment - Multi-Region Landing Zone
#-------------------------------------------------------
variable "extend_landing_zone_to_new_region" {
  default = false
  type    = bool
  description = "Whether Landing Zone is being extended to another region. When set to true, compartments, groups, policies and resources at the home region are not provisioned. Use this when you want provision a Landing Zone in a new region, but reuse existing Landing Zone resources in the home region."
}

# ------------------------------------------------------
# ----- IAM - Enclosing compartments
#-------------------------------------------------------
variable "use_enclosing_compartment" {
  type        = bool
  default     = true
  description = "Whether the Landing Zone compartments are created within an enclosing compartment. If false, the Landing Zone compartments are created under the root compartment. The recommendation is to utilize an enclosing compartment."
}
variable "existing_enclosing_compartment_ocid" {
  type        = string
  default     = null
  description = "The enclosing compartment OCID where Landing Zone compartments will be created. If not provided and use_enclosing_compartment is true, an enclosing compartment is created under the root compartment."
}

# ------------------------------------------------------
# ----- IAM - Policies
#-------------------------------------------------------
variable "policies_in_root_compartment" {
  type        = string
  default     = "CREATE"
  description = "Whether required grants at the root compartment should be created or simply used. Valid values: 'CREATE' and 'USE'. If 'CREATE', make sure the user executing this stack has permissions to create grants in the root compartment. If 'USE', no grants are created."
  validation {
    condition     = contains(["CREATE", "USE"], var.policies_in_root_compartment)
    error_message = "Validation failed for policies_in_root_compartment: valid values are CREATE or USE."
  }
}

variable "enable_template_policies" {
  type = bool
  default = false
  description = "Whether policies should be created based on metadata associated to compartments. This is an alternative way of managing policies, enabled by the CIS Landing Zone standalone IAM policy module: https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam/tree/main/policies. When set to true, the grants to resources belonging to a specific compartment are combined into a single policy that is attached to the compartment itself. This differs from the default approach, where grants are combined per grantee and attached to the enclosing compartment."
}

# ------------------------------------------------------
# ----- IAM - Groups
#-------------------------------------------------------
variable "rm_existing_iam_admin_group_name" {
  type    = string
  default = ""
}
variable "existing_iam_admin_group_name" {
  type        = list(string)
  default     = []
  description = "List of groups for iam administrators."
}

variable "rm_existing_cred_admin_group_name" {
  type    = string
  default = ""
}
variable "existing_cred_admin_group_name" {
  type        = list(string)
  default     = []
  description = "List of groups for credential administrators."
}

variable "rm_existing_security_admin_group_name" {
  type    = string
  default = ""
}
variable "existing_security_admin_group_name" {
  type        = list(string)
  default     = []
  description = "List of groups for security administrators."
}


variable "rm_existing_network_admin_group_name" {
  type    = string
  default = ""
}
variable "existing_network_admin_group_name" {
  type        = list(string)
  default     = []
  description = "List of groups for network administrators."
}

variable "rm_existing_appdev_admin_group_name" {
  type    = string
  default = ""
}
variable "existing_appdev_admin_group_name" {
  type        = list(string)
  default     = []
  description = "List of groups for appdev administrators."
}

variable "rm_existing_database_admin_group_name" {
  type    = string
  default = ""
}
variable "existing_database_admin_group_name" {
  type        = list(string)
  default     = []
  description = "List of groups for database administrators."
}

variable "rm_existing_auditor_group_name" {
  type    = string
  default = ""
}
variable "existing_auditor_group_name" {
  type        = list(string)
  default     = []
  description = "List of groups for auditors."
}

variable "rm_existing_announcement_reader_group_name" {
  type    = string
  default = ""
}
variable "existing_announcement_reader_group_name" {
  type        = list(string)
  default     = []
  description = "List of groups for announcement readers."
}

variable "rm_existing_exainfra_admin_group_name" {
  type    = string
  default = ""
}
variable "existing_exainfra_admin_group_name" {
  type        = list(string)
  default     = []
  description = "List of groups for exainfra administrators."
}

variable "rm_existing_cost_admin_group_name" {
  type    = string
  default = ""
}
variable "existing_cost_admin_group_name" {
  type        = list(string)
  default     = []
  description = "List of groups for cost administrators."
}

variable "rm_existing_storage_admin_group_name" {
  type    = string
  default = ""
}
variable "existing_storage_admin_group_name" {
  type        = list(string)
  default     = []
  description = "List of groups for storage administrators."
}

# ------------------------------------------------------
# ----- IAM - Dynamic Groups
#-------------------------------------------------------
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

# ------------------------------------------------------
# ----- Networking - Generic VCNs
# ------------------------------------------------------
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
variable "net_advanced_options" {
  type = bool
  default = false
} 

# ------------------------------------------------------
# ----- Networking - Exadata Cloud Service VCNs
# ------------------------------------------------------
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
variable "exa_advanced_options" {
  type = bool
  default = false
}

# ------------------------------------------------------
# ----- Networking - Hub/Spoke
# ------------------------------------------------------
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
variable "hs_advanced_options" {
  type = bool
  default = false
}

# ------------------------------------------------------
# ----- Networking - Public Connectivity
# ------------------------------------------------------
variable "no_internet_access" {
  default     = false
  type        = bool
  description = "Determines if the network will have direct access to the internet. If false, an Internet Gateway and NAT Gateway are created. If true, Internet Gateway and NAT Gateway are NOT created and both is_vcn_onprem_connected and onprem_cidr become required."
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

# ------------------------------------------------------
# ----- Networking - Connectivity to On-Premises
# ------------------------------------------------------
 variable "is_vcn_onprem_connected" {
  type        = bool
  default     = false
  description = "Whether the VCNs are connected to the on-premises network, in which case a DRG is created and attached to the VCNs. This must be true if 'no_internet_access' is true and 'existing_drg_id' is not provided."
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

# ------------------------------------------------------
# ----- Networking - DRG (Dynamic Routing Gateway)
# ------------------------------------------------------
variable "existing_drg_id" {
  type        = string
  default     = ""
  description = "The OCID of an existing DRG, used in Hub/Spoke and when connecting to On-Premises network. Provide a value if you want the Landing Zone to not deploy a DRG."
}

# ------------------------------------------------------
# ----- Events and Notifications
# ------------------------------------------------------
variable "network_admin_email_endpoints" {
  type        = list(string)
  default     = []
  description = "List of email addresses for all network related notifications."
  validation {
    condition = length(var.network_admin_email_endpoints) > 0
    error_message = "Validation failed for network_admin_email_endpoints: at least one valid email address must be provided."
  }
  validation {
    condition     = length([for e in var.network_admin_email_endpoints : e if length(regexall("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", e)) > 0]) == length(var.network_admin_email_endpoints)
    error_message = "Validation failed for network_admin_email_endpoints: invalid email address."
  }
}
variable "security_admin_email_endpoints" {
  type        = list(string)
  default     = []
  description = "List of email addresses for all security related notifications."
  validation {
    condition = length(var.security_admin_email_endpoints) > 0
    error_message = "Validation failed for security_admin_email_endpoints: at least one valid email address must be provided."
  }
  validation {
    condition     = length([for e in var.security_admin_email_endpoints : e if length(regexall("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", e)) > 0]) == length(var.security_admin_email_endpoints)
    error_message = "Validation failed for security_admin_email_endpoints: invalid email address."
  }
}
variable "storage_admin_email_endpoints" {
  type        = list(string)
  default     = []
  description = "List of email addresses for all storage related notifications."
  validation {
    condition     = length([for e in var.storage_admin_email_endpoints : e if length(regexall("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", e)) > 0]) == length(var.storage_admin_email_endpoints)
    error_message = "Validation failed for storage_admin_email_endpoints: invalid email address."
  }
}
variable "compute_admin_email_endpoints" {
  type        = list(string)
  default     = []
  description = "List of email addresses for all compute related notifications."
  validation {
    condition     = length([for e in var.compute_admin_email_endpoints : e if length(regexall("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", e)) > 0]) == length(var.compute_admin_email_endpoints)
    error_message = "Validation failed for compute_admin_email_endpoints: invalid email address."
  }
}
variable "budget_admin_email_endpoints" {
  type        = list(string)
  default     = []
  description = "List of email addresses for all budget related notifications."
  validation {
    condition     = length([for e in var.budget_admin_email_endpoints : e if length(regexall("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", e)) > 0]) == length(var.budget_admin_email_endpoints)
    error_message = "Validation failed for budget_admin_email_endpoints: invalid email address."
  }
}
variable "database_admin_email_endpoints" {
  type        = list(string)
  default     = []
  description = "List of email addresses for all database related notifications."
  validation {
    condition     = length([for e in var.database_admin_email_endpoints : e if length(regexall("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", e)) > 0]) == length(var.database_admin_email_endpoints)
    error_message = "Validation failed for database_admin_email_endpoints: invalid email address."
  }
}
variable "exainfra_admin_email_endpoints" {
  type        = list(string)
  default     = []
  description = "List of email addresses for all Exadata infrastrcture related notifications. Only applicable if deploy_exainfra_cmp is true."
  validation {
    condition     = length([for e in var.exainfra_admin_email_endpoints : e if length(regexall("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", e)) > 0]) == length(var.exainfra_admin_email_endpoints)
    error_message = "Validation failed for exainfra_admin_email_endpoints: invalid email address."
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
variable "notifications_advanced_options" {
  type = bool
  default = false
}

# ------------------------------------------------------
# ----- Cloud Guard
# ------------------------------------------------------
variable "enable_cloud_guard" {
  type = bool
  description = "Determines whether the Cloud Guard service should be enabled. If true, Cloud Guard is enabled and the Root compartment is configured with a Cloud Guard target, as long as there is no pre-existing Cloud Guard target for the Root compartment (or target creation will fail). Keep in mind that once you set this to true, Cloud Guard target is managed by Landing Zone. If later on you switch this to false, the managed target is deleted and all (open, resolved and dismissed) problems associated with the deleted target are being moved to 'deleted' state. This operation happens in the background and would take some time to complete. Deleted problems can be viewed from the problems page using the 'deleted' status filter. For more details on Cloud Guard problems lifecycle, see https://docs.oracle.com/en-us/iaas/cloud-guard/using/problems-page.htm#problems-page__sect_prob_lifecycle. If Cloud Guard is already enabled and a target exists for the Root compartment, set this variable to false."
  default = true
}
variable "enable_cloud_guard_cloned_recipes" {
  type = bool
  description = "Whether cloned recipes are attached to the managed Cloud Guard target. If false, Oracle managed recipes are attached."
  default = false
}
variable "cloud_guard_reporting_region" {
  description = "Cloud Guard reporting region, where Cloud Guard reporting resources are kept. If not set, it defaults to home region."
  type = string
  default = null
}
variable "cloud_guard_risk_level_threshold" {
  default     = "High"
  description = "Determines the minimum Risk level that triggers sending Cloud Guard problems to the defined Cloud Guard Email Endpoint. E.g. a setting of High will send notifications for Critical and High problems."
  validation {
    condition     = contains(["CRITICAL", "HIGH","MEDIUM","MINOR","LOW"], upper(var.cloud_guard_risk_level_threshold))
    error_message = "Validation failed for cloud_guard_risk_level_threshold: valid values (case insensitive) are CRITICAL, HIGH, MEDIUM, MINOR, LOW."
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

# ------------------------------------------------------
# ----- Security Zones
# ------------------------------------------------------
variable "enable_security_zones" {
    type        = bool
    default     = false
    description = "Determines if Security Zones are enabled in Landing Zone. When set to true, the Security Zone is enabled for the enclosing compartment. If no enclosing compartment is used, then the Security Zone is not enabled."
  }
  
  variable "sz_security_policies" {
    type = list
    default = []
    description =  "List of Security Zones Policy OCIDs to add to security zone recipe. To get a Security Zone policy OCID use the oci cli:  oci cloud-guard security-policy-collection list-security-policies --compartment-id <tenancy-ocid>."
    validation {
      condition = length([for e in var.sz_security_policies : e if length(regexall("ocid1.securityzonessecuritypolicy.*", e)) > 0]) == length(var.sz_security_policies)
      error_message = "Validation failed for sz_security_policies must be a valid Security Zone Policy OCID.  To get a Security Zone policy OCID use the oci cli:  oci cloud-guard security-policy-collection list-security-policies --compartment-id <tenancy-ocid>."
    }
  }
# ------------------------------------------------------
# ----- Service Connector Hub
# ------------------------------------------------------
variable "enable_service_connector" {
  description = "Whether Service Connector Hub should be enabled. If true, a single Service Connector is managed for all services log sources and the designated target specified in 'service_connector_target_kind'. The Service Connector resource is created in INACTIVE state. To activate, set 'activate_service_connector' to true (costs may incur)."
  type = bool
  default = false
}
variable "activate_service_connector" {
  description = "Whether Service Connector Hub should be activated. If true, costs my incur due to usage of Object Storage bucket, Streaming or Function."
  type = bool
  default = false
}
variable "service_connector_target_kind" {
  type        = string
  default     = "objectstorage"
  description = "Service Connector Hub target resource. Valid values are 'objectstorage', 'streaming', 'functions' or 'logginganalytics'. In case of 'objectstorage', a new bucket is created. In case of 'streaming', you can provide an existing stream ocid in 'existing_service_connector_target_stream_id' and that stream is used. If no ocid is provided, a new stream is created. In case of 'functions', you must provide the existing function ocid in 'existing_service_connector_target_function_id'. If case of 'logginganalytics', a log group for Logging Analytics service is created and the service is enabled if not already."
  validation {
    condition     = contains(["objectstorage", "streaming", "functions", "logginganalytics"], var.service_connector_target_kind)
    error_message = "Validation failed for service_connector_target_kind: valid values are objectstorage, streaming, functions or logginganalytics."
  }
}
variable "existing_service_connector_bucket_vault_compartment_id" {
  description = "The OCID of an existing compartment for the vault with the key used in Service Connector target Object Storage bucket encryption. Only applicable if 'service_connector_target_kind' is set to 'objectstorage'."
  type = string
  default = null
}
variable "existing_service_connector_bucket_vault_id" {
  description = "The OCID of an existing vault for the encryption key used in Service Connector target Object Storage bucket. Only applicable if 'service_connector_target_kind' is set to 'objectstorage'."
  type = string
  default = null
}
variable "existing_service_connector_bucket_key_id" {
  description = "The OCID of an existing encryption key used in Service Connector target Object Storage bucket. Only applicable if 'service_connector_target_kind' is set to 'objectstorage'."
  type = string
  default = null
}
variable "existing_service_connector_target_stream_id" {
    description = "The OCID of an existing stream to be used as the Service Connector target. Only applicable if 'service_connector_target_kind' is set to 'streaming'."
    type = string
    default = "service-connector-stream"
}
variable "existing_service_connector_target_function_id" {
    description = "The OCID of an existing function to be used as the Service Connector target. Only applicable if 'service_connector_target_kind' is set to 'functions'."
    type = string
    default = null
}

# ------------------------------------------------------
# ----- Vulnerability Scanning Service
# ------------------------------------------------------
variable "vss_create" {
  description = "Whether Vulnerability Scanning Service recipes and targets are enabled in the Landing Zone."
  type        = bool
  default     = false
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
variable "vss_port_scan_level" {
  description = "Valid values: STANDARD, LIGHT, NONE. STANDARD checks the 1000 most common port numbers, LIGHT checks the 100 most common port numbers, NONE does not check for open ports."
  type = string
  default = "STANDARD"
  validation {
    condition     = contains(["STANDARD", "LIGHT", "NONE"], upper(var.vss_port_scan_level))
    error_message = "Validation failed for vss_port_scan_level: valid values are STANDARD, LIGHT, NONE (case insensitive)."
  }
}
variable "vss_agent_scan_level" {
  description = "Valid values: STANDARD, NONE. STANDARD enables agent-based scanning. NONE disables agent-based scanning and moots any agent related attributes."
  type = string
  default = "STANDARD"
  validation {
    condition     = contains(["STANDARD", "NONE"], upper(var.vss_agent_scan_level))
    error_message = "Validation failed for vss_agent_scan_level: valid values are STANDARD, NONE (case insensitive)."
  }
}
variable "vss_agent_cis_benchmark_settings_scan_level" {
  description = "Valid values: STRICT, MEDIUM, LIGHTWEIGHT, NONE. STRICT: If more than 20% of the CIS benchmarks fail, then the target is assigned a risk level of Critical. MEDIUM: If more than 40% of the CIS benchmarks fail, then the target is assigned a risk level of High. LIGHTWEIGHT: If more than 80% of the CIS benchmarks fail, then the target is assigned a risk level of High. NONE: disables cis benchmark scanning."
  type = string
  default = "MEDIUM"
  validation {
    condition     = contains(["STRICT", "MEDIUM", "LIGHTWEIGHT", "NONE"], upper(var.vss_agent_cis_benchmark_settings_scan_level))
    error_message = "Validation failed for vss_agent_cis_benchmark_settings_scan_level: valid values are STRICT, MEDIUM, LIGHTWEIGHT, NONE (case insensitive)."
  }
}
variable "vss_enable_file_scan" {
  description = "Whether file scanning is enabled."
  type        = bool
  default     = false
}
variable "vss_folders_to_scan" {
  description = "A list of folders to scan. Only applies if vss_enable_file_scan is true. Currently, the Scanning service checks for vulnerabilities only in log4j and spring4shell."
  type = list(string)
  default = ["/"]
}

# ------------------------------------------------------
# ----- Object Storage
# ------------------------------------------------------
variable "enable_oss_bucket" {
  description = "Whether an Object Storage bucket should be enabled. If true, the bucket is managed in the application (AppDev) compartment."
  type = bool
  default = true
}
variable "existing_bucket_vault_compartment_id" {
  description = "The OCID of an existing compartment for the vault with the key used in Object Storage bucket encryption."
  type = string
  default = null
}
variable "existing_bucket_vault_id" {
  description = "The OCID of an existing vault for the key used in Object Storage bucket encryption."
  type = string
  default = null
}
variable "existing_bucket_key_id" {
  description = "The OCID of an existing key used in Object Storage bucket encryption."
  type = string
  default = null
}
# ------------------------------------------------------
# ----- Cost Management - Budget
# ------------------------------------------------------
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