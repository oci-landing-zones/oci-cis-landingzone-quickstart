## How the Terraform Code is Organized 
The Terraform code consists of a single root module configuration defined within the *config* folder along with a few children modules within the *modules* folder.

Within the config folder, the Terraform files are named after the use cases they implement as described in CIS OCI Security Foundation Benchmark document. For instance, iam_1.1.tf implements use case 1.1 in the IAM sectiom, while mon_3.5.tf implements use case 3.5 in the Monitoring section. .tf files with no numbering scheme are either Terraform suggested names for Terraform constructs (provider.tf, variables.tf, locals.tf, outputs.tf) or use cases supporting files (iam_compartments.tf, net_vcn.tf).

**Note**: The code has been written and tested with Terraform version 0.13.5 and OCI provider version 4.2.0.

## <a name="input_variables"></a>Input Variables
Input variables used in the configuration are all defined in config/variables.tf:

### <a name="env_variables"></a>Environment Variables
Variable Name | Description | Required | Default Value
--------------|-------------|----------|--------------
**tenancy_ocid** | the OCI tenancy id where this configuration will be executed. This information can be obtained in OCI Console | Yes | None
**user_ocid** | the OCI user id that will execute this configuration. This information can be obtained in OCI Console. The user must have the necessary privileges to provision the resources | Yes | ""
**fingerprint** | the user's public key fingerprint. This information can be obtained in OCI Console | Yes | ""
**private_key_path** | the local path to the user private key | Yes | ""
**private_key_password** | the private key password, if any | No | ""
**region** \* | the tenancy region identifier where the Terraform should provision the resources | Yes | None
**service_label** | a label used as a prefix for naming resources | Yes | None

\* For a list of available regions, please see https://docs.cloud.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm

### <a name="enc_cmp_variables"></a>Enclosing Compartment Variables
Variable Name | Description | Required | Default Value
--------------|-------------|----------|--------------
**use_enclosing_compartment** | a boolean flag indicating whether or not to provision the Landing Zone within an enclosing compartment other than the root compartment. **When provisioning the Landing Zone as a _narrower-permissioned_ user, make sure to set this variable value to true** | Yes | false
**existing_enclosing_compartment_ocid** | the OCID of a pre-existing enclosing compartment where Landing Zone compartments are to be created. If *enclosing_compartment* is false, the module creates the Landing Zone compartments in the root compartment as long as the executing user has the required permission | No | None
**policies_in_root_compartment** | the Landing Zone requires policies attached to the root compartment to work at full capacity. For instance, security administrators are expect to manage Cloud Guard, Tag Namespaces, Tag Defaults, Event Rules, and others. Likewise, IAM administrators are expected to manage IAM resources in general. Such capabilities are only enabled if policies are created at the root compartment, as they apply to the tenancy as a whole. A *narrower-permissioned* user will not likely have the permissions to create such policies. As a consequence, it is expected that these policies are previously created by a *wide-permissioned* user. Therefore, **when provisioning the Landing Zone as a _narrower-permissioned_ user, make sure to set this variable value to USE, in which case permissions are not created at the root compartment**. Default is CREATE, meaning the module will provision the policies at the root compartment, as long as the executing user has the required permission. | Yes | CREATE

### <a name="existing_groups_variables"></a>Existing Groups Reuse Variables
Variable Name | Description | Required | Default Value
--------------|-------------|----------|--------------
**use_existing_iam_groups** | Whether or not existing groups are to be reused for this Landing Zone. If unchecked, one set of groups is created. If checked, existing group names must be provided and this set will be able to manage resources in this Landing Zone. | Yes | true
**existing_iam_admin_group_name** | The name of an existing group for IAM administrators | Yes, if use_existing_iam_groups is true | None
**existing_cred_admin_group_name** | The name of an existing group for credential administrators | Yes, if use_existing_iam_groups is true | None
**existing_security_admin_group_name** | The name of an existing group for security administrators | Yes, if use_existing_iam_groups is true | None
**existing_network_admin_group_name** | The name of an existing group for network administrators | Yes, if use_existing_iam_groups is true | None
**existing_appdev_admin_group_name** | The name of an existing group for application development administrators | Yes, if use_existing_iam_groups is true | None
**existing_database_admin_group_name** | The name of an existing group for database administrators | Yes, if use_existing_iam_groups is true | None
**existing_auditor_group_name** | The name of an existing group for auditors | Yes, if use_existing_iam_groups is true | None
**existing_announcement_reader_group_name** | The name of an existing group for announcement readers | Yes, if use_existing_iam_groups is true | None

