# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

##### The uncommented variable assignments below are for REQUIRED variables that do NOT have a default value in variables.tf. They must be provided appropriate values.
##### The commented variable assignments are for variables with a default value in variables.tf. For overriding them, uncomment the variable and provide an appropriate value.

# ------------------------------------------------------
# ----- Environment
# ------------------------------------------------------
tenancy_ocid         = "<tenancy_ocid>"
user_ocid            = "<user_ocid>"
fingerprint          = "<user_api_key_fingerprint>"
private_key_path     = "<path_to_user_private_key_file>"
private_key_password = ""
region               = "<tenancy_region>"
service_label        = "<a_label_to_prefix_resource_names_with>"
cis_level            = "1"

# ------------------------------------------------------
# ----- Environment - Multi-Region Landing Zone
#-------------------------------------------------------
# extend_landing_zone_to_new_region = false

# ------------------------------------------------------
# ----- IAM - Enclosing compartments
#-------------------------------------------------------
# use_enclosing_compartment           = true
# existing_enclosing_compartment_ocid = "<ocid>" # Compartment OCID where Landing Zone compartments are created.

# ------------------------------------------------------
# ----- IAM - Policies
#-------------------------------------------------------
# policies_in_root_compartment = "CREATE"
# enable_template_policies = false

# ------------------------------------------------------
# ----- IAM - Groups
#-------------------------------------------------------
# existing_iam_admin_group_name           = ["<group 1>","<group 2>","...","<group n>"] # list of groups to be used.  Spaces in names are allowed.
# existing_cred_admin_group_name          = ["<group 1>","<group 2>","...","<group n>"] # list of groups to be used.  Spaces in names are allowed.
# existing_security_admin_group_name      = ["<group 1>","<group 2>","...","<group n>"] # list of groups to be used.  Spaces in names are allowed.
# existing_network_admin_group_name       = ["<group 1>","<group 2>","...","<group n>"] # list of groups to be used.  Spaces in names are allowed.
# existing_appdev_admin_group_name        = ["<group 1>","<group 2>","...","<group n>"] # list of groups to be used.  Spaces in names are allowed.
# existing_database_admin_group_name      = ["<group 1>","<group 2>","...","<group n>"] # list of groups to be used.  Spaces in names are allowed.
# existing_auditor_group_name             = ["<group 1>","<group 2>","...","<group n>"] # list of groups to be used.  Spaces in names are allowed.
# existing_announcement_reader_group_name = ["<group 1>","<group 2>","...","<group n>"] # list of groups to be used.  Spaces in names are allowed.
# existing_exainfra_admin_group_name      = ["<group 1>","<group 2>","...","<group n>"] # list of groups to be used.  Spaces in names are allowed.
# existing_cost_admin_group_name          = ["<group 1>","<group 2>","...","<group n>"] # list of groups to be used.  Spaces in names are allowed.
# existing_storage_admin_group_name       = ["<group 1>","<group 2>","...","<group n>"] # list of groups to be used.  Spaces in names are allowed.

# ------------------------------------------------------
# ----- IAM - Dynamic Groups
#-------------------------------------------------------
# existing_security_fun_dyn_group_name  = "<existing_security_fun_dyn_group_name>"
# existing_appdev_fun_dyn_group_name    = "<existing_appdev_fun_dyn_group_name>"
# existing_compute_agent_dyn_group_name = "<existing_compute_agent_dyn_group_name>"
# existing_database_kms_dyn_group_name  = "<existing_database_kms_dyn_group_name>"

# ------------------------------------------------------
# ----- Networking - Generic VCNs
# ------------------------------------------------------
# vcn_cidrs     = ["10.0.0.0/20","<cidr_2>","...","<cidr_n>"] # list of CIDRs to be used when creating the VCNs. One CIDR to one VCN. Default: ["10.0.0.0/20"].
# vcn_names     = ["<name_1>,"<name_2>","...","<name_n>"] # list of VCN names to override default names with. One name to one CIDR, nth element to vcn_cidrs' nth element. 
# subnets_names = []
# subnets_sizes = []

