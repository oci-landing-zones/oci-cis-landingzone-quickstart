# CIS OCI Landing Zone Quickstart Template

## Overview
This Landing Zone template deploys a standardized environment in an Oracle Cloud Infrastructure (OCI) tenancy that helps organizations with workloads needing to comply with the CIS Oracle Cloud Foundations Benchmark v1.1.    

The Landing Zone template deploys a standard three-tier web architecture using a single VCN with multiple compartments to segregate access to various resources. The template configures the OCI tenancy to meet CIS OCI Foundations Benchmark settings related to:

- IAM (Identity & Access Management)
- Networking
- Keys
- Cloud Guard
- Logging
- Events
- Notifications
- Object Storage

 ## Architecture 
 The template creates a three-tier web architecture in a single VCN. The three tiers are divided into:
 
 - One public subnet for load balancers and bastion servers;
 - Two private subnets: one for the application tier and one for the database tier.
 
 The Landing Zone template also creates four compartments in the tenancy:
 
 - A network compartment: for all networking resources.
 - A security compartment: for all logging, key management, and notifications resources. 
 - An application development compartment: for application development related services, including compute, storage, functions, streams, Kubernetes, API Gateway, etc. 
 - A database compartment: for all database resources. 

The architecture diagram below does not show the database compartment, because no resources are initially provisioned into that compartment.
The greyed out icons in the AppDev compartment indicate services not provisioned by this template.

The resources are provisioned using a single user account with broad tenancy administration privileges.

![Architecture](images/Architecture.png)

## How the Code is Organized 
The code consists of a single Terraform root module configuration defined within the *config* folder along with a few children modules within the *modules* folder.

Within the config folder, the Terraform files are named after the use cases they implement as described in CIS OCI Security Foundation Benchmark document. For instance, iam_1.1.tf implements use case 1.1 in the IAM sectiom, while mon_3.5.tf implements use case 3.5 in the Monitoring section. .tf files with no numbering scheme are either Terraform suggested names for Terraform constructs (provider.tf, variables.tf, locals.tf, outputs.tf) or use cases supporting files (iam_compartments.tf, net_vcn.tf).

**Note**: The code has been written and tested with Terraform version 0.13.5 and OCI provider version 4.2.0.

## Input Variables
Input variables used in the configuration are all defined (and defaulted) in config/variables.tf:

Variable Name | Description | Required | Default Value
--------------|-------------|----------|--------------
**tenancy_ocid** | the OCI tenancy id where this configuration will be executed. This information can be obtained in OCI Console | Yes | None
**user_ocid** | the OCI user id that will execute this configuration. This information can be obtained in OCI Console. The user must have the necessary privileges to provision the resources | Yes | None
**fingerprint** | the user's public key fingerprint. This information can be obtained in OCI Console | Yes | None
**private_key_path** | the local path to the user private key | Yes | None
**private_key_password** | the private key password, if any | No | ""
**home_region** \* | the tenancy home region identifier where Terraform should provision IAM resources | Yes | None
**region** \* | the tenancy region identifier where the Terraform should provision the resources | Yes | None
**region_key** \* | the 3-letter region key | Yes | None
**service_label** | a label used as a prefix for naming resources | Yes | None
**vcn_cidr** | the VCN CIDR block | Yes | "10.0.0.0/16"
**public_subnet_cidr** | the public subnet CIDR block | Yes | "10.0.1.0/24"
**private_subnet_app_cidr** | the App private subnet CIDR block | Yes | "10.0.2.0/24"
**private_subnet_db_cidr** | the DB private subnet CIDR block | Yes | "10.0.3.0/24"
**public_src_bastion_cidr** | the external CIDR block that is allowed to ingress into the bastions servers in the public subnet | Yes | None
**public_src_lbr_cidr** | the external CIDR block that is allowed to ingress into the load balancer in the public subnet | Yes | "0.0.0.0/0"
**is_vcn_onprem_connected** | whether the VCN is connected to on-premises, in which case a DRG is created and attached to the VCN | Yes | false
**onprem_cidr** | the on-premises CIDR block. Only used if is_vcn_onprem_connected == true | No | "0.0.0.0/0"
**network_admin_email_endpoint** | an email to receive notifications for network related events | Yes | None
**security_admin_email_endpoint** | an email to receive notifications for security related events | Yes | None
**cloud_guard_configuration_status** | whether Cloud Guard is enabled or not | Yes | ENABLED
**cloud_guard_configuration_self_manage_resources** | whether Cloud Guard should seed Oracle-managed entities. Setting this variable to true lets the user seed the Oracle-managed entities with minimal changes to the original entities | Yes | false

\* For a list of available regions, please see https://docs.cloud.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm	

## How to Execute the Code Using Terraform CLI
Within the config folder, provide variable values in the existing *quickstart-input.tfvars* file.

Next, within the config folder, execute:

	terraform init
	terraform plan -var-file="quickstart-input.tfvars" -out plan.out
	terraform apply -var-file="quickstart-input.tfvars" plan.out

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

Once the stack is created, navigate to the stack page and use the **Terraform Actions** button to plan/apply/destroy your configuration.

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

# CIS Reports Script
## Overview
The CIS Reports Script checks a tenancy's configuration against the CIS Foundations Benchmark for Oracle Cloud.  The script outputs a summmary report CSV as well individual CSV findings report for configuration issues that are discovered.

Using the --output-to-bucket ```<bucket-name>``` the reports will be copied to the Object Storage bucket in a folder with current day's date ex. ```2020-12-08```.

## Usage 

### Executing on local machine

1. [Setup and Prerequisites](https://docs.cloud.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#Required_Keys_and_OCIDs) 

1. Run
```
python3 cis_reports.py --output-to-bucket 'my-example-bucket-1' -t <Profile_Name>
```
where \<Profile_Name> is the profile name in OCI client config file (typically located under $HOME/.oci). The profile name defines the connecting parameters to your tenancy, like tenancy id, region, user id, fingerprint and key file.

	[the_profile_name]
	tenancy=ocid1.tenancy.oc1..aaaaaaaagfqbe4notarealocidreallygzinrxt6h6hfshjokfgfi5nzquxmfpzkyq
	region=us-ashburn-1
	user=ocid1.user.oc1..aaaaaaaaltwx45wllv52qqxk7inotarealocidreallyo76gboofpbzlgmihq
	fingerprint=c8:91:41:8p:65:56:68:02:2e:54:80:kk:36:76:69:39
	key_file=/path_to_my_private_key_file.pem

### Executing using Cloud Shell:
1. install OCI sdk

```
pip3 install --user oci
```
1. Copy the cis_reports.py to the directory

1. Run
```
python3 cis_reports.py -dt --output-to-bucket 'my-example-bucket-1'
``` 
# Known Facts
## Destroying Resources
- By design, vaults and keys are not destroyed immediately. They have a delayed delete of 30 days.
- By design, compartments are not destroyed immediately. 
- Tag namespace may fail to delete on the first destroy.  Run destroy again to remove.

# Feedback
We welcome your feedback. To post feedback, submit feature ideas or report bugs, please use the Issues section on this repository.	