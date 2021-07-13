# Frequently Asked Questions
## Questions
- [What is the CIS Oracle Cloud Infrastructure Foundations Benchmark version 1.1.0?](#cis)
- [What is the CIS OCI Landing Zone?](#lz)
- [What is the cost of the services created by the Landing Zone?](#cost)
- [What permissions are needed to deploy the Landing Zone?](#access)
- [Do I have deploy the Landing Zone to use the the compliance check script?](#script)
- [What permissions are needed to run the compliance script?](#script-access)
- [What network architectures can be deployed by the Landing Zone?](#networking)
- [Which OCI services can be deployed by the Landing Zone?](#services)

## Answers 
<a name="cis"></a>**What is the CIS Oracle Cloud Infrastructure Foundations Benchmark version 1.1.0?**

Objective, consensus-driven, security guidelines for OCI that have been accepted by the Center for Internet Security (CIS) and the supporting CIS community. Click [here](https://www.cisecurity.org/benchmark/oracle_cloud/) to download a copy.

<a name="lz"></a>**What is the CIS Landing Zone?**

The CIS Landing Zone is a publicly available reference architecture for creating the foundations of a secure tenancy on OCI following best practices from the CIS Benchmark for OCI; along with best practices developed in OCI for our own Oracle PaaS, SaaS, and IT services.  In addition to the reference architecture, the Landing Zone includes easy to deploy Terraform code (Quick Start) that automates the creation of a secure tenancy and a compliance checking script that can be used on new or existing tenancies that validates configuration in the tenancy for compliance with the CIS benchmark recommendations.  

<a name="cost"></a>**What is the cost of the services created by the Landing Zone?**

There is no cost to the resources deployed out by the Landing Zone. However, the use of Service Hub Connector and OCI Logging may incur some charges for data stored and processed.

<a name="permissions"></a>**What permissions are needed to deploy the Landing Zone?**

The pre-config module, that is expected to be executed by a user with broad permissions (typically a member of the Administrators group).

Users then assigned to the Provisioning Group will be able to provision Landing Zone resources in the Enclosing compartment and the few required resources in the Root compartment.

<a name="script"></a>**Do I have deploy the Landing Zone to use the the compliance check script?**

No. The [cis_reports.py](https://github.com/oracle-quickstart/oci-cis-landingzone-quickstart/blob/main/scripts/cis_reports.py) is a stand alone python3 script that can be run in any tenancy.   

<a name="script-access"></a>**What permissions are needed to run the compliance script?**

The user running the script show be in the Auditors group.

To allow the Auditor group to write to the reports to an output bucket the below policy must be added to the  **<service label>-AuditorAccess-Policy**:
`Allow group <prefix>-Auditors to manage objects in compartment <compartment-name> where target.bucket.name='<bucket-name>'`

<a name="networking"></a>**What network architectures can be deployed by the Landing Zone?**

The Landing Zone can deploy multiple network architectures.  It can create multiple VCNs as either stand alone networks or in one of the below Hub and Spoke architectures:
- **Access to multiple VCNs in the same region:** This scenario enables communication between an on-premises network and multiple VCNs in the same region over a single FastConnect private virtual circuit or Site-to-Site VPN and uses a DRG as the hub.
- **Access between multiple networks through a single DRG with a firewall between networks:** This scenario connects several VCNs to a single DRG, with all routing configured to send packets through a firewall in a hub VCN before they can be sent to another network.

You can choose if want to allow the creation of Internet Gateways and NAT Gateways to provide a more isolated network. 

<a name="services"></a>**Which OCI services can be deployed by the Landing Zone??**

The Landing Zone can deploy the following services:
- IAM (Identity & Access Management)
    - Compartments
    - Groups
    - Policies
- Networking
    - VCN (Virtual Cloud Networks)
        - Route Tables
        - Internet Gateway (IGW)
        - NAT Gateway   
        - Service Gateway (SGW)
        - Dynamic Gateway Attachments
        - Default Security Lists
        - Network Security Groups
    - Dynamic Routing Gateways (DRG)
- Vaults
    - Keys
- Cloud Guard
- Logging
    - Logs
    - Log Groups
- Service Connector Hub
- Vulnerability Scanning
- Events
- Notifications
- Object Storage