# ------------------------------------------------------
# ----- Networking - Exadata Cloud Service VCNs
# ------------------------------------------------------
# exacs_vcn_cidrs           = ["<cidr_1>","<cidr_2>","...","<cidr_n>"] # list of CIDRs to be used when creating the VCNs. One CIDR to one VCN. 
# exacs_client_subnet_cidrs = ["<cidr_1>","<cidr_2>","...","<cidr_n>"] # list of CIDR blocks for the client subnets of Exadata Cloud Service VCNs, in CIDR notation. One subnet CIDR to one VCN CIDR, the nth element corresponding to exa_vcn_cidrs' nth element.
# exacs_backup_subnet_cidrs = ["<cidr_1>","<cidr_2>","...","<cidr_n>"] # list of CIDR blocks for the backup subnets of Exadata Cloud Service VCNs, in CIDR notation. One subnet CIDR to one VCN CIDR, the nth element corresponding to exa_vcn_cidrs' nth element.
# exacs_vcn_names           = ["<name_1>","<name_2>","...","<name_n>"] # list of VCN names to override default names with. One name to one VCN CIDR, the nth element corresponding to exa_vcn_cidrs' nth element. 
# deploy_exainfra_cmp       = true # whether to deploy a compartment for Exadata infrastructure.

# ------------------------------------------------------
# ----- Networking - Hub/Spoke
# ------------------------------------------------------
# hub_spoke_architecture = false # determines if a Hub & Spoke network architecture is to be deployed.  Allows for inter-spoke routing.
# dmz_vcn_cidr           = "<dmz_vcn_cidr>" # IP range in CIDR notation for the DMZ (a.k.a Hub) VCN.
# dmz_for_firewall       = false # whether a supported 3rd Party Firewall will be deployed in the DMZ.
# dmz_number_of_subnets  = 2 # number of subnets in DMZ VCN.
# dmz_subnet_size        = 4 # number of additional bits with which to extend the DMZ VCN CIDR prefix.

# ------------------------------------------------------
# ----- Networking - Public Connectivity
# ------------------------------------------------------
# no_internet_access       = false # whether the Landing Zone VCN(s) are Internet connected.
# public_src_lbr_cidrs     = ["<cidr_1>","<cidr_2>","...","<cidr_n>"] # external IP ranges in CIDR notation allowed to make HTTPS inbound connections.
# public_src_bastion_cidrs = ["<cidr_1>","<cidr_2>","...","<cidr_n>"] # external IP ranges in CIDR notation allowed to make SSH inbound connections. 0.0.0.0/0 is not allowed in the list.
# public_dst_cidrs         = ["<cidr_1>","<cidr_2>","...","<cidr_n>"] # external IP ranges in CIDR notation for HTTPS outbound connections.

# ------------------------------------------------------
# ----- Networking - Connectivity to On-Premises
# ------------------------------------------------------
# is_vcn_onprem_connected = false # determines if the Landing Zone VCN(s) are connected to an on-premises network. This must be true if no_internet_acess is true.
# onprem_cidrs            = ["<cidr_1>","<cidr_2>","...","<cidr_n>"] # list of on-premises CIDRs that are routeable to Landing Zone networks.
# onprem_src_ssh_cidrs    = ["<cidr_1>","<cidr_2>","...","<cidr_n>"] # list of on-premises CIDRs allowed to connect to Landing Zone networks over SSH. They must be a subset of onprem_cidrs.

# ------------------------------------------------------
# ----- Networking - DRG (Dynamic Routing Gateway)
# ------------------------------------------------------
# existing_drg_id = "" # the OCID of an existing DRG. If provided, no DRG is created even if is_vcn_onprem_connected is checked.

# ------------------------------------------------------
# ----- Events and Notifications
# ------------------------------------------------------
network_admin_email_endpoints    = ["<email1>","<email2>","...","<emailn>"] # list of email addresses for all network related notifications.
security_admin_email_endpoints   = ["<email1>","<e-mail2>","...","<emailn>"] # list of email addresses for all security related notifications.
# compute_admin_email_endpoints  = ["<email1>","<e-mail2>","...","<emailn>"] # list of email addresses for all compute related notifications.
# storage_admin_email_endpoints  = ["<email1>","<e-mail2>","...","<emailn>"] # list of email addresses for all storage related notifications.
# database_admin_email_endpoints = ["<email1>","<e-mail2>","...","<emailn>"] # list of email addresses for all database related notifications.
# exainfra_admin_email_endpoints = ["<email1>","<e-mail2>","...","<emailn>"] # list of email addresses for all Exadata infrastrcture related notifications.
# budget_admin_email_endpoints   = ["<email1>","<e-mail2>","...","<emailn>"] # list of email addresses for all budget related notifications.
# create_alarms_as_enabled       = false 
# create_events_as_enabled       = false 

# ------------------------------------------------------
# ----- Cloud Guard
# ------------------------------------------------------
# enable_cloud_guard                = true
# enable_cloud_guard_cloned_recipes = false
# cloud_guard_reporting_region      = null # if null, defaults to home region. 
# cloud_guard_risk_level_threshold  = "High" # Critical, High, Medium, Minor, Low. Determines the minimum Risk level that triggers sending Cloud Guard problems to the defined Cloud Guard Email Endpoint. E.g. a setting of High will send notifications for Critical and High problems.
# cloud_guard_admin_email_endpoints = ["<email1>","<e-mail2>","...","<emailn>"] # List of email addresses for Cloud Guard related notifications.

