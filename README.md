# CIS 1.1 OCI Landing Zone Template

## Overview
This Landing Zone template deploys a standardized environment in an Oracle Cloud Infrastructure (OCI) tenancy that helps organizations with workloads needing to comply with the CIS Oracle Cloud Foundations Benchmark v1.1. 

The Landing Zone template deploys a standard three-tier web architecture using a single VCN with multiple compartments to segregate access to various resources. The template configures the OCI tenancy to meet CIS OCI Foundations Benchmark settings related to:

- IAM
- Networking
- Monitoring
- Object Storage
 
 ## Architecture 
 The Landing Zone template creates a three-tier web architecture in a single VCN. The three tiers are divided into:
 
 - One (1) Public Subnet (for load balancers and the OCI bastion host service)
 - Two (2) Private Subnets (one for the application tier/servers and one for the database tier)
 
 The Landing Zone template also creates five (5) compartments in the tenancy:
 
 - A network compartment: A compartment for all networking resources.
 - A security compartment: A compartment for all logging, key management, and notifications resources and services. 
 - A compute and storage compartment: A compartment for all compute and storage (including object storage) resources
 - A database compartment: A compartment for a database resources and services. 
 - An application development compartment: A compartment for application services, such as functions and API Gateway. 

The network diagram below does not show the database and application development compartments, because no resources are initially provisioned into these compartments. 

![Architecture](images/Architecture.png)

## How the Code is Organized 
The code consists of a single Terraform configuration defined within the config folder along with a few children modules within the modules folder.

Within the config folder, the Terraform files are named after the use cases they implement as described in CIS OCI Security Foundation Benchmark document. For instance, iam_1.1.tf implements use case 1.1 in the IAM sectiom, while mon_3.5.tf implements use case 3.5 in the Monitoring section. .tf files with no numbering scheme are either Terraform suggested names for Terraform constructs (provider.tf, variables.tf, locals.tf, outputs.tf) or use cases supporting files (iam_compartments.tf, net_vcn.tf).

**Note**: The code has been written and tested with Terraform version 0.13.5 and OCI provider version 4.2.0.

## Input Variables
Input variables used in the configuration are all defined (and defaulted) in config/variables.tf:
- **tenancy_ocid**: the OCI tenancy id where this configuration will be executed. This information can be obtained in OCI Console.
	- Required, no default
- **user_ocid**: the OCI user id that will execute this configuration. This information can be obtained in OCI Console. The user must have the necessary privileges to provision the resources.
	- Required, no default
- **fingerprint**: the user's public key fingerprint. This information can be obtained in OCI Console.
	- Required, no default
- **private_key_path**: the local path to the user private key.
	- Required, no default
- **private_key_password**: the private key password, if any.
	- Optional, no default
