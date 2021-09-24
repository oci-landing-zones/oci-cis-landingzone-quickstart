## <a name="config_input_variables"></a>Config Module Input Variables
Input variables used in the config module are all defined in config/variables.tf:

### <a name="env_variables"></a>Environment Variables
Variable Name | Description | Required | Default Value
--------------|-------------|----------|--------------
**tenancy_ocid** | the OCI tenancy id where this configuration will be executed. This information can be obtained in OCI Console. | Yes | None
**user_ocid** | the OCI user id that will execute this configuration. This information can be obtained in OCI Console. The user must have the necessary privileges to provision the resources. | Yes | ""
**fingerprint** | the user's public key fingerprint. This information can be obtained in OCI Console. | Yes | ""
**private_key_path** | the local path to the user private key. | Yes | ""
**private_key_password** | the private key password, if any. | No | ""
**region** \* | the tenancy region identifier where the Terraform should provision the resources. | Yes | None
**service_label** | a label used as a prefix for naming resources. | Yes | None

\* For a list of available regions, please see https://docs.cloud.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm

### <a name="enc_cmp_variables"></a>Enclosing Compartment Variables
Variable Name | Description | Required | Default Value
--------------|-------------|----------|--------------
**use_enclosing_compartment** | A boolean flag indicating whether or not to provision the Landing Zone within an enclosing compartment other than the root compartment. **When provisioning the Landing Zone as a _narrower-permissioned_ user, make sure to set this variable value to true**. | Yes | false
**existing_enclosing_compartment_ocid** | The OCID of a pre-existing enclosing compartment where Landing Zone compartments are to be created. If *use_enclosing_compartment* is false, the module creates the Landing Zone compartments in the root compartment as long as the executing user has the required permissions. | No | None
**policies_in_root_compartment** | The Landing Zone requires policies attached to the root compartment to work at full capacity. For instance, security administrators are expect to manage Cloud Guard, Tag Namespaces, Tag Defaults, Event Rules, and others. Likewise, IAM administrators are expected to manage IAM resources in general. Such capabilities are only enabled if policies are created at the root compartment, as they apply to the tenancy as a whole. A *narrower-permissioned* user will not likely have the permissions to create such policies. As a consequence, it is expected that these policies are previously created by a *wide-permissioned* user. Therefore, **when provisioning the Landing Zone as a _narrower-permissioned_ user, make sure to set this variable value to "USE", in which case permissions are not created at the root compartment**. Default is "CREATE", meaning the module will provision the policies at the root compartment, as long as the executing user has the required permissions. | Yes | "CREATE"

### <a name="existing_groups_variables"></a>Existing Groups Reuse Variables
Variable Name | Description | Required | Default Value
--------------|-------------|----------|--------------
**use_existing_groups** | Whether or not existing groups are to be reused for this Landing Zone. If false, one set of groups is created. If true, existing group names must be provided and this set will be able to manage resources in this Landing Zone. | Yes | false
**existing_iam_admin_group_name** | The name of an existing group for IAM administrators. | Yes, if *use_existing_groups* is true | None
**existing_cred_admin_group_name** | The name of an existing group for credential administrators. | Yes, if *use_existing_groups* is true | None
**existing_security_admin_group_name** | The name of an existing group for security administrators. | Yes, if *use_existing_groups* is true | None
**existing_network_admin_group_name** | The name of an existing group for network administrators. | Yes, if *use_existing_groups* is true | None
**existing_appdev_admin_group_name** | The name of an existing group for application development administrators. | Yes, if *use_existing_groups* is true | None
**existing_database_admin_group_name** | The name of an existing group for database administrators. | Yes, if *use_existing_groups* is true | None
**existing_auditor_group_name** | The name of an existing group for auditors. | Yes, if *use_existing_groups* is true | None
**existing_announcement_reader_group_name** | The name of an existing group for announcement readers. | Yes, if *use_existing_groups* is true | None