# ------------------------------------------------------
# ----- Security Zones 
# ------------------------------------------------------
# enable_security_zones = true
# sz_security_policies ["security-zone-policy-ocid","security-zone-policy-ocid"] # List of Security Zone Policy OCIDs to be added to Security Zones recipes. To get a Security Zone policy OCID use the oci cli:  oci cloud-guard security-policy-collection list-security-policies --compartment-id <tenancy-ocid> 


# ------------------------------------------------------
# ----- Service Connector Hub
# ------------------------------------------------------
# enable_service_connector                      = false # whether Service Connector Hub should be enabled. If true, all supporting resources are created, with Service Connector in INACTIVE state. To activate, set 'activate_service_connector' to true (costs may incur).
# activate_service_connector                    = false # whether Service Connector Hub should be activated. If true, sets Service Connector to ACTIVE. Costs my incur due to usage of Object Storage bucket, Streaming or Function.
# service_connector_target_kind                 = "objectstorage" # Service Connector Hub target resource. Valid values are 'objectstorage', 'streaming', 'functions' or 'logginganalytics'.
# existing_service_connector_bucket_vault_compartment_id = null # the OCID of an existing compartment for the vault with the key used in Object Storage bucket encryption used by Service Connector. Only applicable if 'service_connector_target_kind' is set to 'objectstorage'
# existing_service_connector_bucket_vault_id    = null # the OCID of an existing vault for the key used in Object Storage bucket encryption used by Service Connector. Only applicable if 'service_connector_target_kind' is set to 'objectstorage'
# existing_service_connector_bucket_key_id      = null # the OCID of an existing key used in Object Storage bucket encryption used by Service Connector. Only applicable if 'service_connector_target_kind' is set to 'objectstorage'
# existing_service_connector_target_stream_id   = null # the OCID of an existing stream to be used as the Service Connector target. Only applicable if 'service_connector_target_kind' is set to 'streaming'.
# existing_service_connector_target_function_id = null # the OCID of an existing function to be used as the Service Connector target. Only applicable if 'service_connector_target_kind' is set to 'functions'.


# ------------------------------------------------------
# ----- Vulnerability Scanning Service
# ------------------------------------------------------
# vss_create           = false      # whether Vulnerability Scanning Service recipes and targets are enabled.
# vss_scan_schedule    = "WEEKLY"   # the scan schedule for the Vulnerability Scanning Service recipe. Valid values are WEEKLY or DAILY (case insensitive).
# vss_scan_day         = "SUNDAY"   # the week day for the Vulnerability Scanning Service recipe, if enabled. Only applies if vss_scan_schedule is WEEKLY (case insensitive).
# vss_port_scan_level  = "STANDARD" # the port scan level. STANDARD, LIGHT or NONE (case insensitive).
# vss_agent_scan_level = "STANDARD" # the agent scan level. STANDARD or NONE (case insensitive).
# vss_agent_cis_benchmark_settings_scan_level = "MEDIUM" # the CIS benchmark level for agent-based scans. STRICT, MEDIUM, LIGHTWEIGHT or NONE (case insensitive)..
# vss_enable_file_scan = false   # whether file scanning is enabled for agent-based scans
# vss_folders_to_scan  = ["/"]   # folders to scan. Required if vss_enable_file_scan is true. 

# ------------------------------------------------------
# ----- Object Storage bucket
# ------------------------------------------------------
# enable_oss_bucket                    = true # "whether an Object Storage bucket should be enabled. If true, the bucket is managed in the application (AppDev) compartment."
# existing_bucket_vault_compartment_id = the OCID of an existing compartment for the vault with the key used in Object Storage bucket encryption.
# existing_bucket_vault_id             = the OCID of an existing vault for the key used in Object Storage bucket encryption.
# existing_bucket_key_id               = the OCID of an existing key used in Object Storage bucket encryption.

# ------------------------------------------------------
# ----- Cost Management - Budget
# ------------------------------------------------------
# budget_alert_threshold       = 100 # percentage of budget amount
# budget_amount                = 250 # monthly budget amount
# create_budget                = true # create a budget at the root or enclosing compartment level, depending on the value of "use_enclosing_compartment"
# budget_alert_email_endpoints = ["<email1>","<e-mail2>","...","<emailn>"] # list of email addresses for budget related alerts.