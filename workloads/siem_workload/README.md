# OCI MAP Foundations Remediation

![Landing Zone logo](../../images/landing%20zone_300.png)

## Introduction

This terraform code can be used to partially setup SIEM integration from the OCI side.

**Logging Monitoring and Alerting Events and Notifications:**

- Configure a SIEM method based on requirements for OCI and 3rd Party solutions.

## Variables
### <a name="tf_variables"></a>Terraform Provider Variables
Variable Name | Description | Required | Default Value
--------------|-------------|----------|--------------
**tenancy_ocid** | The OCI tenancy id where this configuration will be executed. This information can be obtained in OCI Console. | Yes | None
**user_ocid** | The OCI user id that will execute this configuration. This information can be obtained in OCI Console. The user must have the necessary privileges to provision the resources. | Yes | ""
**fingerprint** | The user's public key fingerprint. This information can be obtained in OCI Console. | Yes | ""
**private_key_path** | The local path to the user private key. | Yes | ""
**private_key_password** | The private key password, if any. | No | ""

### <a name="env_variables"></a>Environment Variables
Variable Name | Description | Required | Default Value
--------------|-------------|----------|--------------
**homeregion** | The tenancy's home region identifier where the Terraform should provision the resources. | Yes | None
**service_label** | A label used as a prefix for naming resources. | Yes | None

### <a name="siem_variables"></a>SIEM Variables
Variable Name | Description | Required | Default Value
--------------|-------------|----------|--------------
**integration_type** | Select an integration pattern to provision in your tenancy. Valid choices are: "Generic Stream-based", "Splunk", or "Stellar Cyber | Yes | ""
**compartment_id_for_stream** | The compartment where the stream should reside. | Yes | null
**name_for_stream** | Customize the stream name. Service Label will be prefixed.. | Yes | "siem-integration-stream"
**compartment_id_for_service_connector_stream** | The compartment where the Service Connector should reside. | Yes | null
**name_for_service_connector_stream** | Customize the service connector name. Service Label will be prefixed. | No | "audit_logs_to_stream"
**create_iam_resources_stream** | Create a group in the Default Identity Domain and the required IAM Stream read policy. The IAM policy will be created in the same compartment as the stream. | No | null
**access_method_stream** | Select how the SIEM will access OCI APIs. | No | "API Signing Key"
**stream_partitions_count** | Number of partitions in the stream. Default to 1. | No | 1
**stream_retention_in_hours** | Stream retention in hours. Default 24 hours. | No | 24

### <a name="la_variables"></a>Logging Analytics Variables
Variable Name | Description | Required | Default Value
**create_iam_resources_la** | Determines whether the required IAM permissions for Logging Analytics will be created. | No | null
**integration_link** | Select an integration pattern to provision in your tenancy. | No | null
**integration_info** | Information needed to configure the Integration on the SIEM Side. | No | null

## Prerequisites

The following permissions are needed to run the stack using the resource manager.

Note: Some policies(Cloudevents-rule, Alarms, ons-family) can be further restricted and refined if required.

Please replace "`<Remediation Group>`" with an appropriate group in your tenancy.

The reference to "`<Stack Compartment>`" should be replaced within an existing compartment used for housing Security or Shared resources. The stack can also be created at the tenancy level but it is not recommended.

**Resource Manager Permissions:**

`Allow group <Remediation Group> to manage orm-stacks in compartment <Stack Compartment>`  
`Allow group <Remediation Group> to manage orm-jobs in compartment <Stack Compartment>`

**Remediation Permissions:**

`Allow group <Remediation Group> to inspect all-resources in tenancy`  
`Allow group <Remediation Group> to read all-resources in tenancy`  
`Allow group <Remediation Group> to manage cloud-guard-family in tenancy`  
`Allow group <Remediation Group> to manage cloudevents-rules in tenancy`  
`Allow group <Remediation Group> to manage usage-budgets in tenancy`  
`Allow group <Remediation Group> to manage alarms in tenancy`  
`Allow group <Remediation Group> to manage ons-family in tenancy`  
`Allow group <Remediation Group> to manage policies in tenancy`

