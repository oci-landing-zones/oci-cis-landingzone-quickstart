# OCI CIS 1.1 Foundations

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

## How this Terraform Configuration is organized 
[Andre to add]

## How to run this Terraform Configuration using Terraform CLI
You MUST provide values for the following variable names:
- tenancy_ocid: the OCI tenancy id where this configuration will be executed. This information can be obtained in OCI Console.
- user_ocid: the OCI user id that will execute this configuration. This information can be obtained in OCI Console. The user must have the necessary privileges to provision the resources.
- fingerprint: the user's public key fingerprint. This information can be obtained in OCI Console.
- private_key_path: the local path to the user private key.
- private_key_password: the private key password, if any.

There are multiple ways of achieving this, all documented in https://www.terraform.io/docs/configuration/variables.html:
- Environment variables
- terraform.tfvars or terraform.tfvars.json files 
- *.auto.tfvars or *.auto.tfvars.json files
- any -var and -var-file options on the command line.

For environment variables, please see the provided env-vars.template. Once the correct values are provided, make sure to run 'source env-vars.template' to export those variables before executing Terraform.

If you want to use terraform.tfvars file, create the file with this exact name (terraform.tfvars) in the config folder and provide values as shown below (you are expected to change the sample values :-)). 
terraform.tfvars is automatically loaded when Terraform executes.

	tenancy_ocid="ocid1.tenancy.oc1..aaaaaaaaixl3xlrmengaocampeaogim5q2l2pv2qmfithywqhw4tgbvuq"
	user_ocid="ocid1.user.oc1..aaaaaaaalxqallveu54bidalibertaaaonjyn7mopu2oyy4hqjjducajotaefe"
	fingerprint="c1:91:24:3f:49:77:68:22:2e:45:80:fg:36:67:45:93"
	private_key_path="/home/users/myself/private_key.pem"
	private_key_password=""

With variable values provided, execute:

	terraform init
	terraform plan -out plan.out
	terraform apply plan.out

## How to run this Terraform Configuration using OCI Resource Manager
[Andre to add]



# Known Issues
## Deployment via Resource Manager or Terraform
- Destroying the stack
	- Vaults have a delayed delete of 7 days
	- Compartments may not delete 
	- Tag namespace fails to delete on the first destroy.  Run destroy again to remove
## Deployment via Resourece Manager
- Variable syntax errors are not detected during the planning