### <a name="networking_variables"></a>Networking Variables
Variable Name | Description | Required | Default Value
--------------|-------------|----------|--------------
**vcn_cidr** | the VCN CIDR block | Yes | "10.0.0.0/16"
**public_subnet_cidr** | the public subnet CIDR block | Yes | "10.0.1.0/24"
**private_subnet_app_cidr** | the App private subnet CIDR block | Yes | "10.0.2.0/24"
**private_subnet_db_cidr** | the DB private subnet CIDR block | Yes | "10.0.3.0/24"
**public_src_bastion_cidr** | the external CIDR block that is allowed to ingress into the bastions servers in the public subnet | Yes | None
**public_src_lbr_cidr** | the external CIDR block that is allowed to ingress into the load balancer in the public subnet | Yes | "0.0.0.0/0"
**is_vcn_onprem_connected** | whether the VCN is connected to on-premises, in which case a DRG is created and attached to the VCN | Yes | false
**onprem_cidr** | the on-premises CIDR block. Only used if is_vcn_onprem_connected == true | No | "0.0.0.0/0"

### <a name="notification_variables"></a>Notification Variables
Variable Name | Description | Required | Default Value
--------------|-------------|----------|--------------
**network_admin_email_endpoint** | an email to receive notifications for network related events | Yes | None
**security_admin_email_endpoint** | an email to receive notifications for security related events | Yes | None

### <a name="cloudguard_variables"></a>Cloud Guard Variables
Variable Name | Description | Required | Default Value
--------------|-------------|----------|--------------
**cloud_guard_configuration_status** | whether Cloud Guard is enabled or not | Yes | ENABLED

### <a name="logging_variables"></a>Logging Variables
Variable Name | Description | Required | Default Value
--------------|-------------|----------|--------------
**create_service_connector_audit** | whether to create Service Connector Hub for Audit logs | Yes | false
**service_connector_audit_target** | destination for Service Connector Hub for Audit Logs. Valid values are 'objectStorage', 'streaming' and 'functions' | No | objectStorage
**service_connector_audit_state** | state in which to create the Service Connector Hub for Audit logs. Valid values are 'ACTIVE' and 'INACTIVE' | No | INACTIVE
**service_connector_audit_target_OCID** | applicable only for streaming/functions target types. OCID of stream/function target for the Service Connector Hub for Audit logs | No | None
**service_connector_audit_target_cmpt_OCID** | applicable only for streaming/functions target types. OCID of compartment containing the stream/function target for the Service Connector Hub for Audit logs | No | None
**sch_audit_target_rollover_MBs** | applicable only for objectStorage target type. Target rollover size in MBs for Audit logs | No | 100
**sch_audit_target_rollover_MSs** | applicable only for objectStorage target type. Target rollover time in MSs for Audit logs | No | 420000
**sch_audit_objStore_objNamePrefix** | applicable only for objectStorage target type. The prefix for the objects for Audit logs | No | sch-audit
**create_service_connector_vcnFlowLogs** | whether to create Service Connector Hub for VCN Flow logs | Yes | false
**service_connector_vcnFlowLogs_target** | destination for Service Connector Hub for VCN Flow Logs. Valid values are 'objectStorage', 'streaming' and functions | No | objectStorage
**service_connector_vcnFlowLogs_state** | state in which to create the Service Connector Hub for VCN Flow logs. Valid values are 'ACTIVE' and 'INACTIVE' | No | INACTIVE
**service_connector_vcnFlowLogs_target_OCID** | applicable only for streaming/functions target types. OCID of stream/function target for the Service Connector Hub for VCN Flow logs | No | None
**service_connector_vcnFlowLogs_target_cmpt_OCID** | applicable only for streaming/functions target types. OCID of compartment containing the stream/function target for the Service Connector Hub for VCN Flow logs | No | None
**sch_vcnFlowLogs_target_rollover_MBs** | applicable only for objectStorage target type. Target rollover size in MBs for VCN Flow logs | No | 100
**sch_vcnFlowLogs_target_rollover_MSs** | applicable only for objectStorage target type. Target rollover time in MSs for VCN Flow logs | No | 420000
**sch_vcnFlowLogs_objStore_objNamePrefix** | applicable only for objectStorage target type. The prefix for the objects for VCN Flow logs| No | sch-vcnFlowLogs	

## How to Execute the Code Using Terraform CLI
Within the *config* folder, provide variable values in the existing *quickstart-input.tfvars* file.

Next, within the *config* folder, execute:

	terraform init
	terraform plan -var-file="quickstart-input.tfvars" -out plan.out
	terraform apply plan.out

Alternatively, rename *quickstart-input.tfvars* file to *terraform.tfvars* and execute:	

	terraform init
	terraform plan -out plan.out
	terraform apply plan.out

## How to Execute the Code Using OCI Resource Manager
There are a few different ways of running Terraform code in OCI Resource Manager (ORM). Here we describe two of them: 
- creating an ORM stack by uploading a folder to ORM;
- creating an ORM stack by integrating with GitLab. 

A stack is the ORM term for a Terraform configuration. Regardless of the chosen method, **an ORM stack must not be contain any state file or *.terraform* folder in Terraform working folder (the *config* folder in this setup)**.

For more ORM information, please see https://docs.cloud.oracle.com/en-us/iaas/Content/ResourceManager/Concepts/resourcemanager.htm.