### <a name="networking_variables"></a>Networking Variables
Variable Name | Description | Required | Default Value
--------------|-------------|----------|--------------
**vcn_cidrs** | List of CIDR blocks for the VCNs to be created in CIDR notation. If hub_spoke_architecture is true, these VCNs are turned into spoke VCNs. | No | []
**vcn_names** | List of custom names to be given to the VCNs, overriding the default VCN names (*service_label*-*index*-vcn). The list length and elements order must match *vcn_cidrs*'. | No | []
**is_vcn_onprem_connected** | Whether the VCNs are connected to the on-premises network, in which case a DRG is created and attached to the VCNs. | No | false
**existing_drg_id** | The OCID of an existing DRG. If provided, no DRG is created even if *is_vc_onprem_connected* is set to true.  | No | ""
**hub_spoke_architecture** | Determines if a Hub & Spoke network architecture is to be deployed.  Allows for inter-spoke routing. | No | false
**dmz_vcn_cidr** | CIDR block for the DMZ VCN. DMZ VCNs are commonly used for network appliance deployments. All traffic will be routed through the DMZ. | Yes, if *hub_spoke_architecture* is true | ""
**dmz_for_firewall** | Determines if the DMZ VCN will be used for deploying 3rd party firewalls via terraform. DRG attachments will not be created. | No | false
**dmz_number_of_subnets** | The number of subnets to be created in the DMZ VCN. If using the DMZ VCN for a network appliance deployment, please see the vendor's documentation or OCI reference architecture to determine the number of subnets required. | Yes, if *dmz_vcn_cidr* is provided  | 2
**dmz_subnet_size** | The number of additional bits with which to extend the DMZ VCN CIDR prefix. For instance, if *dmz_vcn_cidr*'s prefix is 20 (/20) and *dmz_subnet_size* is 4, subnets are going to be /24. | Yes, if *dmz_vcn_cidr* is provided  | 4

### <a name="exadata_variables"></a>Exadata Cloud Service Variables
Variable Name | Description | Required | Default Value
--------------|-------------|----------|--------------
**exacs_vcn_cidrs** | List of CIDR blocks for the Exadata VCNs, in CIDR notation. Each provided CIDR relates to one and only one VCN. Be mindful about Exadata *Requirements for IP Address Space* in <a href="https://docs.oracle.com/en-us/iaas/Content/Database/Tasks/exanetwork.htm">OCI documentation</a>. You can provide up to nine CIDRs. | No | []
**exacs_vcn_names** | List of Exadata VCNs custom names, overriding the default Exadata VCNs names. Each provided name relates to one and only one VCN, the *nth* value applying to the *nth* value in *exacs_vcn_cidrs*. You can provide up to nine names. | No | []
**exacs_client_subnet_cidrs** | List of CIDR blocks for the client subnets of Exadata Cloud Service VCNs, in CIDR notation. Each provided CIDR value relates to one and only one VCN, the *nth* value applying to the *nth* value in *exacs_vcn_cidrs*. CIDRs must not overlap with 192.168.128.0/20. You can provide up to nine CIDRs. | No | []
**exacs_backup_subnet_cidrs** | List of CIDR blocks for the backup subnets of Exadata Cloud Service VCNs, in CIDR notation. Each provided CIDR value relates to one and only one VCN, the *nth* value applying to the *nth* value in *exacs_vcn_cidrs*. CIDRs must not overlap with 192.168.128.0/20. You can provide up to nine CIDRs.| No | []
**exacs_vcn_cidrs** | Whether a compartment for Exadata infrastructure should be created. If false, Exadata infrastructure should be created in the database compartment. | No | true

