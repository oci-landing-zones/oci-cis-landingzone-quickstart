## Compliance Checking Script
### Overview
The Compliance Checking script checks a tenancy's configuration against the CIS OCI Foundations Benchmark. 

The script is located under the *scripts* folder in this repository. It outputs a summmary report CSV as well individual CSV findings report for configuration issues that are discovered in a folder(default location) with current day's date ex. ```2020-12-08```. 

Using --output-to-bucket ```<bucket-name>``` the reports will be copied to the Object Storage bucket in a folder(default location) with current day's date ex. ```2020-12-08```.

Using --report-directory ```<directory-name>``` the reports will be copied to the specified directory. If used with --output-to-bucket the reports will be copied to the Object Storage bucket in a folder specified  in --report-directory ```<directory-name>```.

### Usage 

#### Executing on local machine

1. [Setup and Prerequisites](https://docs.cloud.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#Required_Keys_and_OCIDs) 

2. Download cis_reports.py: [https://raw.githubusercontent.com/oracle-quickstart/oci-cis-landingzone-quickstart/main/scripts/cis_reports.py](https://raw.githubusercontent.com/oracle-quickstart/oci-cis-landingzone-quickstart/main/scripts/cis_reports.py)

3. Run
```
pip3 install oci
python3 cis_reports.py --output-to-bucket 'my-example-bucket-1' -t <Profile_Name>
```
where ```<Profile_Name>``` is the profile name in OCI client config file (typically located under $HOME/.oci). A profile defines the connecting parameters to your tenancy, like tenancy id, region, user id, fingerprint and key file.

	[the_profile_name]
	tenancy=<tenancy_ocid>
	region=us-ashburn-1
	user=<user_ocid>
	fingerprint=<api_key_finger_print>
	key_file=/path_to_my_private_key_file.pem

#### Executing using Cloud Shell:
1. Install setup venv and install OCI
```
python3 -m venv python-venv
source python_venv/bin/activate
pip3 install oci
```
2. Run
```
wget https://raw.githubusercontent.com/oracle-quickstart/oci-cis-landingzone-quickstart/main/scripts/cis_reports.py
```
3. Run
```
python3 cis_reports.py -dt --output-to-bucket 'my-example-bucket-1'
``` 
### Script Output
The script loops through all resource types referenced in the CIS OCI Foundations Benchmark and outputs a summary compliance report. Each report row corresponds to a recommendation in the OCI Foundations Benchmark and identifies if the tenancy is in compliance as well as the number of offending findings. The report summary columns read as:

- **Num**: the recommendation number in the CIS Benchmark document.
- **Level**: the recommendation level. Level 1 recommendations are less restrictive than Level 2.
- **Compliant**: whether the tenancy is in compliance with the recommendation.
- **Findings**: the number of offending findings for the recommendation.
- **Title**: the recommendation description.

In the sample output below, we see the tenancy is not compliant with several recommendations. Among those is item 1.7 where the output shows 12 users do not have MFA enabled for accessing OCI Console.

```
##########################################################################################
#                      CIS Foundations Benchmark 1.1 Summary Report                      #
##########################################################################################
Num     Level   Compliant       Findings        Title
##########################################################################################
1.1     1       No              2               Ensure service level admins are created to manage resources of particular service
1.2     1       Yes             0               Ensure permissions on all resources are given only to the tenancy administrator group
1.3     1       No              5               Ensure IAM administrators cannot update tenancy Administrators group
1.4     1       Yes             0               Ensure IAM password policy requires minimum length of 14 or greater
1.5     1       Yes             0               Ensure IAM password policy expires passwords within 365 days
1.6     1       Yes             0               Ensure IAM password policy prevents password reuse
1.7     1       No              12              Ensure MFA is enabled for all users with a console password
1.8     1       No              14              Ensure user API keys rotate within 90 days or less
1.9     1       No              4               Ensure user customer secret keys rotate within 90 days or less
1.10    1       No              3               Ensure user auth tokens rotate within 90 days or less
1.11    1       No              2               Ensure API keys are not created for tenancy administrator users
1.12    1       No              11              Ensure all OCI IAM user accounts have a valid and current email address
2.1     1       No              22              Ensure no security lists allow ingress from 0.0.0.0/0 to port 22
2.2     1       No              1               Ensure no security lists allow ingress from 0.0.0.0/0 to port 3389
2.3     1       No              2               Ensure no network security groups allow ingress from 0.0.0.0/0 to port 22
2.4     1       No              2               Ensure no network security groups allow ingress from 0.0.0.0/0 to port 3389
2.5     1       No              44              Ensure the default security list of every VCN restricts all traffic except ICMP
3.1     1       Yes             0               Ensure audit log retention period is set to 365 days
3.2     1       Yes             0               Ensure default tags are used on resources
3.3     1       Yes             0               Create at least one notification topic and subscription to receive monitoring alerts
3.4     1       Yes             0               Ensure a notification is configured for Identity Provider changes
3.5     1       Yes             0               Ensure a notification is configured for IdP group mapping changes
3.6     1       Yes             0               Ensure a notification is configured for IAM group changes
3.7     1       Yes             0               Ensure a notification is configured for IAM policy changes
3.8     1       Yes             0               Ensure a notification is configured for user changes
3.9     1       Yes             0               Ensure a notification is configured for VCN changes
3.10    1       Yes             0               Ensure a notification is configured for  changes to route tables
3.11    1       Yes             0               Ensure a notification is configured for  security list changes
3.12    1       Yes             0               Ensure a notification is configured for  network security group changes
3.13    1       Yes             0               Ensure a notification is configured for  changes to network gateways
3.14    2       No              52              Ensure VCN flow logging is enabled for all subnets
3.15    1       Yes             0               Ensure Cloud Guard is enabled in the root compartment of the tenancy
3.16    1       Yes             0               Ensure customer created Customer Managed Key (CMK) is rotated at least annually
3.17    2       No              204             Ensure write level Object Storage logging is enabled for all buckets
4.1     1       No              1               Ensure no Object Storage buckets are publicly visible
4.2     2       No              201             Ensure Object Storage Buckets are encrypted with a Customer Managed Key (CMK)
5.1     1       Yes             0               Create at least one compartment in your tenancy to store cloud resources
5.2     1       No              184             Ensure no resources are created in the root compartment
```
For each non-compliant report item, a file with findings details is generated, as shown in the last part of the output:
```
##########################################################################################
#                                 Writing reports to CSV                                 #
##########################################################################################
CSV: summary_report         --> cis_summary_report.csv
CSV: Identity and Access Management_1.1 --> cis_Identity and Access Management_1.1.csv
CSV: Identity and Access Management_1.3 --> cis_Identity and Access Management_1.3.csv
CSV: Identity and Access Management_1.7 --> cis_Identity and Access Management_1.7.csv
CSV: Identity and Access Management_1.8 --> cis_Identity and Access Management_1.8.csv
CSV: Identity and Access Management_1.9 --> cis_Identity and Access Management_1.9.csv
CSV: Identity and Access Management_1.10 --> cis_Identity and Access Management_1.10.csv
CSV: Identity and Access Management_1.11 --> cis_Identity and Access Management_1.11.csv
CSV: Identity and Access Management_1.12 --> cis_Identity and Access Management_1.12.csv
CSV: Networking_2.1         --> cis_Networking_2.1.csv
CSV: Networking_2.2         --> cis_Networking_2.2.csv
CSV: Networking_2.3         --> cis_Networking_2.3.csv
CSV: Networking_2.4         --> cis_Networking_2.4.csv
CSV: Networking_2.5         --> cis_Networking_2.5.csv
CSV: Logging and Monitoring_3.14 --> cis_Logging and Monitoring_3.14.csv
CSV: Logging and Monitoring_3.17 --> cis_Logging and Monitoring_3.17.csv
CSV: Object Storage_4.1     --> cis_Object Storage_4.1.csv
CSV: Object Storage_4.2     --> cis_Object Storage_4.2.csv
```
Back to our example, by looking at *cis_Identity and Access Management_1.7.csv* file, the output shows the 12 users who do not have MFA enabled for accessing OCI Console. The script only identifies compliance gaps. It does not remediate the findings. Administrator action is required to address this compliance gap.

#### **Output Non-compliant Findings Only**

Using --print-to-screen ```False``` will only print non-compliant findings to the screen. 

In the sample output below:

```
##########################################################################################
#                      CIS Foundations Benchmark 1.1 Summary Report                      #
##########################################################################################
Num     Level   Compliant       Findings        Title
##########################################################################################
1.1     1       No              4               Ensure service level admins are created to manage resources of particular service
1.3     1       No              4               Ensure IAM administrators cannot update tenancy Administrators group
1.7     1       No              5               Ensure MFA is enabled for all users with a console password
1.8     1       No              1               Ensure user API keys rotate within 90 days or less
1.11    1       No              1               Ensure API keys are not created for tenancy administrator users
1.12    1       No              5               Ensure all OCI IAM user accounts have a valid and current email address
2.1     1       No              4               Ensure no security lists allow ingress from 0.0.0.0/0 to port 22
2.5     1       No              6               Ensure the default security list of every VCN restricts all traffic except ICMP
3.14    2       No              4               Ensure VCN flow logging is enabled for all subnets
3.17    2       No              7               Ensure write level Object Storage logging is enabled for all buckets
4.1     1       No              2               Ensure no Object Storage buckets are publicly visible
4.2     2       No              3               Ensure Object Storage Buckets are encrypted with a Customer Managed Key (CMK)
5.2     1       No              3               Ensure no resources are created in the root compartment

##########################################################################################
#                                 Writing reports to CSV                                 #
##########################################################################################
CSV: summary_report         --> 2021-02-21/cis_summary_report.csv
CSV: Identity and Access Management_1.1 --> 2021-02-21/cis_Identity and Access Management_1.1.csv
CSV: Identity and Access Management_1.3 --> 2021-02-21/cis_Identity and Access Management_1.3.csv
CSV: Identity and Access Management_1.7 --> 2021-02-21/cis_Identity and Access Management_1.7.csv
CSV: Identity and Access Management_1.8 --> 2021-02-21/cis_Identity and Access Management_1.8.csv
CSV: Identity and Access Management_1.11 --> 2021-02-21/cis_Identity and Access Management_1.11.csv
CSV: Identity and Access Management_1.12 --> 2021-02-21/cis_Identity and Access Management_1.12.csv
CSV: Networking_2.1         --> 2021-02-21/cis_Networking_2.1.csv
CSV: Networking_2.5         --> 2021-02-21/cis_Networking_2.5.csv
CSV: Logging and Monitoring_3.14 --> 2021-02-21/cis_Logging and Monitoring_3.14.csv
CSV: Logging and Monitoring_3.17 --> 2021-02-21/cis_Logging and Monitoring_3.17.csv
CSV: Object Storage_4.1     --> 2021-02-21/cis_Object Storage_4.1.csv
CSV: Object Storage_4.2     --> 2021-02-21/cis_Object Storage_4.2.csv
CSV: Asset Management_5.2   --> 2021-02-21/cis_Asset Management_5.2.csv
```