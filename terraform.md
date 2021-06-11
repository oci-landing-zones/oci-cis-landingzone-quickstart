## Landing Zone Modules
The Landing Zone terraform is made of two root modules and some children modules. The root modules are under the *config* and *pre-config* folders, while the children modules are under the *modules* folder. Both *config* and *pre-config* use the children modules for resource creation.

The *config* module is responsible for provisioning the Landing Zone resources. It can be executed by a tenancy administrator or a non tenancy administrator. When executed by a non tenancy administrator, the *pre-config* module must be previously executed by a tenancy administrator to create Landing Zone required resources in the root compartment, like compartments, policies and groups. If the *config* module is being executed by a tenancy administrator, the *pre-config* module does not need to be executed, as the *config* module will be able to create all required resources in the root compartment.

Within the config folder, the Terraform files are named after the use cases they implement as described in CIS OCI Security Foundation Benchmark document. Each file prefix implements/supports use cases in the corresponding section in that document.

The variables in each root module are described below in [Config Module Input Variables](VARIABLES.md#config_input_variables) and [Pre-Config Module Input Variables](VARIABLES.md#pre_config_input_variables).

**Note**: The code has been written and tested with Terraform version 0.13.5 and OCI provider version 4.23.0.

## How to Execute the Code Using Terraform CLI
Within the root module folder (*config* or *pre-config*), provide variable values in the existing *quickstart-input.tfvars* file.

Next, execute:

	terraform init
	terraform plan -var-file="quickstart-input.tfvars" -out plan.out
	terraform apply plan.out

Alternatively, after providing the variable values in *quickstart-input.tfvars*, rename it to *terraform.tfvars* and execute:	

	terraform init
	terraform plan -out plan.out
	terraform apply plan.out

## How to Execute the Code Using OCI Resource Manager
There are a few different ways of running Terraform code in OCI Resource Manager (ORM). Here we describe two of them: 
- creating an ORM stack by uploading a zip file to ORM;
- creating an ORM stack by integrating with GitLab. 

A stack is the ORM term for a Terraform configuration. Regardless of the chosen method, **an ORM stack must not be contain any state file or *.terraform* folder in Terraform working folder (the *config* folder in this setup)**.

For more ORM information, please see https://docs.cloud.oracle.com/en-us/iaas/Content/ResourceManager/Concepts/resourcemanager.htm.

### Stack from Zip File
Download this repository as a .zip file, by expanding the Code button in the repository home page and choosing the "Download ZIP" option.

![Zip Download](images/ZipDownload.png)

Using OCI Console, navigate to Resource Manager service page and create a stack based on a .zip file. In the **Create Stack** page:
1. Select **My Configuration** option as the origin of the Terraform configuration.
2. In the **Stack Configuration** area, select the **.Zip file** option and upload the .zip file downloaded in the previous step.

![Folder Stack](images/ZipStack_1.png)

3. In **Working Directory**, make sure the config folder is selected.
4. In **Name**, give the stack a name or accept the default.
5. In **Create in Compartment** dropdown, select the compartment to store the Stack.
6. In **Terraform Version** dropdown, **make sure to select 0.13.x at least. Lower Terraform versions are not supported**.

![Folder Stack](images/ZipStack_2.png)

Following the Stack creation wizard, the subsequent step prompts for variables values. Please see the **Input Variables** section above for the variables description. 

Some variables, like *VCN CIDR Block* for instance, are defaulted in the configuration's variables.tf file and must be reviewed and reassigned values as needed.

![Folder Stack](images/ZipStack_3.png)

Once variable values are provided, click Next, review stack values and create the stack. 

In the Stack page use the appropriate buttons to plan/apply/destroy your stack.

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
5. In **Terraform Version** dropdown, **make sure to select 0.13.x at least. Lower Terraform versions are not supported**.

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
