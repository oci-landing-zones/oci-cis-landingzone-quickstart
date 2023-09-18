# Compliance Checking Script
1. [Overview](#overview)
1. [Setup](#setup)
1. [Output](#output)
1. [Usage](#usage)
1. [FAQ](#faq)


## <a name="overview"></a>Overview
The Compliance Checking script checks a tenancy's configuration against the CIS OCI Foundations Benchmark. In addition to CIS checks it can be check for alignment to OCI Best Practices  by using the `--obp` flag.  These checks review the following OCI best practices in your tenancy:
- Aggregation of OCI Audit compartment logs, Network Flow logs, and Object Storage logs are sent to Service Connector Hub in all regions
- A Budget for cost track is created in your tenancy
- Network connectivity to on-premises is redundant 
- Cloud Guard is configured at the root compartment with detectors and responders 

The script is located under the *scripts* folder in this repository. It outputs a summary report CSV as well individual CSV findings report for configuration issues that are discovered in a folder(default location) with the region, tenancy name, and current day's date ex. ```<tenancy_name>-2022-12-02_13-50-30/```. 

## <a name="setup"></a>Setup 

### Required Permissions
The **Auditors Group** that is created as part of the CIS Landing Zone Terraform has all the permissions required to run the compliance checking in the tenancy.  Below is the minimum OCI IAM Policy to grant a group the script in a tenancy.

**Access to audit retention requires the user to be part of the Administrator group* - the only recommendation affected is CIS recommendation 3.1.

```
Allow group Auditor-Group to inspect all-resources in tenancy
Allow group Auditor-Group to read buckets in tenancy
Allow group Auditor-Group to read file-family in tenancy
Allow group Auditor-Group to read network-security-groups in tenancy
Allow group Auditor-Group to read users in tenancy
Allow group Auditor-Group to use cloud-shell in tenancy
Allow group Auditor-Group to read dynamic-groups in tenancy
Allow group Auditor-Group to read tag-defaults in tenancy
```

### Setup the script to run on a local machine
1. [Setup and Prerequisites](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/sdkconfig.htm)
1. Ensure your OCI `config` file is in the `~/.oci/` directory
1. Download cis_reports.py: [https://raw.githubusercontent.com/oracle-quickstart/oci-cis-landingzone-quickstart/main/scripts/cis_reports.py](https://raw.githubusercontent.com/oracle-quickstart/oci-cis-landingzone-quickstart/main/scripts/cis_reports.py)
```
wget https://raw.githubusercontent.com/oracle-quickstart/oci-cis-landingzone-quickstart/main/scripts/cis_reports.py
```
4. Install OCI
```
python3 -m venv python-venv
source python-venv/bin/activate
pip3 install oci
pip3 install pytz
```

### Setup the script to run in a Cloud Shell Environment
1. Download cis_reports.py: [https://raw.githubusercontent.com/oracle-quickstart/oci-cis-landingzone-quickstart/main/scripts/cis_reports.py](https://raw.githubusercontent.com/oracle-quickstart/oci-cis-landingzone-quickstart/main/scripts/cis_reports.py)
```
wget https://raw.githubusercontent.com/oracle-quickstart/oci-cis-landingzone-quickstart/main/scripts/cis_reports.py
```
All required python libraries are already available in the Cloud shell environment.


## <a name="output">Output
The script loops through all regions used by the tenancy and all resource types referenced in the CIS OCI Foundations Benchmark and outputs a summary compliance report. Each report row corresponds to a recommendation in the OCI Foundations Benchmark and identifies if the tenancy is in compliance as well as the number of offending findings. The report summary columns read as:

- **Num**: the recommendation number in the CIS Benchmark document.
- **Level**: the recommendation level. Level 1 recommendations are less restrictive than Level 2.
- **Compliant**: whether the tenancy is in compliance with the recommendation.
- **Findings**: the number of offending findings for the recommendation.
- **Title**: the recommendation description.

In the sample output below, we see the tenancy is not compliant with several recommendations. Among those is item 1.7 where the output shows 33 users do not have MFA enabled for accessing OCI Console.

```
##########################################################################################
#                      CIS Foundations Benchmark 1.2 Summary Report                      #
##########################################################################################
Num     Level   Compliant       Findings        Title
##########################################################################################
1.1     1       Yes                             Ensure service level admins are created to manage resources of particular service
1.2     1       Yes                             Ensure permissions on all resources are given only to the tenancy administrator group
1.3     1       Yes                             Ensure IAM administrators cannot update tenancy Administrators group
1.4     1       Yes                             Ensure IAM password policy requires minimum length of 14 or greater
1.5     1       Yes                             Ensure IAM password policy expires passwords within 365 days
1.6     1       Yes                             Ensure IAM password policy prevents password reuse
1.7     1       No              29              Ensure MFA is enabled for all users with a console password
1.8     1       No              40              Ensure user API keys rotate within 90 days or less
1.9     1       No              4               Ensure user customer secret keys rotate within 90 days or less
1.10    1       No              9               Ensure user auth tokens rotate within 90 days or less
1.11    1       No              1               Ensure API keys are not created for tenancy administrator users
1.12    1       No              29              Ensure all OCI IAM user accounts have a valid and current email address
1.13    1       Yes                             Ensure Dynamic Groups are used for OCI instances, OCI Cloud Databases and OCI Function to access OCI resources
1.14    2       No                              Ensure storage service-level admins cannot delete resources they manage
2.1     1       No              42              Ensure no security lists allow ingress from 0.0.0.0/0 to port 22
2.2     1       No              6               Ensure no security lists allow ingress from 0.0.0.0/0 to port 3389
2.3     1       No              3               Ensure no network security groups allow ingress from 0.0.0.0/0 to port 22
2.4     1       No              2               Ensure no network security groups allow ingress from 0.0.0.0/0 to port 3389
2.5     1       No              101             Ensure the default security list of every VCN restricts all traffic except ICMP
2.6     1       No              5               Ensure Oracle Integration Cloud (OIC) access is restricted to allowed sources
2.7     1       Yes                             Ensure Oracle Analytics Cloud (OAC) access is restricted to allowed sources or deployed within a Virtual Cloud Network
2.8     1       No              8               Ensure Oracle Autonomous Shared Database (ADB) access is restricted or deployed within a VCN
3.1     1       Yes                             Ensure audit log retention period is set to 365 days
3.2     1       Yes                             Ensure default tags are used on resources
3.3     1       Yes                             Create at least one notification topic and subscription to receive monitoring alerts
3.4     1       Yes                             Ensure a notification is configured for Identity Provider changes
3.5     1       Yes                             Ensure a notification is configured for IdP group mapping changes
3.6     1       Yes                             Ensure a notification is configured for IAM group changes
3.7     1       Yes                             Ensure a notification is configured for IAM policy changes
3.8     1       Yes                             Ensure a notification is configured for user changes
3.9     1       Yes                             Ensure a notification is configured for VCN changes
3.10    1       Yes                             Ensure a notification is configured for  changes to route tables
3.11    1       Yes                             Ensure a notification is configured for  security list changes
3.12    1       Yes                             Ensure a notification is configured for  network security group changes
3.13    1       Yes                             Ensure a notification is configured for  changes to network gateways
3.14    2       No              98              Ensure VCN flow logging is enabled for all subnets
3.15    1       Yes                             Ensure Cloud Guard is enabled in the root compartment of the tenancy
3.16    1       No              8               Ensure customer created Customer Managed Key (CMK) is rotated at least annually
3.17    2       No              250             Ensure write level Object Storage logging is enabled for all buckets
4.1.1   1       No              8               Ensure no Object Storage buckets are publicly visible
4.1.2   2       No              250             Ensure Object Storage Buckets are encrypted with a Customer Managed Key (CMK)
4.1.3   2       No              255             Ensure Versioning is Enabled for Object Storage Buckets
4.2.1   2       No              2               Ensure Block Volumes are encrypted with Customer Managed Keys
4.2.2   2       No              64              Ensure Boot Volumes are encrypted with Customer Managed Key
4.3.1   2       No              6               Ensure File Storage Systems are encrypted with Customer Managed Keys
5.1     1       Yes                             Create at least one compartment in your tenancy to store cloud resources
5.2     1       No              206             Ensure no resources are created in the root compartment
```
For each non-compliant report item, a file with findings details is generated, as shown in the last part of the output:
```
##########################################################################################
#                                 Writing reports to CSV                                 #
##########################################################################################
CSV: summary_report         --> <tenancy-name>-2022-07-06_12-15/cis_summary_report.csv
CSV: Identity and Access Management_1.7 --> <tenancy-name>-2022-07-06_12-15/cis_Identity_and_Access_Management_1-7.csv
CSV: Identity and Access Management_1.8 --> <tenancy-name>-2022-07-06_12-15/cis_Identity_and_Access_Management_1-8.csv
CSV: Identity and Access Management_1.9 --> <tenancy-name>-2022-07-06_12-15/cis_Identity_and_Access_Management_1-9.csv
CSV: Identity and Access Management_1.10 --> <tenancy-name>-2022-07-06_12-15/cis_Identity_and_Access_Management_1-10.csv
CSV: Identity and Access Management_1.11 --> <tenancy-name>-2022-07-06_12-15/cis_Identity_and_Access_Management_1-11.csv
CSV: Identity and Access Management_1.12 --> <tenancy-name>-2022-07-06_12-15/cis_Identity_and_Access_Management_1-12.csv
CSV: Networking_2.1         --> <tenancy-name>-2022-07-06_12-15/cis_Networking_2-1.csv
CSV: Networking_2.2         --> <tenancy-name>-2022-07-06_12-15/cis_Networking_2-2.csv
CSV: Networking_2.3         --> <tenancy-name>-2022-07-06_12-15/cis_Networking_2-3.csv
CSV: Networking_2.4         --> <tenancy-name>-2022-07-06_12-15/cis_Networking_2-4.csv
CSV: Networking_2.5         --> <tenancy-name>-2022-07-06_12-15/cis_Networking_2-5.csv
CSV: Networking_2.6         --> <tenancy-name>-2022-07-06_12-15/cis_Networking_2-6.csv
CSV: Networking_2.8         --> <tenancy-name>-2022-07-06_12-15/cis_Networking_2-8.csv
CSV: Logging and Monitoring_3.14 --> <tenancy-name>-2022-07-06_12-15/cis_Logging_and_Monitoring_3-14.csv
CSV: Logging and Monitoring_3.16 --> <tenancy-name>-2022-07-06_12-15/cis_Logging_and_Monitoring_3-16.csv
CSV: Logging and Monitoring_3.17 --> <tenancy-name>-2022-07-06_12-15/cis_Logging_and_Monitoring_3-17.csv
CSV: Storage - Object Storage_4.1.1 --> <tenancy-name>-2022-07-06_12-15/cis_Storage_Object_Storage_4-1-1.csv
CSV: Storage - Object Storage_4.1.2 --> <tenancy-name>-2022-07-06_12-15/cis_Storage_Object_Storage_4-1-2.csv
CSV: Storage - Object Storage_4.1.3 --> <tenancy-name>-2022-07-06_12-15/cis_Storage_Object_Storage_4-1-3.csv
CSV: Storage - Block Volumes_4.2.1 --> <tenancy-name>-2022-07-06_12-15/cis_Storage_Block_Volumes_4-2-1.csv
CSV: Storage - Block Volumes_4.2.2 --> <tenancy-name>-2022-07-06_12-15/cis_Storage_Block_Volumes_4-2-2.csv
CSV: Storage - File Storage Service_4.3.1 --> <tenancy-name>-2022-07-06_12-15/cis_Storage_File_Storage_Service_4-3-1.csv
CSV: Asset Management_5.2   --> <tenancy-name>-2022-07-06_12-15/cis_Asset_Management_5-2.csv
```
Back to our example, by looking at *cis_Identity and Access Management_1.7.csv* file, the output shows the 33 users who do not have MFA enabled for accessing OCI Console. The script only identifies compliance gaps. It does not remediate the findings. Administrator action is required to address this compliance gap.

#### **Output Non-compliant Findings Only**

Using --print-to-screen ```False``` will only print non-compliant findings to the screen. 

In the sample output below:

```
##########################################################################################
#                      CIS Foundations Benchmark 1.2 Summary Report                      #
##########################################################################################
Num     Level   Compliant       Findings        Title
##########################################################################################
1.7     1       No              33              Ensure MFA is enabled for all users with a console password
1.8     1       No              46              Ensure user API keys rotate within 90 days or less
1.9     1       No              4               Ensure user customer secret keys rotate within 90 days or less
1.10    1       No              10              Ensure user auth tokens rotate within 90 days or less
1.11    1       No              2               Ensure API keys are not created for tenancy administrator users
1.12    1       No              33              Ensure all OCI IAM user accounts have a valid and current email address
1.14    2       No                              Ensure storage service-level admins cannot delete resources they manage
2.1     1       No              23              Ensure no security lists allow ingress from 0.0.0.0/0 to port 22
2.2     1       No              3               Ensure no security lists allow ingress from 0.0.0.0/0 to port 3389
2.3     1       No              2               Ensure no network security groups allow ingress from 0.0.0.0/0 to port 22
2.4     1       No              2               Ensure no network security groups allow ingress from 0.0.0.0/0 to port 3389
2.5     1       No              55              Ensure the default security list of every VCN restricts all traffic except ICMP
2.6     1       No              3               Ensure Oracle Integration Cloud (OIC) access is restricted to allowed sources
2.8     1       No              5               Ensure Oracle Autonomous Shared Database (ADB) access is restricted or deployed within a VCN
3.14    2       No              54              Ensure VCN flow logging is enabled for all subnets
3.16    1       No              5               Ensure customer created Customer Managed Key (CMK) is rotated at least annually
3.17    2       No              239             Ensure write level Object Storage logging is enabled for all buckets
4.1.1   1       No              10              Ensure no Object Storage buckets are publicly visible
4.1.2   2       No              239             Ensure Object Storage Buckets are encrypted with a Customer Managed Key (CMK)
4.1.3   2       No              244             Ensure Versioning is Enabled for Object Storage Buckets
4.2.1   2       No              1               Ensure Block Volumes are encrypted with Customer Managed Keys
4.2.2   2       No              46              Ensure boot volumes are encrypted with Customer Managed Key
4.3.1   2       No              6               Ensure File Storage Systems are encrypted with Customer Managed Keys
5.2     1       No              204             Ensure no resources are created in the root compartment
```

#### **Output Level 1 Findings Only**

Using --level ```1``` will only print Level 1 findings. 

In the sample output below:
```
##########################################################################################
#                      CIS Foundations Benchmark 1.2 Summary Report                      #
##########################################################################################
Num     Level   Compliant       Findings        Title
##########################################################################################
1.1     1       Yes                             Ensure service level admins are created to manage resources of particular service
1.2     1       Yes                             Ensure permissions on all resources are given only to the tenancy administrator group
1.3     1       Yes                             Ensure IAM administrators cannot update tenancy Administrators group
1.4     1       Yes                             Ensure IAM password policy requires minimum length of 14 or greater
1.5     1       Yes                             Ensure IAM password policy expires passwords within 365 days
1.6     1       Yes                             Ensure IAM password policy prevents password reuse
1.7     1       No              33              Ensure MFA is enabled for all users with a console password
1.8     1       No              46              Ensure user API keys rotate within 90 days or less
1.9     1       No              4               Ensure user customer secret keys rotate within 90 days or less
1.10    1       No              10              Ensure user auth tokens rotate within 90 days or less
1.11    1       No              2               Ensure API keys are not created for tenancy administrator users
1.12    1       No              33              Ensure all OCI IAM user accounts have a valid and current email address
1.13    1       Yes                             Ensure Dynamic Groups are used for OCI instances, OCI Cloud Databases and OCI Function to access OCI resources
2.1     1       No              23              Ensure no security lists allow ingress from 0.0.0.0/0 to port 22
2.2     1       No              3               Ensure no security lists allow ingress from 0.0.0.0/0 to port 3389
2.3     1       No              2               Ensure no network security groups allow ingress from 0.0.0.0/0 to port 22
2.4     1       No              2               Ensure no network security groups allow ingress from 0.0.0.0/0 to port 3389
2.5     1       No              55              Ensure the default security list of every VCN restricts all traffic except ICMP
2.6     1       No              3               Ensure Oracle Integration Cloud (OIC) access is restricted to allowed sources
2.7     1       Yes                             Ensure Oracle Analytics Cloud (OAC) access is restricted to allowed sources or deployed within a Virtual Cloud Network
2.8     1       No              5               Ensure Oracle Autonomous Shared Database (ADB) access is restricted or deployed within a VCN
3.1     1       Yes                             Ensure audit log retention period is set to 365 days
3.2     1       Yes                             Ensure default tags are used on resources
3.3     1       Yes                             Create at least one notification topic and subscription to receive monitoring alerts
3.4     1       Yes                             Ensure a notification is configured for Identity Provider changes
3.5     1       Yes                             Ensure a notification is configured for IdP group mapping changes
3.6     1       Yes                             Ensure a notification is configured for IAM group changes
3.7     1       Yes                             Ensure a notification is configured for IAM policy changes
3.8     1       Yes                             Ensure a notification is configured for user changes
3.9     1       Yes                             Ensure a notification is configured for VCN changes
3.10    1       Yes                             Ensure a notification is configured for  changes to route tables
3.11    1       Yes                             Ensure a notification is configured for  security list changes
3.12    1       Yes                             Ensure a notification is configured for  network security group changes
3.13    1       Yes                             Ensure a notification is configured for  changes to network gateways
3.15    1       Yes                             Ensure Cloud Guard is enabled in the root compartment of the tenancy
3.16    1       No              5               Ensure customer created Customer Managed Key (CMK) is rotated at least annually
4.1.1   1       No              10              Ensure no Object Storage buckets are publicly visible
5.1     1       Yes                             Create at least one compartment in your tenancy to store cloud resources
5.2     1       No              204             Ensure no resources are created in the root compartment
```

#### **Output OCI Best Practice Summary Report**
Using `--obp` will check for a tenancy's alignment to the available OCI Best Practices. 

```
##########################################################################################
#                              OCI Best Practices Findings                               #
##########################################################################################
Category				Compliant	Findings
##########################################################################################
Cost_Tracking_Budgets    		True		1
SIEM_Audit_Log_All_Comps 		True		0
SIEM_Audit_Incl_Sub_Comp 		True		0
SIEM_VCN_Flow_Logging    		False		511
SIEM_Write_Bucket_Logs   		False		180
SIEM_Read_Bucket_Logs    		False		161
Networking_Connectivity  		False		17
Cloud_Guard_Config       		False		1
```


## <a name="usage">Usage

### Arguments
```
% python3 cis_reports.py -h       
usage: cis_reports.py [-h] [-c FILE_LOCATION] [-t CONFIG_PROFILE] [-p PROXY] [--output-to-bucket OUTPUT_BUCKET]
                      [--report-directory REPORT_DIRECTORY] [--print-to-screen PRINT_TO_SCREEN] [--level LEVEL]
                      [--regions REGIONS] [--raw] [--obp] [--redact_output] [-ip] [-dt] [-st] [-v]

options:
  -h, --help            show this help message and exit
  -c FILE_LOCATION      OCI config file location
  -t CONFIG_PROFILE     Config file section to use (tenancy profile)
  -p PROXY              Set Proxy (i.e. www-proxy-server.com:80)
  --output-to-bucket OUTPUT_BUCKET
                        Set Output bucket name (i.e. my-reporting-bucket)
  --report-directory REPORT_DIRECTORY
                        Set Output report directory by default it is the current date (i.e. reports-date)
  --print-to-screen PRINT_TO_SCREEN
                        Set to False if you want to see only non-compliant findings (i.e. False)
  --level LEVEL         CIS Recommendation Level options are: 1 or 2. Set to 2 by default
  --regions REGIONS     Regions to run the compliance checks on, by default it will run in all regions. Sample input: us-
                        ashburn-1,ca-toronto-1,eu-frankfurt-1
  --raw                 Outputs all resource data into CSV files
  --obp                 Checks for OCI best practices
  --redact_output       Redacts OCIDs in output CSV files
  -ip                   Use Instance Principals for Authentication
  -dt                   Use Delegation Token for Authentication in Cloud Shell
  -st                   Authenticate using Security Token
  -v                    Show the version of the script and exit.
% 
```

### Usage Examples

#### Executing in Cloud Shell to check CIS and OCI Best Practices with raw data
To run using Cloud Shell in all regions and check for OCI Best Practices with raw data of all resources output to CSV files.
```
% python3 cis_reports.py -dt --obp --raw

``` 

#### Executing on local machine with a specific OCI Config file

To run on a local machine using a specific OCI Config file.
```
% python3 cis_reports.py -c <file_location>
```
where ```<file_location>``` is the fully qualified path to an OCI client config file (default location is `~/.oci/config`). An OCI config file contains profiles that define the connecting parameters to your tenancy, like tenancy id, region, user id, fingerprint and key file. For more information: [https://docs.oracle.com/en-us/iaas/Content/API/Concepts/sdkconfig.htm#SDK_and_CLI_Configuration_File](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/sdkconfig.htm#SDK_and_CLI_Configuration_File).


	[<Profile_Name>]
	tenancy=<tenancy_ocid>
	region=us-ashburn-1
	user=<user_ocid>
	fingerprint=<api_key_finger_print>
	key_file=/path_to_my_private_key_file.pem


#### Executing on local machine with a specific profile

To run on a local machine using a specific profile in the an OCI Config file.
```
% python3 cis_reports.py -t <Profile_Name>
```

where ```<Profile_Name>``` is the profile name in OCI client config file (typically located under $HOME/.oci). A profile defines the connecting parameters to your tenancy, like tenancy id, region, user id, fingerprint and key file.

	[<Profile_Name>]
	tenancy=<tenancy_ocid>
	region=us-ashburn-1
	user=<user_ocid>
	fingerprint=<api_key_finger_print>
	key_file=/path_to_my_private_key_file.pem

#### Executing on a local machine via Security Token (oci session authenticate)

To run on a local machine using a Security Token without OCI Config file. For more information: [https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/clitoken.htm](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/clitoken.htm)

Execute the oci command.
```
% oci session authenticate
```
This command will prompt for Region details, provide region name ex: us-ashburn-1.
Browser will open the OCI console window and asks for user credentials. Once after providing the credentials get back to the command prompt. This will create config file using the provided credentials in the "/Users/***/.oci/sessions/config.

Execute the python script.
```
% python3 cis_reports.py -st
```

#### Executing using Cloud Shell
To run in Cloud Shell with delegated token authentication.
```
% python3 cis_reports.py -dt'
``` 

#### Executing on local machine with using instance principal
To run on an OCI instance that associated with Instance Principal. 
```
% python3 cis_reports.py -ip'
``` 

#### Executing using Cloud Shell in only two regions
To run on using Cloud Shell in on us-ashburn-1 and us-phoenix-1. IAM checks will performed in the tenancy's Home Region.
```
% python3 cis_reports.py -dt --region us-ashburn-1,us-phoenix-1'
``` 

#### Executing using output to an bucket
To write the output files to an Object Storage bucket.
 ```
% python3 cis_reports.py --output-to-bucket 'my-example-bucket-1'
``` 
Using --output-to-bucket ```<bucket-name>``` the reports will be copied to the Object Storage bucket in a folder(default location) with the region, tenancy name, and current day's date ex. ```us-ashburn-1-<tenancy_name>-2020-12-08```.  The bucket must already exist and the user executing the script must have permissions to use the bucket. If using the --report-directory flag as well the folder must already exist in the bucket.

#### Executing using report directory
To write the output files to an specified directory.
 ```
% python3 cis_reports.py --report-directory 'my-directory'
``` 
Using --report-directory ```<directory-name>``` the reports will be copied to the specified directory. The directory must already exist.

#### Executing using report directory and output to a bucket
To write the output files to an specified directory in an object storage bucket.
 ```
% python3 cis_reports.py --report-directory 'bucket-directory' --output-to-bucket 'my-example-bucket-1'
``` 
Using --report-directory ```<directory-name>``` and --output-to-bucket ```<bucket-name>``` together the reports will be copied to the specified directory in the specified bucket. The bucket must already exist in the **Tenancy's Home Region** and user must have permissions to write to that bucket.

#### Executing using report directory and output to a bucket
To write the output files to an specified directory in an object storage bucket.
 ```
% python3 cis_reports.py --report-directory 'bucket-directory' --output-to-bucket 'my-example-bucket-1'
``` 
Using --report-directory ```<directory-name>``` and --output-to-bucket ```<bucket-name>``` together the reports will be copied to the specified directory in the specified bucket. The bucket must already exist in the **Tenancy's Home Region** and user must have permissions to write to that bucket.

#### Executing on local machine and output raw data
To run on a local machine with the default profile and output raw data as well as the reports.
```
% python3 cis_reports.py --raw
``` 

## <a name="faq"></a>FAQ

1. Why did the script may fail to run when executing from the local machine with message "** OCI_CONFIG_FILE and OCI_CONFIG_PROFILE env variables not found, abort. ***"?
    * In this case, make sure to set OCI_CONFIG_HOME to the full path of .oci/config file. Optionally, OCI_CONFIG_PROFILE can be configured with a default profile to use from config.