- **home_region**: the tenancy home region identifier where Terraform should provision IAM resources (for a list of available regions, please see https://docs.cloud.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm)
	- Required, default us-ashburn-1
- **region**: the tenancy region identifier where the Terraform should provision the resources.
	- Required, default us-ashburn-1
- **region_key**: the 3-letter region key
	- Required, default iad
- **service_label**: a label that is used as a prefix when naming provisioned resources.
	- Required, default cis
- **vcn_cidr**: the VCN CIDR block
	- Required, default 10.0.0.0/16
- **public_subnet_cidr**: the public subnet CIDR block.
	- Required, default 10.0.1.0/24
- **private_subnet_app_cidr**: the App private subnet CIDR block.
	- Required, default 10.0.2.0/24
- **private_subnet_db_cidr**: the DB private subnet CIDR block.
	- Required, default 10.0.3.0/24
- **public_src_bastion_cidr**: the external CIDR block that is allowed to ingress into the bastions servers in the public subnet.
	- Required, no default
- **public_src_lbr_cidr**: the external CIDR block that is allowed to ingress into the load balancer in the public subnet.
	- Required, default 0.0.0.0/0
- **network_admin_email_endpoint**: an email to receive notifications for network related events.
	- Required, no default
- **security_admin_email_endpoint**: an email to receive notifications for security related events.
	- Required, no default
- **cloud_guard_configuration_status**: whether Cloud Guard is enabled or not.
	- Required, default ENABLED
- **cloud_guard_configuration_self_manage_resources**: whether Cloud Guard should seed Oracle-managed entities. Setting this variable to true lets the user seed the Oracle-managed entities with minimal changes to the original entities.
	- Required, default false

## How to Execute the Code Using Terraform CLI
You MUST provide values for the following variable names: tenancy_ocid, user_ocid, fingerprint, private_key_path and private_key_password (if any)

There are multiple ways of achieving this, all documented in https://www.terraform.io/docs/configuration/variables.html:
- Environment variables
- terraform.tfvars or terraform.tfvars.json files 
- *.auto.tfvars or *.auto.tfvars.json files
- any -var and -var-file options on the command line.

For environment variables, please see the provided env-vars.template. Once the correct values are provided, make sure to run 'source env-vars.template' to export those variables before executing Terraform.

If you want to use terraform.tfvars file, create the file with this exact name (terraform.tfvars) in the config folder and provide values as shown below (you are expected to change the sample values :-)). Also add any custom values for the defaulted variables defined in config/variables.tf
terraform.tfvars is automatically loaded when Terraform executes.

	tenancy_ocid="ocid1.tenancy.oc1..aaaaaaaaixl3xlrmengaocampeaogim5q2l2pv2qmfithywqhw4tgbvuq"
	user_ocid="ocid1.user.oc1..aaaaaaaalxqallveu54bidalibertaaaonjyn7mopu2oyy4hqjjducajotaefe"
	fingerprint="c1:91:24:3f:49:77:68:22:2e:45:80:fg:36:67:45:93"
	private_key_path="/home/users/myself/private_key.pem"
	private_key_password=""
	public_src_bastion_cidr="a_valid_cidr_block"
	network_admin_email_endpoint="a_valid_email@your_domain.com"
	security_admin_email_endpoint="a_valid_email@your_domain.com"

With variable values provided, execute:

	cd config
	terraform init
	terraform plan -out plan.out
	terraform apply plan.out

## How to Execute the Code Using OCI Resource Manager
OCI Resource Manager (ORM) has slightly different requirements than Terraform CLI. First and foremost, there is no need to provide tenancy connection and user authentication input variables for the OCI provider, as Resource Manager, being an OCI service, uses the service connection information itself.
The only required input variable for the OCI provider is the **region**. Fortunately, the provided Terraform code, by not having defaults to tenancy_ocid, user_ocid, fingerprint, private_key_path and private_key_password is already adequate and no changes are required.

There are a few different ways of running Terraform code in ORM. Here we describe two of them: creating an ORM stack by uploading a folder to ORM or creating an ORM stack by integrating with GitLab. A stack is the ORM term to refer to a Terraform configuration.

For OCI Resource Manager details, please see https://docs.cloud.oracle.com/en-us/iaas/Content/ResourceManager/Concepts/resourcemanager.htm.

### Stack from Folder
Create a folder in your local computer (name it say 'cis-oci') and paste there the config and modules folders from this repository. 

Using OCI Console, navigate to Resource Manager service page and create a stack based on a folder. In the **Create Stack** page:
1. Select **My Configuration** option as the origin of the Terraform configuration.
2. In the **Stack Configuration** area, select the **Folder** option and upload the folder containing both config and modules folder ('cis-oci' in this example).

![Folder Stack](images/FolderStack_1.png)

3. In **Working Directory**, select the config folder ('cis-oci/config' in this example) .
4. In **Name**, give the stack a name or accept the default.
5. In **Create in Compartment** dropdown, select the compartment to store the Stack.
6. In **Terraform Version** dropdown, **make sure to select 0.13.x**.

![Folder Stack](images/FolderStack_2.png)

Once the stack is created, navigate to the stack page and use the **Terraform Actions** button to plan/apply/destroy your configuration.

![Run Stack](images/RunStack.png)

### Stack from GitLab
First make sure to create a GitLab project out of this repository. 

Using OCI Console, navigate to Resource Manager service page and create a connection to your GitLab.

In the **Configuration Source Providers** page, provide the required connection details to your GitLab, including the **GitLab URL** and your GitLab **Personal Access Token**. 

![GitLab Connection](images/GitLabConnection.png)

**Note:** the GitLab URL must be accessible over the Internet.

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

# Known Issues
## Deployment via Resource Manager or Terraform
- Destroying the stack
	- Vaults have a delayed delete of 7 days
	- Compartments may not delete 
	- Tag namespace fails to delete on the first destroy.  Run destroy again to remove.