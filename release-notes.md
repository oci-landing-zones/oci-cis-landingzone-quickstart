#   October 6, 2023 Release Notes - 2.6.5
1. [CIS Compliance Script Updates](#2-6-5-script-updates)
1. [Terraform Quick Start Updates](#2-6-5-quickstart-updates)
1. [Terraform Workloads Updates](#2-6-5-workload-updates)

## <a name="2-6-5-script-updates">Updates to the CIS Compliance Script</a>
Updates:
    - Added debugging Identity Groups collection

## <a name="2-6-5-quickstart-updates">Terraform Quick Start Updates</a>
Updates:
- Compartments management has been pinned to Compartments module v0.1.6.

## <a name="2-6-5-workload-updates">Terraform Quick Start Updates</a>
Updates:
    - Generic Workloads outputs compartments created
Fixes:
- Dynamic Group AppDev

#   September 18, 2023 Release Notes - 2.6.4
1. [CIS Compliance Script Adds Identity Domains](#2-6-4-identity-domains)
1. [Updates to the CIS Compliance Script](#2-6-4-script-updates)
1. [Workload Expansion Terraform for Quick Start](#2-6-4-workload-updates)

## <a name="2-6-4-identity-domains">CIS Compliance Script Adds Identity Domains</a>
CIS compliance checking scripts adds collection of Identity Domains password policy.  This allows the compliance checking script to access CIS recommendation 1.5 Ensure IAM password policy expires passwords within 365 days and recommendation 1.6 Ensure IAM password policy prevents password reuse.

## <a name="2-6-4-script-updates">Updates to the CIS Compliance Script</a>
- Updates:
    - Improved navigation for CIS Summary Report HTML
    - Added `error_report.csv` for errors when collection OCI resources
- Fixes:
    - Improved OCI logging error handling
    - Fixed compliance for Storage Admin policies for CIS recommendation 1.14 Ensure storage service-level admins cannot delete resources they manage

## <a name="2-6-4-workload-updates">Workload Expansion Terraform for Quick Start</a>
The terraform code in this folder expands an existing CIS Landing Zone deployment.  It does this by adding one or more workload compartment(s) in the AppDev compartment and, optionally, the associated OCI IAM groups, dynamic groups, and OCI IAM policies to manage OCI resources in the workload compartment. For more information please see the [readme.md](./workloads/generic_workload_compartments/readme.md)

#   September 4, 2023 Release Notes - 2.6.3
1. [Fixes to the CIS Compliance Script](#2-6-3-script-fixes)
1. [Updates to the CIS Compliance Script](#2-6-3-script-updates)
1. [Updates to Terraform Template](#2-6-3-terraform-updates)

## <a name="2-6-3-script-fixes">Fixes to the CIS Compliance Script</a>
Fixes:
- Index of out range exception in obp checks for subnets and buckets in some exceptional cases.
- No budget returned if script executed from non-home region in Cloud Shell. Budgets are now returned in all cases.

## <a name="2-6-3-script-updates">Updates to the CIS Compliance Script</a>
Updates:
- Event types added to remediation in HTML report for check 3.13.
- All OCI groups are now returned in raw output, including groups with no users.
- Databases in "UNAVAILABLE" state are no longer returned in check 2.8.

## <a name="2-6-3-terraform-updates">Updates to Terraform Template</a>
Updates:
- Existing groups can now have spaces in their names. Useful when referring to synchronized groups from external identity providers, where spaces are allowed in group names.
- Variables for existing groups (*existing_xxxxx_admin_group_name*) can be assigned multiple groups. Feature only available through Terraform CLI. Not available in OCI Resource Manager.
- *network_admin_email_endpoints* and *security_admin_email_endpoints* variables now enforce non-emptiness in Terrafom CLI.

#   August 8, 2023 Release Notes - 2.6.2
1. [Fixes to the CIS Compliance Script](#2-6-2-script-fixes)
1. [Updates to the CIS Compliance Script](#2-6-2-script-updates)
1. [Updates to the Readme](#2-6-2-readme-updates)


## <a name="2-6-2-script-updates">Updates to the CIS Compliance Script</a>
Updates:
- Added Service Connector Hub ID and Name to OBP Best practices for VCN Flow Logs and Object Storage Buckets
- Alert users when the cis_reports.py is not run in home region which can impact budgets collection

## <a name="2-6-2-script-fixes">Fixes to the CIS Compliance Script</a>
Fixes: 
- Updated CIS 2.8 check updated to exclude ADB-S that are in a VCN but not attached to Network Security Group.  Closes issue [#105](https://github.com/oracle-quickstart/oci-cis-landingzone-quickstart/issues/105)
- Cleaned up 1900+ Flake8 

## <a name="2-6-2-readme-updates">Updates to the Readme</a>
Updates:
- Removed team section
- Added the CIS Terraform Modules Section


#   July 26, 2023 Release Notes - 2.6.1
1. [Updates to Terraform Template](#2-6-1-tf-updates)
1. [Documentation Updates](#2-6-1-doc-updates)
1. [Fixes to the CIS Compliance Script](#2-6-1-script-fixes)

## <a name="2-6-1-tf-updates">Updates to Terraform Template</a>
Fixes:
- Fixed a defect where missing exainfra admin group name in grants was causing policies creation to fail.

Updates:
- Set Terraform version upper bound to *< 1.3.0* in [provider.tf](./config/provider.tf).

## <a name="2-6-1-doc-updates">Documentation Updates</a>
Updates:
- Added link to CIS Landing Zone Quick Start Live Lab in [README.md](./README.md).

## <a name="2-6-1-script-fixes">Fixes to the CIS Compliance Script</a>
Fixes:
- CIS check 2.8 now skips autonomous database in the UNAVAILABLE state

#   July 14, 2023 Release Notes - 2.6.0
1. [Updates to Terraform Template](#2-6-0-tf-updates)

## <a name="2-6-0-tf-updates">Updates to Terraform Template</a>
Updates:
- IAM resources, including compartments, groups, dynamic groups and policies are now managed with new remote modules, available in https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam. The old local IAM modules are still kept in this repository.
- IAM policies can now be created based on metadata associated to compartments. This is an alternative way of managing policies, enabled by the [new IAM policy module](https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam/tree/main/policies). In this approach, the grants to resources belonging to a specific compartment are combined into a single policy that is attached to the compartment itself. This differs from the existing approach, where grants are combined per grantee and attached to the enclosing compartment. This alternative way is enabled by **Enable template policies?** checkbox (if using OCI Resource Manager) or by the **enable_template_policies** variable (if using Terraform CLI). The existing approach of deploying policies remains the default.
- Some policy grants have been updated, allowing admin groups to manage keys in their own compartments using the OCI Vault in the Security Compartment and deploy private endpoints in Network compartment. Additionally, some grants have been consolidated into a single grant with a comma-separated list of group principals. Service policies have been consolidated into a single policy with the new name *${var.service_label}-services-policy*.
- Deploying with an enclosing compartment becomes the default. Users who deploy without an enclosing compartment should unset **Use an enclosing compartment?** checkbox (if using OCI Resource Manager) or set **use_enclosing_compartment** variable to false (if using Terraform CLI).
- Quick Start release number added to cis-landing-zone freeform tag.
- Application Information tab is now enabled in OCI Resource Manager, displaying basic information about the stack and outputs of latest Terraform apply.


#   June 29, 2023 Release Notes - 2.5.12
1. [Fixes to the CIS Compliance Script](#2-5-12-script-fixes)

## <a name="2-5-12-script-fixes">Fixes to the CIS Compliance Script</a>
Fixes:
- Fixed a logic issue for Security Lists and Network Security Groups with source ports but no destination ports
- Removed Deeplink from Exception handling when reading object storage buckets
- OBP check for budgets now verifies that there is budget with an alert for the root compartment


#   June 20, 2023 Release Notes - 2.5.11
1. [Performance update to the CIS Compliance Script](#2-5-11-script-performance)
1. [Summary Data update to the CIS Compliance Script](#2-5-11-script-updates)
1. [Fixes to the CIS Compliance Script](#2-5-11-script-fixes)

## <a name="2-5-11-script-performance">Performance update to the CIS Compliance Script</a>
Migrate the querying of resources to Resource Search (a module within Oracle’s API).  By using Resource Search, compartment iterations for listing items are ignored.  For items that require more detailed information than Resource Search returns, only those compartments are queried.  This migration reduces script execution time by 8 times.

## <a name="#2-5-11-script-updates">Updates to the CIS Compliance Script</a>
The CIS Summary report CSV adds two new columns **Compliant Items**, which represents the number of resources that are aligned to that recommendation, and **Total** which is the total number of that resource in tenancy. The **Total** column is also in the screen output.

## <a name="#2-5-11-script-fixes">Fixes to the CIS Compliance Script</a>
Fixes
- Updated the CIS checks 2.1, 2,2, 2.3, and 2.4 to detect Security Lists and Networks Security Groups that allow egress access to ports 22 or 3389 via allowing all protocols, all ports, or using port ranges.
- Updated CIS Check 2.5 to only look at Default Security Lists.


#   May 12, 2023 Release Notes - 2.5.10
1. [Support for Security Tokens in the CIS Compliance Script](#2-5-10-script-updates)
1. [Terraform Template Updates](#2-5-9-tf-updates)

## <a name="2-5-10-script-updates">Support for Security Tokens in the CIS Compliance Script</a>
New:
- Added support of Security Tokens for script authentication courtesy of Dave Knot ([dns-prefetch](https://github.com/dns-prefetch)).  For usage example, go to the [compliance-script.md](https://github.com/oracle-quickstart/oci-cis-landingzone-quickstart/blob/main/compliance-script.md) and review the **Executing on a local machine via Security Token (oci session authenticate)** example. For more information on security tokens: [https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/clitoken.htm](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/clitoken.htm)

## <a name="2-5-10-tf-updates">Terraform Template Updates</a>
Fixes:
- Security rule added for ICMP in Exadata CS security lists, allowing for the initiation of ICMP requests to hosts in the VCN. Changes in [net_exacs_vcns.tf](./config/net_exacs_vcns.tf).
- VSS targets are now created when the Landing Zone is extended to a new region. Changes in [vss.tf](./config/vss.tf).

#   April 26, 2023 Release Notes - 2.5.9
1. [Terraform Template Updates](#2-5-9-tf-updates)

## <a name="2-5-9-tf-updates">Terraform Template Updates</a>
Updates:
- Security Zone is enabled only if an enclosing compartment is used. Changes in [security_zones.tf](./config/security_zones.tf).
- Network event types updated for local peering gateway and service gateway: only event types ending with ".end" are captured. Changes in [mon_notifications.tf](./config/mon_notifications.tf).

#   April 17, 2023 Release Notes - 2.5.8
1. [Compliance Checking Script Updates](#2-5-8-script-updates)
1. [Terraform Template Updates](#2-5-8-tf-updates)

## <a name="2-5-8-script-updates">CIS Compliance Script Updates</a>
Updates:
- Updated CIS rule 1.7 to exclude OCI IAM Local Users that are service accounts.  A service account is a OCI IAM Local user that does not have *Local Password* as a *User Capabilities.*  
- Support validated on OCI SDK 2.97.0.
Fixes:
- Improved error handling for Event Rules with no conditions.

## <a name="2-5-8-tf-updates">Terraform Template Updates</a>
- Compartment level service policies no longer created when extending Landing Zone to new region.
- VSS and Vault resources now dependent on service policies. 

#   April 04, 2023 Release Notes - 2.5.7
1. [Exadata Events Fix](#2-5-7-exadata-events-fix)
1. [Compliance Checking Script Updates](#2-5-7-script-updates)

## <a name="2-5-7-exadata-events-fix">Exadata Events Fix</a>
- Exadata events handled with jsonencode function in [mon_notifications.tf](./config/mon_notifications.tf).

## <a name="2-5-7-script-updates">CIS Compliance Script Updates</a>
Updates:
- Added optionality to the NSG deep_link incase the link is less than 254 characters.
- Updated Release version and date.

Fixes:
- Fixed console output formatting for CIS Summary report.



#   March 24, 2023 Release Notes - 2.5.6
1. [Compliance Checking Script Updates](#2-5-6-script-updates)

## <a name="2-5-6-script-updates">CIS Compliance Script Updates</a>
Updates:
- Added egress rules to Security Lists and Network Security Groups.
- Added DRG Upgrade status as *Upgrade_status* to the `raw_data_network_drgs.csv` file.

Fixes:
- For CIS Recommendations 1.5 and 1.6 now show *Not Applicable* instead of *Yes* or *No* as this is not yet checked by the script.
- Removed filenames for findings with zero findings from the `cis_summary_report.csv` and `cis_html_summary_report.html` reports.

#   March 2, 2023 Release Notes - 2.5.5
1. [OCI IAM Policy Fix for Database Admin Group](#2-5-5-adb-policy-fix)
1. [OCI IAM Service Policy Update](#2-5-5-oci-iam-service-policy)
1. [Enhanced HTML CIS Summary Report](#2-5-5-html-cis-summary)
1. [Compliance Checking Script Updates](#2-5-5-script-updates)


## <a name="2-5-5-adb-policy-fix">OCI IAM Policy Fix for Database Admin Group</a>
Updated OCI IAM policies attached to the Database Admin Group to support deploying ADBs in private subnets. Policy is based on documentation [here](https://docs.oracle.com/en-us/iaas/autonomous-database-shared/doc/iam-private-endpoint-configure-policies.html).

## <a name="2-5-5-oci-iam-service-policy">OCI IAM Service Policy Update</a>
Added an OCI IAM policy to allow OCI services File Storage Service, Object Storage Service, Oracle Kubernetes Engine, Streaming and Block Storage to encrypt data using keys in the OCI Vault in the Security Compartment. 

## <a name="2-5-5-html-cis-summary">Enhanced HTML CIS Summary Report</a>
The HTML CIS Summary report from the CIS compliance checking script has a significantly updated look and feel.

## <a name="2-5-5-script-updates">CIS Compliance Script Updates</a>
- The CIS compliance checking script has added user capabilities to OCI IAM user collection.  These attributes are only available in the `raw_data_identity_users.csv` file.
- Enhanced exception handling for Oracle Best Practice checks.


#   February 10, 2023 Release Notes - 2.5.4
1. [Improved CIS 3.7 and 3.13 Checks](#2-5-4-cis-logic)

## <a name="2-5-4-cis-logic">Improved CIS 3.7 and 3.13 Checks</a>
The CIS Compliance checking script checks for Logging and Monitoring 3.7: *Ensure a notification is configured for IAM policy changes* and Logging and Monitoring 3.13: *Ensure a notification is configured for changes to route tables* has been improved to reduce false positives.

#   February 1, 2023 Release Notes - 2.5.3
1. [HTML CIS Summary Report](#2-5-3-script-html)
1. [Resource Deep Links in CSV](#2-5-3-deep-link)
1. [Improved CIS IAM 1.1 Check](#2-5-3-cis-logic)

## <a name="2-5-3-script-html">HTML CIS Summary Report</a>
The CIS Compliance checking script now outputs an HTML summary report.  The summary report includes additional information from the [CIS OCI Benchmark v1.2](https://www.cisecurity.org/benchmark/oracle_cloud) plus a link to the finding's CSV file.

## <a name="2-5-3-deep-link">Resource Deep Links in CSV</a>
The CIS Compliance checking script CSV reports have a new field `deep_link` which contains a clickable link to the resource in the OCI Console. 

## <a name="2-5-3-cis-logic">Improved CIS IAM 1.1 Check</a>
The CIS Compliance checking script check for Identity and Access Management 1.1: *Ensure service level admins are created to manage resources of particular service* has been improved to reduce false positives. 

#  January 26, 2023 Release Notes - 2.5.2
1. [Service Connector Hub Improvements](#2-5-2-sch-improvements)
1. [CIS Level Setting Updates](#2-5-2-cis-level)

## <a name="2-5-2-sch-improvements">Service Connector Hub Improvements</a>
Service Connector Hub functionality has been improved with the following:
- Audit logs from all tenancy compartments are now captured.
- Support for Logging Analytics as target. With this update, the following targets are supported: Object Storage, Streaming, Functions and Logging Analytics.

## <a name="2-5-2-cis-level">CIS Level Setting Updates</a>
Following updates were made regarding the CIS Level setting (*cis_level* variable):
- Setting *cis_level* variable to "2" is enough for OCI Vault creation. Previously, the OCI Vault creation would also require a bucket and no provided existing vault.
- Write logs for buckets are only created if *cis_level* variable is set to "2". Previously, bucket write logs were not impacted by CIS Level setting.


#  December 16, 2022 Release Notes - 2.5.1
1. [CIS Compliance Script fixes](#2-5-1-script-update)
1. [Improved Terraform Windows Support](#2-5-1-terraform-windows)

## <a name="2-5-1-script-update">CIS Compliance Script fixes</a>
The CIS Compliance Checking script [.cis_reports.py](./scripts/cis_reports.py) has had the following fixes:
- Fixed consolidated xlsx file generation on Windows command line and Powershell.
- Converted from positional arguments in OCI API calls to named arguments.

## <a name="2-5-1-terraform-windows">Improved Terraform Windows Support</a>
Fixed support for deploying terraform via Windows. Closes [Issue](https://github.com/oracle-quickstart/oci-cis-landingzone-quickstart/issues/61).

#  December 05, 2022 Release Notes - 2.5.0
1. [OCI Best Practices Checks Added to CIS Compliance Script](#2-5-0-script-update)
1. [Cloud Guard Improvements](#2-5-0-cloud-guard-improvements)

## <a name="2-5-0-script-update">OCI Best Practices Checks Added to CIS Compliance Script</a>
The CIS Compliance Checking script [.cis_reports.py](./scripts/cis_reports.py) has had the following enhancements:
- CIS compliance checking script has added checking for OCI Best Practices (OBP).  The following OCI Best Practices in your tenancy:
    - Aggregation of OCI Audit compartment logs, Network Flow logs, and Object Storage logs are sent to Service Connector Hub in all regions
    - A Budget for cost track is created in your tenancy
    - Network connectivity to on-premises is redundant 
    - Cloud Guard is configured at the root compartment with detectors and responders 
    
- Redaction of OCIDs before data is written to CSVs using the `--redact` flag.  This uses a sha256 hashes of OCID to maintain OCID consistency across files.
- Reduced script runtime by synchronously reading OCI resources.
- CSV files will be consolidated into a single XLSX file if the python3 environment has `xlsxwriter` installed.  

See [compliance-script.md](./compliance-script.md#usage) for usage.

## <a name="2-5-0-cloud-guard-improvements">Cloud Guard Improvements</a>
Cloud Guard module has been updated with the following features:
- Cloud Guard resources creation made optional, based on *enable_cloud_guard* input variable. Cloud Guard is enabled by default.
- Support for cloned detector and responder recipes, based on *enable_cloud_guard_cloned_recipes* input variable. By default, for keeping backwards compatibility, the module uses Oracle managed recipes.
- Support for customer provided reporting region. If reporting region is not provided, the module defaults to home region.
- Resource Manager user interface reflects above changes.

See [Cloud Guard variables](./VARIABLES.md#cloud-guard-variables) for details.

#  October 28, 2022 Release Notes - 2.4.3
## Bug Fixes
- Arch Center tag module conditioned to Landing Zone not being extended. Fix in [mon_tags.tf](./config/mon_tags.tf).
- CIS Compliance checking script was looking for attributes not available in list analytics and list integrations instances API calls. 
#  October 14, 2022 Release Notes - 2.4.2
1. [Compliance Checking Supports Custom OCI Config File Location](#2-4-2-script-config-file)
1. [Custom Security Zone policies support for all OCI realms](#2-4-2-sz-all-realms)
1. [Bug fixes](#2-4-2-bug-fixes)

## <a name="2-4-2-script-config-file">Compliance Checking Supports Custom OCI Config File Location</a>
The Compliance checking script adds a new flag `-c` that takes the location of an OCI config file. This flag allows users to specify which OCI config file to use instead of using the one in the default location (`~/.oci/config`).

## <a name="2-4-2-sz-all-realms">Custom Security Zone policies support for all OCI realms</a>
Custom Security Zone policies are now supported by CIS Landing Zone in all OCI realms where Custom Security Zones are available.

## <a name="2-4-2-bug-fixes">Bug Fixes</a>
- Incorrect *backups* resource-type replaced by *db-backups* for database admin grants in [iam_policies.tf](./config/iam_policies.tf).
- Event types fixed for Exadata Cloud Service in [mon_notifications.tf](./config/mon_notifications.tf).

# September 16, 2022 Release Notes - 2.4.1
1. [Compliance Checking Report Identity Domain Fix](#2-4-1-script-fix)

## <a name="2-4-1-script-fix">Compliance Checking Report Identity Domain Fix</a>
Until this update, a user in the CIS Landing Zone Auditor group would not have been able to successfully run the compliance checking script in tenancies with Identity Domains.  The reason is tenancies with Identity Domains require elevated privileges to check the tenancies password policy.  With release 2.4.1 if the user doesn't have permissions to check password policy the script will continue running and just print an alert.

# September 09, 2022 Release Notes - 2.4.0
1. [Terraform Requirements](#2-4-0-tf-reqs)
1. [CIS OCI Benchmark Configuration Profiles](#2-4-0-cis-level)
1. [Custom Security Zones](#2-4-0-csz)
1. [Service Connector Hub Improved Configuration](#2-4-0-sch-update)
1. [Vulnerability Scanning Improved Configuration](#2-4-0-vss-update)
1. [Application Bucket Improved Configuration](#2-4-0-appdev-bucket-update)
1. [Data Safe Permissions](#2-4-0-datasafe-perms)

## <a name="2-4-0-tf-reqs">Terraform Requirements</a>
**The Terraform features in this release and future releases of the CIS Landing Zone will require Terraform binary 1.1.0 or higher**, where the *moved* block feature is available. The *moved* block provides a transparent way for preserving backwards compatibility in face of required code changes. We have consolidated all *moved* blocks in [moved.tf](./config/moved.tf). For details on this feature, please see: [Terraform's documentation on refactoring](https://www.terraform.io/language/modules/develop/refactoring).

## <a name="2-4-0-cis-level">CIS OCI Benchmark Configuration Profiles</a>
CIS Landing Zone introduces the ability to choose the CIS OCI configuration profile defined in the Benchmark. 

When deploying CIS Landing Zone, users can now specify the CIS configuration profile level using the variable *cis_level* and it defines the configuration of some Landing Zone managed resources. For this release, the affected resources are Object Storage Buckets and Security Zones. The *cis_level* setting drives how buckets are encrypted and the minimum set of policies in a Security Zone.

## <a name="2-4-0-csz">Security Zones</a>
CIS Landing Zone adds to the overall tenancy security posture with the support for [Security Zones](https://docs.oracle.com/en-us/iaas/security-zone/using/security-zones.htm). Landing Zone users can now enable Security Zones for Landing Zone managed compartments and specify which policies to apply. These policies are the preventive controls that make sure a tenancy stays within the defined track as it evolves over time.  

Aligning with the [CIS OCI Benchmark Configuration Profile](#2-4-0-cis-level) feature, if *cis_level* is set to 1, the provided Security Zone policies are aligned to the CIS OCI Benchmark configuration profile Level 1. If *cis_level* is set to 2, the provided Security Zone policies are aligned to the CIS OCI Benchmark configuration profile Level 2. Below are the Security Zone policies to configuration profile level.

| CIS Recommendation | CIS Level | Security Zone Policy Name               | Security Zone Policy Description                                                                                                                                               |
| ------------------ | --------- | --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 4.1.1              | 1         | deny public\_buckets                    | Object Storage buckets in a security zone can't be public.                                                                                                                     |
| 2.8.0              | 1         | deny db\_instance\_public\_access       | Databases in a security zone can't be assigned to public subnets. They must use private subnets.                                                                               |
| 4.2.1              | 2         | deny block\_volume\_without\_vault\_key | Block volumes in a security zone must use a customer-managed master encryption key in the Vault service. They can't use the default encryption key managed by Oracle.          |
| 4.2.2              | 2         | deny boot\_volume\_without\_vault\_key  | Boot volumes in a security zone must use a customer-managed master encryption key in the Vault service. They can't use the default encryption key managed by Oracle.           |
| 4.1.2              | 2         | deny buckets\_without\_vault\_key       | Object Storage buckets in a security zone must use a customer-managed master encryption key in the Vault service. They can't use the default encryption key managed by Oracle. |
| 4.3.1              | 2         | deny file\_system\_without\_vault\_key  | File systems in the security zone must use a customer-managed master encryption key in the Vault service. They can't use the default encryption key managed by Oracle.         |

## <a name="2-4-0-sch-update">Service Connector Hub Improved Configuration</a>
The [Service Connector Hub module](./config/mon_service_connector.tf) as announced in [Updated Logging Architecture](#2-3-6-updated-logging) has been updated to optionally deploy Service Connector Hub related resources. As a result, existing users need to set *enable_service_connector* and *activate_service_connector* variables to *true* for Service Connector Hub resources to be created and to activate the service. For details, look at *enable_service_connector* and *activate_service_connector* variables in [VARIABLES.md](./VARIABLES.md#logging_variables).

When deploying an Object Storage bucket as Service Connector target, users can now bring an existing key for bucket encryption. For details, look at *existing_service_connector_bucket_vault_compartment_id*, *existing_service_connector_bucket_vault_id* and *existing_service_connector_bucket_key_id* variables in [VARIABLES.md](./VARIABLES.md#logging_variables). Aligning with the [CIS Profile Levels](#2-4-0-cis-level) feature, if *cis_level* is set to 1, the bucket is encrypted with an Oracle-managed key; if *cis_level* is set to 2, a customer-managed key (either provided or managed by Landing Zone) is used for bucket encryption.

## <a name="2-4-0-vss-update">Vulnerability Scanning Improved Configuration</a>
Users have more control on Landing Zone Vulnerability Scanning recipes. It is now possible to specify the levels for port scan, agent-based scan and CIS setting for agent-based scans. Additionally, users can enable file scanning for Linux systems and specify the folders to scan. Variables are described in [VARIABLES.md](./VARIABLES.md#vss_variables).

Vulnerability Scanning is now disabled by default in CIS Landing Zone. Moving forward, the intent is enabling by default only those services that are required by CIS Benchmark. Existing users who are managing Vulnerability Scanning resources with Landing Zone should simply enable it back, by setting *vss_create* variable to true.

A bug preventing Vulnerability Scanning target creation in default enclosing compartment has been fixed.

## <a name="2-4-0-appdev-bucket-update">Application Bucket Improved Configuration</a>
Previous to this release, CIS Landing Zone would manage a sample bucket in the Application compartment (a.k.a AppDev) and encrypt it with a customer-managed key. This has changed. Now the bucket creation is optional, and when deployed, the user has a choice to bring an existing key for encryption. Aligning with the [CIS Profile Levels](#2-4-0-cis-level) feature, if *cis_level* is set to 1, the bucket is encrypted with an Oracle-managed key; if *cis_level* is set to 2, a customer-managed key (either provided or managed by Landing Zone) is used for bucket encryption.

## <a name="2-4-0-datasafe-perms">Data Safe Permissions</a>
In the config directory, management permission for the Data Safe family has been added to the Database Administrators and Exadata Infrastructure Administrators groups. Read permission for the Data Safe family has been added to the Auditors group.

In the pre-config directory, read permission for the Data Safe family has been added to the Database Administrators and Auditors groups.

##

# July 11, 2022 Release Notes - 2.3.6
1. [Cloud Guard Events](#2-3-6-cg-events)
1. [Updated Logging Architecture](#2-3-6-updated-logging)
1. [Terraform OCI Provider Moved to oracle/oci](#2-3-6-provider-switch)
1. [Architecture Center Tag](#2-3-6-arch-center-tag)
1. [CIS Compliance Checking Script Update](#2-3-6-cis-script-update)

## <a name="2-3-6-cg-events">Cloud Guard Events</a>
Cloud Guard events have been added to Landing Zone notifications framework. Now users can be notified about Cloud Guard problems that exceeds a user provided criticality threshold.  To support this two new variables have been added to the Cloud Guard Section: `cloud_guard_risk_level_threshold` and `cloud_guard_admin_email_endpoints`. The risk_level_threshold determines what problems will trigger the event rule and send an email to the subscription in the new topic. A level of 'High' will include any problems with a risk level of High or above. This would include High and Critical problems. The event rule looks at any of the 3 Cloud Guard events: Problem Detected, Problem Dismissed and Problem Remediated.

## <a name="2-3-6-updated-logging">Updated Logging Architecture</a>
The [Service Connector Hub module](./config/mon_service_connector.tf) has been updated to align with the [best practice architecture for third-party SIEM tools](https://github.com/oracle-quickstart/oci-arch-logging-splunk).
Now there is a single Landing Zone Service Connector that ingests three log sources (Audit logs, VCN flow logs and Object Storage logs) into a target resource of choice: Object Storage Bucket, Stream or Function.
Landing Zone creates the Bucket and can either create the Stream or use an existing one. If a Function is the target, it must be provided as an input.

## <a name="2-3-6-provider-switch">Terraform OCI Provider Moved to oracle/oci</a>
Landing Zone has been updated with the new home for Terraform OCI provider. It has moved to oracle/oci from hashicorp/oci. 
- Existing Landing Zone customers who use Terraform CLI are required to replace the provider in the state file. To update the state file, run the command below in the folder where the state file is present:

        > terraform state replace-provider hashicorp/oci oracle/oci

- Existing Landing Zone customers who use OCI Resource Manager do not need to do anything, as Resource Manager will update the state file based on the new Landing Zone configuration. 

As part of this move, we have introduced provider requirements expressed in [provider.tf](./config/provider.tf):
- Terraform required version >= 1.0.0
- OCI provider version >= 4.78.0

## <a name="2-3-6-arch-center-tag">Architecture Center Tag</a>
A [defined tag](./config/mon_tags.tf) to track Landing Zone deployments through [OCI Architecture Center](https://docs.oracle.com/solutions/) has been added.

## <a name="2-3-6-cis-script-update">CIS Compliance Checking Script Update</a>
The CIS Compliance checking script now consolidates regional output.  There is a single directory which contains the summary report and findings reports in a directory, the name includes the tenancy name and datetime ex. `<tenancy-name>-2022-MM-DD_HH-MM/`.  The findings CSV in that directory now have a region column to tell you which region the resource is located. 

In addition two new flags have been added:
- `--region` - pass an OCI region name(s) ex. `--region us-ashburn-1,eu-frankfurt-1` and the script will check that region's resources for CIS compliance 
- `--raw` - will output all OCI resource data collected into CSV files with the OCI Service name 

For more details on these flags [compliance-script.md](./compliance-script.md)

# June 13, 2022 Release Notes - Stable 2.3.5
1. [CIS Compliance Checking Script 1.2 update](#2-3-5-script-update)
1. [CIS 1.2 OCI IAM Policy Updates and Storage Admin](#2-3-5-storage_admin)
1. [Connectivity Section Usability Improvements in Resource Manager](#2-3-5-conn_usage)
1. [Removed Public RDP Access](#2-3-5-rdp-public-removal)


## <a name="2-3-5-script-update">CIS Compliance Checking Script 1.2 update</a>
The CIS reports script ([cis_reports.py](./scripts/cis_reports.py)) has been updated to check a tenancy’s compliance with the [CIS OCI Foundations Benchmark 1.2.0]( https://www.cisecurity.org/benchmark/oracle_cloud).  In addition to the new compliance checks, we have streamlined the checks in non-home regions to exclude the IAM since it is redundant.  We also added a new flag `--level` which allows you to run all the CIS OCI Foundations Benchmark 1.2 checks or only those checks associated with Level 1.  The [documentation](./compliance-script.md) for the CIS reports script has been updated to reflect this release.

You can learn about what was added to version 1.2 of the benchmark [here](https://www.ateam-oracle.com/post/the-center-for-internet-security-oracle-cloud-infrastructure-foundations-benchmark-12-release-update). 


## <a name="2-3-5-storage_admin">CIS 1.2 OCI IAM Policy Updates and Storage Admin</a>
We have introduced a group for storage management, entitled to delete OCI storage resources across Landing Zone compartments. The feature implements the recommendation 1.14 of CIS OCI Foundations Benchmark v1.2.0 that states *Ensure storage service-level admins cannot delete resources they manage*, ensuring segregation of duties from service-level administrators, who cannot delete resources they are managing.

Our recommendation for using this group is to place users in it when they must delete an OCI storage resource and then remove their access once that resource is deleted.

In addition we reviewed our policy for consistency.

## <a name="2-3-5-conn_usage">Connectivity Section Usability Improvements</a>
The *Connectivity* variables group in [schema.yml](./config/schema.yml) for OCI Resource Manager UI have been split for improved usability. Now we have separate sections for Hub/Spoke, Public Connectivity, Connectivity to on-premises and DRG. Some section titles and variables descriptions have also been updated.

## <a name="2-3-5-rdp-public-removal">Removed Public RDP Access</a>
We no longer grant RDP access to the bastion NSGs for `public_src_bastion_cidrs` CIDR addresses thus preventing public access to RDP.

# May 11, 2022 Release Notes - Stable 2.3.4
1. [Configurable Cloud Guard Alerting](#cg_alerting)
1. [Advanced Options Check Preservation in Resource Manager](#orm_adv_options)
1. [Notification Endpoints not Required by CIS Not Shown By Default](#hidden_endpoints)
1. [ExaCS VCN Route Table Fix](#exacs_vcn_rt_fix)

## <a name="cg_alerting">Configurable Cloud Guard Alerting based on Problem Risk Level</a>
Cloud Guard Alerting can optionally be configured by the Landing Zone. Two new variables have been added to the Cloud Guard Section: cloud_guard_risk_level_threshold and cloud_guard_admin_email_endpoints. A new topic and new Event rule will be created only if a valid Email Endpoint is provided. The risk_level_threshold determines what problems will trigger the event rule and send an email to the subscription in the new topic. A level of 'High' will include any problems with a risk level of High or above. This would include High and Critical problems. The event rule looks at any of the 3 Cloud Guard events: Problem Detected, Problem Dismissed and Problem Remediated.

## <a name="orm_adv_options">Advanced Options Check Preservation for Resource Manager</a>
CIS Landing Zone interface for Resource Manager has check boxes allowing for advanced input options, hiding or showing groups of variables. The state of these options used to be reset when users needed to update the variables in the UI, hiding options chosen previously. Now the state is saved and no longer reset. Changes made in [config/variables.tf](./config/variables.tf).

## <a name="hidden_endpoints">Notification Endpoints not Required by CIS Not Displayed By Default</a>
Except for Security and Network notifications, all other endpoints are no longer displayed by default in [config/schema.yml](./config/schema.yml) for OCI Resource Manager. A new _Additional Notification Endpoints_ check box displays them when checked. 

## <a name="exacs_vcn_rt_fix">ExaCS VCN Route Table Fix</a>
A fix in the [route table of the Client subnet](./config/net_exacs_vcns.tf) allows for proper on-premises routing with or without a DMZ VCN. If a DMZ VCN is deployed, traffic to an on-premises IP address goes through the VCN. Otherwise, traffic goes to on-premises directly through the DRG.

# April 6, 2022 Release Notes - Stable 2.3.3
1. [Cloud Guard Updates](#cg_updates)
1. [VSS Policy Update](#vss_update)
1. [Code Examples Aligned with Deployment Guide](#code_examples)

## <a name="cg_updates">Cloud Guard Updates</a>
- [Cloud Guard policy](./config/iam_service_policies.tf) has been simplified with *Allow service cloudguard to read all-resources in tenancy*. This way no policy changes are needed as new services are integrated with Cloud Guard.
- [Cloud Guard enablement](./config/mon_cloud_guard.tf) and [target creation logic](./modules/monitoring/cloud-guard/main.tf) have been updated, but still based on *cloud_guard_configuration_status* variable. When the variable is set to 'ENABLE', Cloud Guard is enabled and a target is created for the Root compartment. **Customers need to make sure there is no pre-existing Cloud Guard target for the Root compartment or target creation will fail**. If there is a **pre-existing** Cloud Guard target for the Root compartment, set the variable to 'DISABLE'. In this case, any **pre-existing** Cloud Guard Root target is left intact. However, keep in mind that once you set the variable to 'ENABLE', Cloud Guard Root target becomes managed by Landing Zone. If later on you switch to 'DISABLE', Cloud Guard remains enabled but the Root target is deleted.

## <a name="vss_update">VSS Policy Update</a>
[Policy update](./config/iam_service_policies.tf) allowing Vulnerability Scanning Service (VSS) to scan containers in OCI Registry: *Allow service vulnerability-scanning-service to read repos in tenancy*.

## <a name="code_examples">Code Examples Aligned with Deployment Guide</a>
An [examples](./examples/) folder has been added showcasing input variables for the various deployment samples provided in the [deployment guide](DEPLOYMENT-GUIDE.md). The examples follow Oracle documentation guidelines for acceptable company name.

# March 18, 2022 Release Notes - Stable 2.3.2
1. [Deployment Guide](#deployment_guide)
1. [Reviewed IAM Admin Policies](#iam_policies_review)

## <a name="deployment_guide">Deployment Guide</a>
A compreehensive [deployment guide](DEPLOYMENT-GUIDE.md) for CIS Landing Zone is now available. It covers key deployment considerations, the architecture, major deployment scenarios, customization guidance, detailed steps how to deploy using Terraform CLI and with Resource Manager UI/CLI as well as various deployment configuration samples.

## <a name="iam_policies_review">Reviewed IAM Admin Policies</a>
IAM admin policy has been updated to not allow IAM administrators to manage compartments and policies at the Root compartment, thus avoiding privilege escalation.

# February 25, 2022 Release Notes - Stable 2.3.1
1. [Configurable Spoke Subnet Names and Subnet Sizes](#spoke_config)
1. [Updated Compute Dynamic Group to support OS Management](#dg_osms)
1. [Fixed Internet Gateway Creation in ExaCS VCN](#exacs_fix)
1. [Updated Bastion NSG to include RDP](#rdp_update)
1. [Tagging Support](#tagging)

## <a name="spoke_config">Configurable Spoke Subnet Names and Subnet Sizes</a>
The names and the size of subnets created in spoke VCN(s) can now be configured using the variables: **subnets_names** and **subnets_sizes**. Ex. `["front", "middle", "back"]` and `["12","8","10"]`.  Additional customization of spoke VCNs can be done in net_vcn.tf or with  using [Terraform Override Files](https://www.terraform.io/language/files/override).
Check [Known Issues](README.md#know-issues) section for an issue affecting custom subnets sizes in Resource Manager UI.

## <a name="dg_osms">Updated Compute Dynamic Group to support OS Management</a>
Added IAM policy statements to the compute agent dynamic group policy to include support for OS Management.

## <a name="exacs_fix">Fixed Internet Gateway Creation in ExaCS VCN</a>
Disabled creation of Internet Gateway in ExaCS VCNs.

## <a name="rdp_update">Updated Bastion NSG to include RDP</a>
Added port 3389 to the Bastion Network Security Group (NSG) to support Remote Desktop Protocol (RDP) for Windows based instances.

## <a name="tagging">Tagging Support</a>
The Landing Zone fully supports definition and usage of defined_tags and freeform_tags for all resources. In this release there is no additional variable to be set in the quickstart-input.tfvars. Tag definition and usage can be set using [Terraform Override Files](https://www.terraform.io/language/files/override).

Usage Overview:
- Defined tags - At the moment, using Defined Tags is a two step process.
  1. Create the defined tags.
  1. Use the defined tags.
- Freeform tags - Freeform tags can be used at any time. You simply assign a map of freeform tags, to a predefined local variable in an override file, for example ```all_keys_freeform_tags = {"cis-landing-zone" : "${var.service_label}-quickstart"}```.

Please note that space characters (' ') in the tag names are not supported by OCI.

# February 02, 2022 Release Notes - Stable 2.3.0
1. [Cross Region Landing Zone](#cross_region_lz_2_3_0)
1. [Bring Existing Dynamic Groups](#byodg_2_3_0)
1. [CCCS Guard Rails](#script_2_3_0)
1. [Landing Zone Logo](#lz_logo_2_3_0)
1. [Customized VCN and Subnet deployment option](#lz_vcn_2_3_0)

## <a name="cross_region_lz_2_3_0">Cross Region Landing Zone</a>
When you run Landing Zone's Terraform, some resources are created in the home region, while others are created in a region of choice. Among home region resources are compartments, groups, dynamic groups, policies, tag defaults and an infrastructure for IAM related notifications (including events, topics and subscriptions). Among resources created in the region of choice are VCNs, Log Groups, and those pertaining to security services like Vault Service, Vulnerability Scanning, Service Connector Hub, Bastion. The home region resources are automatically made available by OCI in all subscribed regions.

Some customers want to extend their Landing Zone to more than one region of choice, while reusing the home region resources. One typical use case is setting up a second region of choice for disaster recovery, reusing the same home region Landing Zone resources. A more broad use case is implementing a single global Landing Zone across all subscribed regions. These use cases are now supported via the newly introduced *extend_landing_zone_to_new_region*. When set to true, compartments, groups, dynamic groups, policies and resources pertaining to home region are not provisioned, but reused instead.

## <a name="byodg_2_3_0">Bring Existing Dynamic Groups</a>
As with groups, Landing Zone now supports reusing existing *dynamic* groups. These dynamic groups are thought to be used by OCI Functions, Compute's management agent and databases for calling out other services. 

## <a name="script_2_3_0">CCCS Guard Rails</a>
The Compliance Checking script's summary report now includes a column for CCCS Guard Rails.

## <a name="lz_logo_2_3_0">Landing Zone Logo</a>
Landing Zone has been gifted with a logo. A courtesy from our colleague [Chris Johnson](https://github.com/therealcmj).   

## <a name="lz_vcn_2_3_0">Customized VCN and Subnet deployment option</a>
This release provides the option to easily customize your VCNs and Subnets in terms of cidr ranges and naming using a map resource called custom_vcns_map.
Please note as part of this release we have also updated the default Database subnet to include a routing rule for sending traffic destined for 0.0.0.0/0 to the NAT Gateway.
However the default Network Security Group will still prevent any egress to the internet until it is changed by you.


# December 02, 2021 Release Notes - Stable 2.2.0
1. [Updated Topics and Subscription Module (Impacts existing deployments)](#topics_2_2_0)
1. [Enablement of Operational Events and Alarms Specific to Compute, Storage, Database and Governance](#events_and_alarms_2_2_0)
1. [Compliance Checking Script Runs in All Regions](#script_update_2_2_0)
1. [Click to Deploy button](#click_to_deploy_2_2_0)
1. [Added SVG versions of Core Architecture Files](#svg_architecture_files)
1. [Added an optional Budget and Budget Alert Rule](#budget_2_2_0)


## <a name="topics_2_2_0">Updated Topics and Subscription Module (Impacts existing deployments)</a>
In previous versions of the Landing Zone Topics and Subscriptions were a single module.  Going forward there will be a [Topics Module](modules/topics-v2/toopics/README.md) and a [Subscription Module](modules/topics-v2/subscriptions/README.md). **Due to this change upgrading an existing Landing Zone deployment will cause the Security Topic and Subscriptions as well as the Network Topic and Subscriptions to be deleted and recreated.** This will require users receiving these email notifications to re-accept their subscriptions.

## <a name="events_and_alarms_2_2_0">Enablement of Operational Events and Alarms Specific to Compute, Storage, Database and Governance</a>
Customers can now deploy events and alarms specific to operational areas including Compute, Storage, Database and Governance as part of the default Landing Zone deployment. Operational alarms and events can be enabled by entering an email address in. This includes following alarms:
- AppDev Compartment
    - Instance based monitoring and alerting of high cpu and high memory usage for instances deployed in the AppDev compartment.
    - Bare metal unhealthy and VM maintenance alarms are also part of the new core compute alarm set.
- Database Compartment 
    - Databases deployed in the Database compartment operational events and alerts have been enabled for for high ADB CPU and high ADB Storage usage.
    - Autonomous Database Critical Events and ExaData CS Infrastructure events are now tracked in this release.
- Network Compartment
    - Up/Down status for VPN and FastConnect services in the Network compartment of the Landing Zone.

## <a name="script_update_2_2_0">Compliance Checking Script Runs in All Regions</a>
The compliance checking script now runs checks on all available regions in the tenancy and has improved handling of Oracle PSM policy statements.

## <a name="click_to_deploy_2_2_0">Click to Deploy button</a>
Resource Manager stack can be created directly from GitHub repository through a single button click. The zip file with the source code is passed directly to Resource Manager Create Stack API. 

## <a name="svg_architecture_files">Added SVG versions of Core Architecture Files</a>
Added SVG versions of Core Architecture Files so users can modify the architectures using Draw.io.

## <a name="budget_2_2_0">Added an optional Budget and Budget Alert Rule</a>
Customers can now choose to deploy a budget at the root or enclosing compartment level to track monthly spending and be alerted if a forcasted spending breaches a defined threshold. 

A Cost Managment Admin group is also created that grants permission to Create,Update,Delete budgets and also review Cost Data in the UI or by downloading the detailed Cost Reports.
Cost Data View Only permissions have been added to the policies for: Auditor, Database Admin, AppDev Admin, Network Admin and Security Admin allowing members of these groups to review spending. 
  
# October 13, 2021 Release Notes - Stable 2.1.1
1. [CIS Compliance Checking Script Updates](#cis_script_2_1_1)
1. [Bastion Service Enabled by public_src_bastion_cidrs](#bastion_service_update)

## <a name="cis_script_2_1_1">CIS Compliance Checking Script Updates</a>
CIS Compliance checking script will now prepend the OCI tenancy's display name to the output directory it creates if no directory is specified.  An example output directory `tenancy_display_name-20211013`.

## <a name="bastion_service_update">Bastion Service Enabled by public_src_bastion_cidrs</a>
Now [OCI Bastion service] (https://docs.oracle.com/en-us/iaas/Content/Bastion/Concepts/bastionoverview.htm) is enabled when one or more *public_src_bastion_cidrs* are provided **and** a single VCN deployment is selected.  In the previous version it was enabled by default in a single VCN deployment.

# September 24, 2021 Release Notes - Stable 2.1.0
1. [Ability to Provision Infrastructure for Exadata Cloud Service Deployments](#exadata_2_1_0)
1. [OCI Bastion Service Integration](#bastion_2_1_0)
1. [Individual Security Lists for Subnets](#sec_lists_2_1_0)
1. [Ability to Rename Compartments](#cmp_renaming_2_1_0)
1. [Updates to NSGs and Route Rules Descriptions](#rules_descriptions_update_2_1_0)
1. [Input Variable for SSH Connectivity from On-premises Network](#on_prem_ssh_cidrs_2_1_0)
1. [Updates to Resource Manager Interface](#orm_update_2_1_0)

## <a name="exadata_2_1_0">Ability to Provision Infrastructure for Exadata Cloud Service Deployments</a>
Landing Zone can now provision VCNs, compartment, group and policies for Exadata Cloud Service (ExaCS) deployments. The provisioned resources are deployed in tandem with the overall Landing Zone configuration. VCNs are provisioned with client and backup subnets. If a Hub & Spoke network architecture is being deployed, the ExaCS VCNs are configured as spoke VCNs. A compartment is by default created for the ExaCS infrastructure and an extra group and policies are configured accordingly. Optionally, users may opt for deploying ExaCS infrastructure in the database compartment with appropriate permissions granted to database administrators.

## <a name="bastion_2_1_0">OCI Bastion Service Integration</a>
Customers can now leverage OCI Bastion Service in Landing Zone. A Bastion resource is provisioned into a VCN if a single VCN or a single ExaCS VCN is being deployed. Customers can later on create a Bastion session using the provisioned Bastion resource. The Bastion resource is not provisioned for Hub & Spoke architecture or if the Landing Zone VCNs are connected to an on-premises network. In these cases, SSH inbound access is expected to be provided by Bastion servers in the DMZ (Hub) or hosts in the on-premises network.

## <a name="sec_lists_2_1_0">Individual Security Lists for Subnets</a>
Individual security lists are now created for all subnets. This is useful for customers planning on deploying services that require Security Lists instead of Network Security Groups.

## <a name="cmp_renaming_2_1_0">Ability to Rename Compartments</a>
Landing Zone creates compartments with auto-generated names, prefixed by the service_label variable value. Landing Zone compartments can be renamed at any point in time with all policies adjusted accordingly. 

## <a name="rules_descriptions_update_2_1_0">Updates to NSGs and Route Rules Descriptions</a>
The descriptions of rules in NSGs and route tables have been updated aiming at more clarity and verbiage standardization.

## <a name="on_prem_ssh_cidrs_2_1_0">Input Variable for SSH Connectivity from On-premises Network</a>
Variable *onprem_src_ssh_cidrs* is introduced. It is a list of on-premises CIDR blocks allowed to connect to Landing Zone over SSH. It is added to network security rules for ingress connectivity to Landing Zone networks. The *on_prem_ssh_cidrs* must be a subset of the *onprem_cidrs* variable, which are used for routing between on-premises and Landing Zone networks.

## <a name="orm_update_2_1_0">Updates to Resource Manager Interface</a>
With the introduction of Exadata Cloud Service support, Landing Zone schema.yaml has been updated for better usability in OCI Resource Manager. A new variable group named 'Connectivity' has been introduced, containing variables for defining properties that control the sources and destinations for Landing Zone connectivity. 


# August 12, 2021 Release Notes - Stable 2.0.3
1. [Ability to use existing Dynamic Routing Gateway (DRG) v2 with the Landing Zone](#existing_drg_2_0_3)
1. [Consolidated Network and IAM Notifications](#notifications_consolidation_2_0_3)
1. [Database Customer Managed Key Support](#database_key_support_2_0_3)
1. [Compliance Checking supports free tier tenancy](#cis_report_update_2_0_3)


## <a name="existing_drg_2_0_3"></a>1. Ability to use existing Dynamic Routing Gateway (DRG) with the Landing Zone
Customers that have an existing DRG v2 (a DRG created after April 15, 2021) can now use that existing DRG v2 instead of having the Landing Zone create a new DRG v2. This is useful for customers that have connected a FastConnect to an existing DRG.

## <a name="notifications_consolidation_2_0_3"></a>2. Consolidated Network and IAM Notifications
In previous versions of the Landing Zone notification event rules were created for each CIS benchmark monitoring recommendation.  To help reduce the number of event rules created all the IAM recommendations are combined into a single event rule and all the network recommendations are combined into another event rule. 

## <a name="database_key_support_2_0_3"></a>3. Autonomous Database Customer Managed Key Support
Database Administrators now have the ability to use keys from OCI Vaults in the security compartment to encrypt databases in the database compartment.

## <a name="cis_report_update_2_0_3"></a>4. Compliance Checking supports free tier tenancy
Compliance Checking script can now be run free tier OCI tenancy.

# July 2021 Release Notes - Stable 2.0.0
1. [Ability to provision the Landing Zone with narrower permissions](#narrower_permissions)
1. [Ability to provision Landing Zone within an enclosing compartment at any level in the compartment hierarchy](#enclosing_compartment)
1. [Ability to reuse existing groups when provisioning the Landing Zone](#existing_groups)
1. [Hub and Spoke Network Architecture plus networking enhancements](#hub_spoke_network)


## <a name="narrower_permissions"></a>1. Ability to provision the Landing Zone with narrower permissions
Before this release, the Landing Zone required a user with wide permissions in the tenancy in order to be provisioned. Typically, but not necessarily, this user was a member of the *Administrators* group. That has changed. Now the Landing Zone can be provisioned by a user with narrower permissions. However, some pre-requisites need to be satisfied. Specifically, the Landing Zone requires policies created at the tenancy level and broad permissions at the compartment where it is going to be provisioned. 

The Landing Zone handles these requirements with a new Terraform root module that's expected to be executed by a user with wide permissions (typically a member of the *Administrators* group). The module is available in the *pre-config* folder and provisions the following:
	
1. An enclosing compartment for the Landing Zone compartments. 
2. Optionally, a group with the required permissions to provision the Landing Zone in the enclosing compartment.
3. Optionally, Landing Zone required groups for segregation of duties. These groups can then simply be reused when provisioning the Landing Zone.
4. Optionally, required permissions at the tenancy level granted to Landing Zone groups, like permissions granted to Security and IAM administrators.

The variables controlling the pre-config module behavior are described in [Pre-Config Module Variables section](VARIABLES.md#pre_config_input_variables).
	
## <a name="enclosing_compartment"></a>2. Ability to provision Landing Zone within an enclosing compartment at any level in the compartment hierarchy
This can be done by a *wide-permissioned* user or a *narrower-permissioned* user. If done by the *wide-permissioned* user, the steps described in the previous section MUST be skipped. If done by a *narrower-permissioned* user, the steps in the previous section are required. **A _narrower-permissioned_ user is only allowed to provision the Landing Zone in a enclosing compartment previously designated by a _wide-permissioned_ user.**
	
The existing Landing Zone config module has been extended to support this use case. The module keeps backwards compatibility, i.e., the new variables default values keeps the module current behavior unchanged. In other words, if you execute the config module as-is, the four Landing Zone compartments are created directly under the root compartment with all policies created at the root compartment. 

The module behavior is controlled by variables described in the [Enclosing Compartment Variables section](VARIABLES.md#enc_cmp_variables).
	
## <a name="existing_groups"></a>3. Ability to reuse existing groups when provisioning the Landing Zone
Previously, every Landing Zone execution would create groups. However, it's acknowledged that a customer may want to create multiple Landing Zones but only one set of groups, reusing them across the Landing Zones. 

The module behavior is controlled by variables described in the [Existing Groups Reuse Variables section](VARIABLES.md#existing_groups_variables).

## <a name="hub_spoke_network"></a>4. Hub and Spoke Network Architecture plus networking enhancements

Before this release, the Landing Zone would deploy a single VCN with three subnets designed for a 3-tier application with DRG if on-premises connectivity was required.  In this new release we enhanced the networking and network security modules to can support the creation of multiple VCNs (spokes or stand-alone) and the following Hub and Spoke network architectures:
- **Access to multiple VCNs in the same region:** This scenario enables communication between an on-premises network and multiple VCNs in the same region over a single FastConnect private virtual circuit or Site-to-Site VPN and uses a DRG as the hub.
- **Access between multiple networks through a single DRG with a firewall between networks:** This scenario connects several VCNs to a single DRG, with all routing configured to send packets through a firewall in a hub VCN before they can be sent to another network.

In addition to the above architectures, you can choose if want to allow the creation of Internet Gateways and NAT Gateways to provide a more isolated network. Lastly, we have also added support for various network variables to take lists of CIDR ranges instead of a single CIDR. 

The module behavior is controlled by variables described in the [Networking Variables section](VARIABLES.md#networking-variables).


# June 2021 Release Notes - Stable 1.1.1
1. [Logging Consolidation with Service Connector Hub](#logging_consolidation)
1. [Vulnerability Scanning](#vulnerability_scanning)

	
## <a name="logging_consolidations"></a>1. Logging Consolidation with Service Connector Hub
The Landing Zone enables/collects logs for a few services, like VCN and Audit services. From a governance perspective, it's interesting that these logs get consolidated and made available to security management tools. This capability is now availabe in the Landing Zone with the Service Connector Hub, that reads logs from different sources and sends them to a target that the user chooses. By default, this target is a bucket in the Object Storage service, but functions and streams can also be configured as targets. As the usage of a bucket, function or stream may incur in costs to our customers, Landing Zone users must explicitly activate Service Connector Hub by setting variables in the Terraform configuration, as described in [Logging Variables](terraform.md#logging_variables) section.

To delete or change a Service Connector that has an Object Storage bucket as a target, you must manually remove the target from the Service Connector and manually delete the bucket. A bucket with objects cannot be deleted via Terraform.

## <a name="vulnerability_scanning"></a>2. Vulnerability Scanning
The Landing Zone now enables scanning through the Vulnerability Scanning Service (VSS), creating a scan recipe and scan targets by default. The recipe is set to run every week on sundays and the targets are set to all four Landing Zone compartments. Running the Landing Zone as is, weekly scans are automatically executed for any instances deployed in any of the Landing Zone compartments. The scan results are made available in the Security compartment and can be verified in the OCI Console. 

Scanning can be disabled in the Landing Zone, and the scan frequency and targets can be changed as well. Disabling scanning and changing the frequency are controlled by setting variables in the Terraform configuration, as described in [Scanning Variables](terraform.md#vss_variables) section, while targets can be changed in the vss.tf file. The Vulnerability Scanning Service is free.