### Stack from Folder
Create a folder in your local computer (name it say 'cis-oci') and paste there the config and modules folders from this project. 

Using OCI Console, navigate to Resource Manager service page and create a stack based on a folder. In the **Create Stack** page:
1. Select **My Configuration** option as the origin of the Terraform configuration.
2. In the **Stack Configuration** area, select the **Folder** option and upload the folder containing both config and modules folder ('cis-oci' in this example).

![Folder Stack](images/FolderStack_1.png)

3. In **Working Directory**, select the config folder ('cis-oci/config' in this example) .
4. In **Name**, give the stack a name or accept the default.
5. In **Create in Compartment** dropdown, select the compartment to store the Stack.
6. In **Terraform Version** dropdown, **make sure to select 0.13.x**.

![Folder Stack](images/FolderStack_2.png)

Following the Stack creation wizard, the subsequent step prompts for variables values. Please see the **Input Variables** section above for the variables description. 

Notice that *TENANCY_OCID* and *REGION* have default values. They are automatically picked by ORM based on the executing context. The other values used by the OCI provider, *USER_OCID*, *FINGERPRINT*, *PRIVATE_KEY_PATH* and *PRIVATE_KEY_PASSWORD*, marked as optional, must be left blank, as ORM executes with the privileges of the connected user.

The other defaulted variables, like *VCN_CIDR*, for instance, have their values picked from the stack's variables.tf file and must be reviewed and assigned values as needed.

![Folder Stack](images/FolderStack_3.png)

Once variable values are provided, click Next, review stack values and create the stack. 

Next, navigate to the stack page and use the **Terraform Actions** button to plan/apply/destroy your configuration.

![Run Stack](images/RunStack.png)

### Stack from GitLab
**Note:** ORM requires the GitLab instance accessible over the Internet.

Using OCI Console, navigate to Resource Manager service page and create a connection to your GitLab instance.

In the **Configuration Source Providers** page, provide the required connection details to your GitLab, including the **GitLab URL** and your GitLab **Personal Access Token**. 

![GitLab Connection](images/GitLabConnection.png)

Next, create a stack based on a source code control system. Using OCI Console, in the **Create Stack** page:
1. Select **Source Code Control System** option as the origin of the Terraform configuration.
2. In the **Stack Configuration** area, select the configured GitLab repository details:
	- The configured GitLab provider
	- The repository name
	- The repository branch
	- For the **Working Directory**, select the 'config' folder.	 
3. In **Name**, give the stack a name or accept the default.
4. In **Create in Compartment** dropdown, select the compartment to store the stack.
5. In **Terraform Version** dropdown, **make sure to select 0.13.x**.

![GitLab Stack](images/GitLabStack.png)

Once the stack is created, navigate to the stack page and use the **Terraform Actions** button to plan/apply/destroy your configuration.

## How to Customize the Terraform Configuration
The Terraform code has a single configuration root module and a few modules that actually perform the provisioning. We encourage any customization to follow this pattern as it enables consistent code reuse.

For bringing new resources into the Terraform configuration, like compartments or VCNs, you can simply reuse the existing modules and add extra module calls similar to the existing ones in the root module. Most modules accept a map of resource objects that are usually keyed by the resource name. 

For adding extra objects to an existing container object (like adding subnets to a VCN), simply add the extra objects to the existing map. For instance, looking at the net_vcn.tf file, we have:

```
  module "cis_vcn" {
  	source               = "../modules/network/vcn"
  	compartment_id       = module.cis_compartments.compartments[local.network_compartment_name].id
  	...
  	is_create_drg        = tobool(var.is_vcn_onprem_connected)

  	subnets = {
    (local.public_subnet_name) = {
      compartment_id    = null
      ...
      cidr              = var.public_subnet_cidr
      ...
      dns_label         = "public"
      private           = false
      ...
      route_table_id    = module.cis_vcn.route_tables[local.public_subnet_route_table_name].id
      security_list_ids = [module.cis_security_lists.security_lists[local.public_subnet_security_list_name].id]
    }, 
    (local.private_subnet_app_name) = {
      compartment_id    = null
      ...
      cidr              = var.private_subnet_app_cidr
      ...
      dns_label         = "appsubnet"
      private           = true
      ...
      route_table_id    = module.cis_vcn.route_tables[local.private_subnet_app_route_table_name].id
      security_list_ids = [module.cis_security_lists.security_lists[local.private_subnet_app_security_list_name].id]
	  ...
```
In this code excerpt, the *subnets* variable is a map of subnet objects. Adding a new subnet to the existing VCN is as easy as adding a new subnet object to the *subnets* map. Make sure to provide the new subnet a route table and security list. Use the available code as an example. For adding a new VCN altogether, simply provide a new tf file with contents similar to net_vcn.tf.

## Known Facts
### Destroying Resources
- By design, vaults and keys are not destroyed immediately. They have a delayed delete of 30 days.
- By design, compartments are not destroyed immediately. 
- Tag namespaces may fail to delete on the first destroy.  Run destroy again to remove.