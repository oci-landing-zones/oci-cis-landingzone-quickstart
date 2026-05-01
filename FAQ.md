# Frequently Asked Questions
## Questions
- [What is the CIS Oracle Cloud Infrastructure Foundations Benchmark?](#cis)
- [What is the CIS Compliance Script?](#script)
- [What is the cost of running the CIS Compliance Script?](#cost)
- [What permissions are needed to run the CIS Compliance Script?](#script-access)
- [How to remediate recommendations relating to Cloud Guard, Events, and Notifications?](./terraform-remediations/cis_oci_benchmark_logging_monitoring_remediation/)
- [Why did the script may fail to run when executing from the local machine with message "** OCI_CONFIG_FILE and OCI_CONFIG_PROFILE env variables not found, abort.**?](#oci_config_profile)
- [ImportError: urllib3 v2 only supports OpenSSL 1.1.1+, currently the 'ssl' module is compiled with 'OpenSSL 1.0.2k-fips  26 Jan 2017'.](#urllib3)
- [Understanding CIS recommendation *Ensure storage service-level admins cannot delete resources they manage.*](#storage-admins)
- [How does the CIS Compliance Script evaluate recommendation *1.14 Ensure Instance Principal authentication is used for OCI instances, OCI Cloud Databases and OCI Functions to access OCI resources*?](#dynamic-group-recommendation-114)
- [Why does the script treat some Events rules as compliant even when the Notifications topic subscription is not active?](#event-rule-target-validation)
- [Why are there no dashboard graphics in the HTML page?](#html-page)
- [Why is the XLSX file not created?](#xlsx)

## Answers

### <a name="cis"></a>**What is the CIS Oracle Cloud Infrastructure Foundations Benchmark?**

Objective, consensus-driven, security guidelines for OCI that have been accepted by the Center for Internet Security (CIS) and the supporting CIS community. Click [here](https://www.cisecurity.org/benchmark/oracle_cloud/) to download a copy.

### <a name="script"></a>**What is the CIS OCI Landing Zone?**

The CIS Compliance Script is a Python script that can run on new or existing tenancies to validate configuration in the tenancy for compliance with the CIS OCI Foundations Benchmark Recommendations.

### <a name="cost"></a>**What is the cost of running the CIS Compliance Script?**

There are no OCI-related costs to run the CIS Compliance Script.

### <a name="script-access"></a>What permissions are needed to run the CIS Compliance Script?**

Review the script Setup section.

To allow the script to write the reports to an output bucket, the following policy must be added to the policy:

`Allow group <Group-Name> to manage objects in compartment <compartment-name> where target.bucket.name='<bucket-name>'`

** The Landing Zones create the Auditor Group and Auditor Policy which provide the required permissions.

### <a name="services"></a>**Which OCI services are checked as part of the CIS Compliance Script?**

The script checks the following services based on different flags:
- No Flags CIS Compliance Checks:
    - Compartments
    - Identity Domains
    - Groups
    - Users
    - Policies
    - Tags
    - Cloud Guard
    - Vaults
    - Keys
    - Buckets
    - Logging Groups
    - Logging
    - Events
    - Notifications
    - Network Security Lists
    - Network Security Groups
    - Virtual Cloud Networks
    - Network Capture Filters
    - Autonomous Database
    - Oracle Integration Cloud
    - Oracle Analytics Cloud
    - Block Volumes
    - Boot Volumes
    - File Storage System
    - Instances
- Oracle Best Practice Flag `--obp`
    - All the above
    - Fast Connect
    - IPSec connections
    - Dynamic Routing Gateways
    - Service Connector 
    - Certificates
- All Resources `--all-resources`
    - Network Topology
    - All Resources and additional attributes from Search Service

### <a name="oci_config_profile"></a>**Why did the script may fail to run when executing from the local machine with message "** OCI_CONFIG_FILE and OCI_CONFIG_PROFILE env variables not found, abort.**"?
- In this case, make sure to set OCI_CONFIG_HOME to the full path of .oci/config file. Optionally, OCI_CONFIG_PROFILE can be configured with a default profile to use from config.
_ Optionally, you can use the `-c` option to specify an alternate config file

### <a name="urllib3"></a> `ImportError: urllib3 v2 only supports OpenSSL 1.1.1+, currently the 'ssl' module is compiled with 'OpenSSL 1.0.2k-fips  26 Jan 2017'.`
- Change your urllib3 with the following `pip install --upgrade 'urllib3<=2' --user`

### <a name="storage-admins"></a>**Understanding CIS recommendation *Ensure storage service-level admins cannot delete resources they manage.* logic from an example:**
    
Why is this example being flagged as non-compliant
    
```
Allow group SYSADMINS_PROD to manage volume-family in compartment PROD where request.permission!='VOLUME_DELETE'
Allow group SYSADMINS_PROD to manage object-family in compartment PROD where request.permission!='OBJECT_DELETE'
```
    
In the first example:
    `Allow group SYSADMINS_PROD to manage volume-family in compartment PROD where request.permission!='VOLUME_DELETE'`

The SYSADMIN_PROD group has access to [volume-family](https://docs.oracle.com/en-us/iaas/Content/Identity/policyreference/corepolicyreference.htm#For3) which includes volumes, volumes-backups, and boot-volumes-backups.  Meaning while they would not be able to delete volumes they could delete resources of type: volumes-backups, and boot-volumes-backups which is something we are trying to prevent.

In the second example:
    `Allow group SYSADMINS_PROD to manage object-family in compartment PROD where request.permission!='OBJECT_DELETE'`

The SYSADMIN_PROD group has access to [object-family](https://docs.oracle.com/en-us/iaas/Content/Identity/policyreference/objectstoragepolicyreference.htm#Details_for_Object_Storage_Archive_Storage_and_Data_Transfer) which includes buckets and objects. This means they would be able to delete a bucket violating the intent of the rule.  Even though you can't delete a bucket with objects in it if you don't have permissions to the underlying objects you could delete an empty you created thus violating the intent.

### <a name="dynamic-group-recommendation-114"></a>**How does the CIS Compliance Script evaluate recommendation *1.14 Ensure Instance Principal authentication is used for OCI instances, OCI Cloud Databases and OCI Functions to access OCI resources*?**

Dynamic Groups can be scoped at different levels in OCI, so the script cannot reliably determine every instance, function, or Autonomous Database that should access another OCI service. Because of that, this recommendation is evaluated as an existence check rather than a complete workload-to-policy validation.

The recommendation is considered compliant when at least one Dynamic Group has a matching rule that indicates OCI resource principals are being used, such as rules referencing `instance`, `fnfunc`, `autonomousdatabase`, or compartment-scoped rules using `resource.compartment.id`.

The recommendation is considered non-compliant when no Dynamic Group with one of those matching rules is found.

This means the check confirms that Dynamic Groups are being used as the preferred pattern instead of embedded API keys, but it does not prove that every OCI instance, OCI Function, or OCI Cloud Database in the tenancy is covered by a Dynamic Group. Customers should still review the matching rules and the attached IAM policies to verify that the intended workloads are included.

The report shows all discovered Dynamic Groups in the total section. The pass or fail result is based on whether any qualifying matching rule is present, not on the total number of Dynamic Groups.

### <a name="event-rule-target-validation"></a>**Why does the script treat some Events rules as compliant even when the Notifications topic subscription is not active?**

For CIS event-related checks, the script validates Oracle Notifications Service (ONS) targets when it can confirm that the referenced topic has an active subscription.
Note: non-ONS targets are not validated by this check.

### <a name="html-page"></a>**Why are there no dashboard graphics in the HTML page?**

Creating dashboard graphics is optional and requires the presence of the Python library `matplotlib`. To get the dashboard graphics, install the library.

### <a name="xlsx"></a>**Why is the XLSX file not created?**

Writing an XLSX file is optional and requires the presence of Python library `xslxwriter`. To get an XLSX ooutput file, install the library.