### <a name="connectivity_variables"></a>Connectivity Variables
Variable Name | Description | Required | Default Value
--------------|-------------|----------|--------------
**no_internet_access** | Determines if the VCNs are directly connected to the Internet. If false, an Internet Gateway and NAT Gateway are created for Internet connectivity. If true, Internet Gateway and NAT Gateway are NOT created and it becomes required to set *is_vcn_onprem_connected* to true. | No | false
**public_src_bastion_cidrs** | List of external IP ranges in CIDR notation allowed to make SSH inbound connections. 0.0.0.0/0 is not allowed in the list. | No | []
**public_src_lbr_cidrs** | List of external IP ranges in CIDR notation allowed to make HTTPS inbound connections. | No | []
**public_dst_cidrs** | List of external IP ranges in CIDR notation for HTTPS outbound connections. | No | []
**onprem_cidrs** | List of on-premises CIDR blocks allowed to connect to the Landing Zone network via a DRG. | No | []
**onprem_src_ssh_cidrs** | List of on-premises IP ranges allowed to make SSH inbound connections. It must be a subset of *onprem_cidrs*. | No | []

### <a name="notification_variables"></a>Notification Variables
Variable Name | Description | Required | Default Value
--------------|-------------|----------|--------------
**network_admin_email_endpoints** | A list of email addresses to receive notifications for network related events. | Yes | None
**security_admin_email_endpoints** | A list of email addresses to receive notifications for security related events. | Yes | None

### <a name="cloudguard_variables"></a>Cloud Guard Variables
Variable Name | Description | Required | Default Value
--------------|-------------|----------|--------------
**cloud_guard_configuration_status** | Determines whether Cloud Guard should be enabled in the tenancy. If 'ENABLE', a target is created for the Root compartment. | No | ENABLE

### <a name="logging_variables"></a>Logging Variables
Variable Name | Description | Required | Default Value
--------------|-------------|----------|--------------
**create_service_connector_audit** | Whether to create Service Connector Hub for Audit logs. | No | false
**service_connector_audit_target** | Destination for Service Connector Hub for Audit Logs. Valid values are 'objectstorage', 'streaming' and 'functions'. | No | "objectstorage"
**service_connector_audit_state** | State in which to create the Service Connector Hub for Audit logs. Valid values are 'ACTIVE' and 'INACTIVE'. | No | "INACTIVE"
**service_connector_audit_target_OCID** | Applicable only for streaming/functions target types. OCID of stream/function target for the Service Connector Hub for Audit logs. | No | None
**service_connector_audit_target_cmpt_OCID** | Applicable only for streaming/functions target types. OCID of compartment containing the stream/function target for the Service Connector Hub for Audit logs. | No | None
**sch_audit_target_rollover_MBs** | Applicable only for objectstorage target type. Target rollover size in MBs for Audit logs. | No | 100
**sch_audit_target_rollover_MSs** | Applicable only for objectstorage target type. Target rollover time in MSs for Audit logs. | No | 420000
**sch_audit_objStore_objNamePrefix** | Applicable only for objectstorage target type. The prefix for the objects for Audit logs. | No | "sch-audit"
**create_service_connector_vcnFlowLogs** | Whether to create Service Connector Hub for VCN Flow logs. | No | false
**service_connector_vcnFlowLogs_target** | Destination for Service Connector Hub for VCN Flow Logs. Valid values are 'objectstorage', 'streaming' and 'functions'. | No | "objectstorage"
**service_connector_vcnFlowLogs_state** | State in which to create the Service Connector Hub for VCN Flow logs. Valid values are 'ACTIVE' and 'INACTIVE'. | No | "INACTIVE"
**service_connector_vcnFlowLogs_target_OCID** | Applicable only for streaming/functions target types. OCID of stream/function target for the Service Connector Hub for VCN Flow logs. | No | None
**service_connector_vcnFlowLogs_target_cmpt_OCID** | Applicable only for streaming/functions target types. OCID of compartment containing the stream/function target for the Service Connector Hub for VCN Flow logs. | No | None
**sch_vcnFlowLogs_target_rollover_MBs** | Applicable only for objectstorage target type. Target rollover size in MBs for VCN Flow logs. | No | 100
**sch_vcnFlowLogs_target_rollover_MSs** | Applicable only for objectstorage target type. Target rollover time in MSs for VCN Flow logs. | No | 420000
**sch_vcnFlowLogs_objStore_objNamePrefix** | Applicable only for objectstorage target type. The prefix for the objects for VCN Flow logs.| No | "sch-vcnFlowLogs"	

