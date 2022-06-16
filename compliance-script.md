# Compliance Checking Script
1. [Overview](#overview)
1. [Setup](#setup)
1. [Output](#output)
1. [Usage](#usage)
1. [FAQ](#faq)


## <a name="overview"></a>Overview
The Compliance Checking script checks a tenancy's configuration against the CIS OCI Foundations Benchmark. 

The script is located under the *scripts* folder in this repository. It outputs a summary report CSV as well individual CSV findings report for configuration issues that are discovered in a folder(default location) with the region, tenancy name, and current day's date ex. ```us-ashburn-1-<tenancy_name>-2020-12-08```. 

## <a name="setup"></a>Setup 

### Required Permissions
The **Auditors Group** that is created as part of the CIS Landing Zone Terraform has all the permissions required to run the compliance checking in the tenancy.  Below is the minimum OCI IAM Policy to grant a group the script in a tenancy.

**Access to audit retention requires the user to be part of the Administrator group*

```
Allow group Auditor-Group to inspect all-resources in tenancy
Allow group Auditor-Group to read buckets in tenancy
Allow group Auditor-Group to read file-family in tenancy
Allow group Auditor-Group to read network-security-groups in tenancy
Allow group Auditor-Group to read users in tenancy
Allow group Auditor-Group to use cloud-shell in tenancy
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
pip3 install oci
pip3 install pytz
```

### Setup the script to run in a Cloud Shell Environment
1. Download cis_reports.py: [https://raw.githubusercontent.com/oracle-quickstart/oci-cis-landingzone-quickstart/main/scripts/cis_reports.py](https://raw.githubusercontent.com/oracle-quickstart/oci-cis-landingzone-quickstart/main/scripts/cis_reports.py)
```
wget https://raw.githubusercontent.com/oracle-quickstart/oci-cis-landingzone-quickstart/main/scripts/cis_reports.py
```
2. Install setup venv and install OCI
```
python3 -m venv python-venv
source python_venv/bin/activate
pip3 install oci
pip3 install pytz
```


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
1.7     1       No              33              Ensure MFA is enabled for all users with a console password
1.8     1       No              46              Ensure user API keys rotate within 90 days or less
1.9     1       No              4               Ensure user customer secret keys rotate within 90 days or less
1.10    1       No              10              Ensure user auth tokens rotate within 90 days or less
1.11    1       No              2               Ensure API keys are not created for tenancy administrator users
1.12    1       No              33              Ensure all OCI IAM user accounts have a valid and current email address
1.13    1       Yes                             Ensure Dynamic Groups are used for OCI instances, OCI Cloud Databases and OCI Function to access OCI resources
1.14    2       No                              Ensure storage service-level admins cannot delete resources they manage
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
3.14    2       No              54              Ensure VCN flow logging is enabled for all subnets
3.15    1       Yes                             Ensure Cloud Guard is enabled in the root compartment of the tenancy
3.16    1       No              5               Ensure customer created Customer Managed Key (CMK) is rotated at least annually
3.17    2       No              239             Ensure write level Object Storage logging is enabled for all buckets
4.1.1   1       No              10              Ensure no Object Storage buckets are publicly visible
4.1.2   2       No              239             Ensure Object Storage Buckets are encrypted with a Customer Managed Key (CMK)
4.1.3   2       No              244             Ensure Versioning is Enabled for Object Storage Buckets
4.2.1   2       No              1               Ensure Block Volumes are encrypted with Customer Managed Keys
4.2.2   2       No              46              Ensure boot volumes are encrypted with Customer Managed Key
4.3.1   2       No              6               Ensure File Storage Systems are encrypted with Customer Managed Keys
5.1     1       Yes                             Create at least one compartment in your tenancy to store cloud resources
5.2     1       No              204             Ensure no resources are created in the root compartment
```
For each non-compliant report item, a file with findings details is generated, as shown in the last part of the output:
```
##########################################################################################
#                                 Writing reports to CSV                                 #
##########################################################################################
CSV: summary_report         --> us-ashburn-1-<tenancy_name>-2022-06-02/cis_summary_report.csv
CSV: Identity and Access Management_1.7 --> us-ashburn-1-<tenancy_name>-2022-06-02/cis_Identity_and_Access_Management_1-7.csv
CSV: Identity and Access Management_1.8 --> us-ashburn-1-<tenancy_name>-2022-06-02/cis_Identity_and_Access_Management_1-8.csv
CSV: Identity and Access Management_1.9 --> us-ashburn-1-<tenancy_name>-2022-06-02/cis_Identity_and_Access_Management_1-9.csv
CSV: Identity and Access Management_1.10 --> us-ashburn-1-<tenancy_name>-2022-06-02/cis_Identity_and_Access_Management_1-10.csv
CSV: Identity and Access Management_1.11 --> us-ashburn-1-<tenancy_name>-2022-06-02/cis_Identity_and_Access_Management_1-11.csv
CSV: Identity and Access Management_1.12 --> us-ashburn-1-<tenancy_name>-2022-06-02/cis_Identity_and_Access_Management_1-12.csv
CSV: Networking_2.1         --> us-ashburn-1-<tenancy_name>-2022-06-02/cis_Networking_2-1.csv
CSV: Networking_2.2         --> us-ashburn-1-<tenancy_name>-2022-06-02/cis_Networking_2-2.csv
CSV: Networking_2.3         --> us-ashburn-1-<tenancy_name>-2022-06-02/cis_Networking_2-3.csv
CSV: Networking_2.4         --> us-ashburn-1-<tenancy_name>-2022-06-02/cis_Networking_2-4.csv
CSV: Networking_2.5         --> us-ashburn-1-<tenancy_name>-2022-06-02/cis_Networking_2-5.csv
CSV: Networking_2.6         --> us-ashburn-1-<tenancy_name>-2022-06-02/cis_Networking_2-6.csv
CSV: Networking_2.8         --> us-ashburn-1-<tenancy_name>-2022-06-02/cis_Networking_2-8.csv
CSV: Logging and Monitoring_3.14 --> us-ashburn-1-<tenancy_name>-2022-06-02/cis_Logging_and_Monitoring_3-14.csv
CSV: Logging and Monitoring_3.16 --> us-ashburn-1-<tenancy_name>-2022-06-02/cis_Logging_and_Monitoring_3-16.csv
CSV: Logging and Monitoring_3.17 --> us-ashburn-1-<tenancy_name>-2022-06-02/cis_Logging_and_Monitoring_3-17.csv
CSV: Storage: Object Storage_4.1.1 --> us-ashburn-1-<tenancy_name>-2022-06-02/cis_Storage:_Object_Storage_4-1-1.csv
CSV: Storage: Object Storage_4.1.2 --> us-ashburn-1-<tenancy_name>-2022-06-02/cis_Storage:_Object_Storage_4-1-2.csv
CSV: Storage: Object Storage_4.1.3 --> us-ashburn-1-<tenancy_name>-2022-06-02/cis_Storage:_Object_Storage_4-1-3.csv
CSV: Storage: Block Volumes_4.2.1 --> us-ashburn-1-<tenancy_name>-2022-06-02/cis_Storage:_Block_Volumes_4-2-1.csv
CSV: Storage: Block Volumes_4.2.2 --> us-ashburn-1-<tenancy_name>-2022-06-02/cis_Storage:_Block_Volumes_4-2-2.csv
CSV: Storage: File Storage Service_4.3.1 --> us-ashburn-1-<tenancy_name>-2022-06-02/cis_Storage:_File_Storage_Service_4-3-1.csv
CSV: Asset Management_5.2   --> us-ashburn-1-<tenancy_name>-2022-06-02/cis_Asset_Management_5-2.csv
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


## <a name="usage">Usage

### Arguments
```
% python3 cis_reports.py -h       
usage: cis_reports.py [-h] [-t CONFIG_PROFILE] [-p PROXY] [--output-to-bucket OUTPUT_BUCKET] [--report-directory REPORT_DIRECTORY] [--print-to-screen PRINT_TO_SCREEN] [--level LEVEL] [-ip] [-dt]

optional arguments:
  -h, --help            show this help message and exit
  -t CONFIG_PROFILE     Config file section to use (tenancy profile)
  -p PROXY              Set Proxy (i.e. www-proxy-server.com:80)
  --output-to-bucket OUTPUT_BUCKET
                        Set Output bucket name (i.e. my-reporting-bucket)
  --report-directory REPORT_DIRECTORY
                        Set Output report directory by default it is the current date (i.e. reports-date)
  --print-to-screen PRINT_TO_SCREEN
                        Set to False if you want to see only non-compliant findings (i.e. False)
  --level LEVEL         CIS Recommendation Level options are: 1 or 2. Set to 2 by default
  -ip                   Use Instance Principals for Authentication
  -dt                   Use Delegation Token for Authentication in Cloud Shell
% 
```

### Usage Examples
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
Using --report-directory ```<directory-name>``` and --output-to-bucket ```<bucket-name>``` together the reports will be copied to the specified directory in the specified bucket. The bucket must already exist, the specified directory must exist in the bucket, and inside the specified directory there must be a folder for each region ex. ````<directory-name>\us-ashburn-1```.

## <a name="faq"></a>FAQ

1. Why did the script may fail to run when executing from the local machine with message "** OCI_CONFIG_FILE and OCI_CONFIG_PROFILE env variables not found, abort. ***"?
    * In this case, make sure to set OCI_CONFIG_HOME to the full path of .oci/config file. Optionally, OCI_CONFIG_PROFILE can be configured with a default profile to use from config.