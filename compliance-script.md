## Compliance Checking Script
### Overview
The CIS Reports Script checks a tenancy's configuration against the CIS Foundations Benchmark for Oracle Cloud. 

The script is located under the *reports* folder in this repository. It outputs a summmary report CSV as well individual CSV findings report for configuration issues that are discovered.

Using the --output-to-bucket ```<bucket-name>``` the reports will be copied to the Object Storage bucket in a folder with current day's date ex. ```2020-12-08```.

### Usage 

#### Executing on local machine

1. [Setup and Prerequisites](https://docs.cloud.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#Required_Keys_and_OCIDs) 

1. Run
```
python3 cis_reports.py --output-to-bucket 'my-example-bucket-1' -t <Profile_Name>
```
where \<Profile_Name> is the profile name in OCI client config file (typically located under $HOME/.oci). A profile defines the connecting parameters to your tenancy, like tenancy id, region, user id, fingerprint and key file.

	[the_profile_name]
	tenancy=ocid1.tenancy.oc1..aaaaaaaagfqbe4notarealocidreallygzinrxt6h6hfshjokfgfi5nzquxmfpzkyq
	region=us-ashburn-1
	user=ocid1.user.oc1..aaaaaaaaltwx45wllv52qqxk7inotarealocidreallyo76gboofpbzlgmihq
	fingerprint=c8:91:41:8p:65:56:68:02:2e:54:80:kk:36:76:69:39
	key_file=/path_to_my_private_key_file.pem

#### Executing using Cloud Shell:
1. install OCI sdk

```
pip3 install --user oci
```
1. Copy the cis_reports.py to the directory

1. Run
```
python3 cis_reports.py -dt --output-to-bucket 'my-example-bucket-1'
``` 