### <a name="vss_variables"></a>Scanning Variables
Variable Name | Description | Required | Default Value
--------------|-------------|----------|--------------
**vss_create** | Whether or not Vulnerability Scanning Service (VSS) recipes and targets are to be created in the Landing Zone. | No | true
**vss_scan_schedule** | The scan schedule for the VSS recipe, if enabled. Valid values are WEEKLY or DAILY. | No | "WEEKLY"
**vss_scan_day** | The week day for the VSS recipe, if enabled. Only applies if vss_scan_schedule is WEEKLY. | No | "SUNDAY"

## <a name="pre_config_input_variables"></a>Pre-Config Module Input Variables
Input variables used in the pre-config module are all defined in pre-config/variables.tf:

Variable Name | Description | Required | Default Value
--------------|-------------|----------|--------------
**unique_prefix** | A label that gets prefixed to all default resource names created by the module. | No | None
**enclosing_compartment_names** | A list of compartment names that will hold the Landing Zone compartments. If no compartment name is given, the module creates one compartment with a default name ending in *-top-cmp*. | No | "*unique_prefix*-top-cmp" or "lz-top-cmp"
**existing_enclosing_compartments_parent_ocid** | the parent compartment ocid of the top compartment, indicating where to insert the enclosing compartment in the hierarchy. Remember that OCI has a max six level compartment hierarchy. If you create the enclosing compartment at level five, the Landing Zone compartments will be at level six and adding sub-compartments to Landing Zone compartments will not be possible. | No | *tenancy_ocid*	
**use_existing_provisioning_group** | A boolean flag indicating whether or not an existing group will be used for Landing Zone provisioning. If false, one group is created for each compartment defined by *enclosing_compartment_names* variable. | Yes | false
**existing_provisioning_group_name(\*)** | The name of an existing group to be used for provisioning all resources in the compartments defined by *enclosing_compartment_names* variable. Ignored if *use_existing_provisioning_group* is false. | No | None
**grant_services_policies** | Whether services policies should be granted. If these policies already exist in the root compartment, set it to false for avoiding policies duplication. Useful if the module is reused across distinct stacks or configurations. | Yes | true
**use_existing_groups** | A boolean flag indicating whether or not existing groups are to be reused for Landing Zone. If false, one set of groups is created for each compartment defined by *enclosing_compartment_names* variable. If true, existing group names must be provided and this single set will be able to manage resources in all those compartments. | Yes | false 
**existing_iam_admin_group_name** | The name of an existing group for IAM administrators. | Yes, if *use_existing_groups* is true. | None
**existing_cred_admin_group_name** | The name of an existing group for credential administrators. | Yes, if *use_existing_groups* is true. | None
**existing_security_admin_group_name** | The name of an existing group for security administrators. | Yes, if *use_existing_groups* is true. | None
**existing_network_admin_group_name** | The name of an existing group for network administrators. | Yes, if *use_existing_groups* is true. | None
**existing_appdev_admin_group_name** | The name of an existing group for application development administrators. | Yes, if *use_existing_groups* is true. | None
**existing_database_admin_group_name** | The name of an existing group for database administrators. | Yes, if *use_existing_groups* is true. | None
**existing_auditor_group_name** | The name of an existing group for auditors. | Yes, if *use_existing_groups* is true. | None
**existing_announcement_reader_group_name** | The name of an existing group for announcement readers. | Yes, if *use_existing_groups* is true. | None

(*) A user with an API key must be assigned to the provisioning group. The module does not create or assign the user.
