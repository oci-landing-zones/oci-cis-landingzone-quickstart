# Frequently Asked Questions
## Questions
- [What is the CIS Oracle Cloud Infrastructure Foundations Benchmark?](#cis)
- [What is the CIS Compliance Script?](#lz)
- [What is the cost of running the CIS Compliance Script?](#cost)
- [What permissions are needed to run the CIS Compliance Script?](#script-access)


## Answers 
<a name="cis"></a>**What is the CIS Oracle Cloud Infrastructure Foundations Benchmark version?**

Objective, consensus-driven, security guidelines for OCI that have been accepted by the Center for Internet Security (CIS) and the supporting CIS community. Click [here](https://www.cisecurity.org/benchmark/oracle_cloud/) to download a copy.

<a name="lz"></a>**2. What is the CIS OCI Landing Zone?**

The CIS Compliance Checking script is a python3 script that can be used on new or existing tenancies that validates configuration in the tenancy for compliance with the CIS OCI Foundations Benchmark Recommendations.  

<a name="cost"></a>**3. What is the cost of running the CIS Compliance Script?**

There is no OCI related cost to run the CIS Compliance Script.

<a name="script"></a>**5. Do I have deploy the Landing Zone to use the the compliance check script?**

No. The [cis_reports.py](https://github.com/oracle-quickstart/oci-cis-landingzone-quickstart/blob/main/scripts/cis_reports.py) is a stand alone python3 script that can be run in any tenancy.   

<a name="script-access"></a>**What permissions are needed to run the CIS Compliance Script?**

Review the script Setup section.

To allow the script to write the reports to an output bucket the below policy must be added to the policy:

`Allow group <Group-Name> to manage objects in compartment <compartment-name> where target.bucket.name='<bucket-name>'`

** The Landing Zones create the Auditor Group and Auditor Policy which provide the required permissions.

<a name="services"></a>**Which OCI services are checked as part of the CIS Compliance Script?**

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
- All Resource `--all-resources`
    - Network Topology
    - All Resources and additional attributes from Search Service