## Considerations before running the Terraform script

**Stack placement:**

We recommend creating the stack in a Security or Shared compartment and not in the Root compartment. The location of the stack doesn't have any effect on the resources created by the stack.

**Service Label:**

Consider what service label to use and if you have any existing naming convention to follow. A Service Label is a unique label that gets prepended to all resources created by this stack. Max length of 8 alphanumeric characters starting with a letter.

**Multi Region deployment:**

If you are subscribed to multiple regions, you will need to create a stack per region as the terraform provider works on a regional basis.

**Compartment for Network Events and Alarms:**

Consider what compartment should be used for Network Event Notifications and Alarms. Typically, an existing networking or shared services compartment is used.

**Compartment for Security Events:**

Consider what compartment should be used for Security Event Notifications. Typically, an existing security or shared services compartment is used.

**Email recipients for Security Events, Network Events and Alarms:**

Consider what Distribution Lists or individuals should receive  emails related to :

Security Events

Network Events

Connectivity Alarms

**Review Cloud Guard configuration:**

Review the current Cloud Guard configuration. If a target already exists at the root level, this wil cause an issue when running the Cloud Guard remediation. Evaluate if the current target can be removed and created.

- **Budget information:**

The budget creation requires a Monthly spending threshold. For tenancies that have existing and stable workload, the Cost Analysis tooling in OCI can show how the current monthly spending looks.

Consider, who should receive a Budget Alert when it is forecasted that the monthly threshold will be exceeded.

- **Enforced tagging strategy:**

The provisioning of resources will fail, If you have setup tags to be required at resource creations, since the stack cannot provide these tags.

## How to execute
### Via Resource Manager
1. [![Deploy_To_OCI](../../images/DeployToOCI.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/oracle-quickstart/oci-cis-landingzone-quickstart/archive/refs/heads/main.zip)
*If you are logged into your OCI tenancy, the button will take you directly to OCI Resource Manager where you can proceed to deploy. If you are not logged, the button takes you to Oracle Cloud initial page where you must enter your tenancy name and login to OCI.*
1. Under **Working directory select the directory ending with *cis_oci_benchmark_logging_monitoring_workload*
![Working_Directory](images/image1.png)
1. Click Next
1. Enter the required variables
![variables](images/image2.png)
1. Click Next
1. Click Next
1. Click Apply

### Via Terraform CLI
1. Enter required variables from input.auto.tfvars
1. terraform init
1. terraform plan
1. terraforom apply

## Expected outcome and known issues

When deploy in your home region, you should expect Terraform to create 21 resources if all remediations have been selected. This can be validated by reviewing the Terraform Log after a successful Apply Job

**Cloud Guard Errors when running the Apply Job:**

You will see an API - "CreateTarget" error when running an Apply job, if you have selected the Cloud Guard remediation and Cloud Guard has already been partially configured., i.e. has a target defined at the root level.  If Cloud Guard is not yet operationalized in your tenancy, evaluate if deleting any existing target is feasible and then rerunning the Apply Job. This will enable and configure Cloud Guard as recommended by Oracle.

**Destroying Notification resources is slow:**

This delay is due to the way the Notification API works when destroying topics. Typically, a 10 minutes delay is to be expected.

**TF requires network connectivity to github.com**

The remediation code references modules hosted publicly on Github - Oracle Quickstart. When Terraform initializes it will need network access to download the referenced modules. This may be relevant when using 3rd party tooling.

**Detailed Log Levels are set to None:**

When troubleshooting any issues when running the remediation TF in Resource Manager, we recommend enabling detailed logging in the advanced section of the Plan or Apply popup window and rerunning the job.

**Terraform version errors due to version mismatch:**

The TF code requires terraform 1.2.x. When using 3rd party tooling you need to ensure the matching terraform binaries are used.
