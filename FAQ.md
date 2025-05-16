# Frequently Asked Questions
## Questions
- [What is the CIS Oracle Cloud Infrastructure Foundations Benchmark?](#cis)
- [What is the CIS Compliance Script?](#script)
- [What is the cost of running the CIS Compliance Script?](#cost)
- [What permissions are needed to run the CIS Compliance Script?](#script-access)

## Answers 
<a name="cis"></a>**What is the CIS Oracle Cloud Infrastructure Foundations Benchmark version?**

Objective, consensus-driven, security guidelines for OCI that have been accepted by the Center for Internet Security (CIS) and the supporting CIS community. Click [here](https://www.cisecurity.org/benchmark/oracle_cloud/) to download a copy.

<a name="script"></a>**2. What is the CIS OCI Landing Zone?**

The CIS Compliance Script is a Python script that can run on new or existing tenancies to validate configuration in the tenancy for compliance with the CIS OCI Foundations Benchmark Recommendations.

<a name="cost"></a>**3. What is the cost of running the CIS Compliance Script?**

There are no OCI-related costs to run the CIS Compliance Script.

<a name="script-access"></a>**What permissions are needed to run the CIS Compliance Script?**

Review the script Setup section.

To allow the script to write the reports to an output bucket, the following policy must be added to the policy:

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
- All Resources `--all-resources`
    - Network Topology
    - All Resources and additional attributes from Search Service


