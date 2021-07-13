# CIS OCI Landing Zone Quick Start Template

## Table of Contents
1. [Overview](#overview)
1. [Deliverables](#deliverables)
1. [Architecture](#architecture)
    1. [Network](#arch-network)
    1. [IAM](#arch-iam)
    1. [Diagram](#arch-diagram)
1. [Executing Instructions](#instructions)
    1. [Terraform Configuration](terraform.md)
    1. [Compliance Checking](compliance-script.md)
1. [Documentation](#documentation)
1. [Frequently Asked Questions](FAQ.md)
1. [Acknowledgements](#acknowledgements)
1. [The Team](#team)
1. [Feedback](#feedback)
1. [Contribute](#CONTRIBUTING.md)

## <a name="overview"></a>Overview
This Landing Zone template deploys a standardized environment in an Oracle Cloud Infrastructure (OCI) tenancy that helps organizations to comply with the [CIS OCI Foundations Benchmark v1.1](https://www.cisecurity.org/benchmark/oracle_cloud/).    

The template uses multiple compartments, groups, and IAM policies to segregate access to resources based on job function. The resources within the template are configured to meet the CIS OCI Foundations Benchmark settings related to:

- IAM (Identity & Access Management)
- Networking
- Keys
- Cloud Guard
- Logging
- Vulnerability Scanning
- Events
- Notifications
- Object Storage

 ## <a name="deliverables"></a>Deliverables
 This repository encloses two deliverables:

- A reference implementation written in Terraform HCL (Hashicorp Language) that provisions fully functional resources in an OCI tenancy.
- A Python script that performs compliance checks for most of the CIS OCI Foundations Benchmark recommendations. The script is completely independent of the Terraform code and can be used against any existing tenancy.

 ## <a name="architecture"></a>Architecture
 ### <a name="arch-iam"></a>IAM
The Landing Zone template creates four compartments in the tenancy or under the **enclosing compartment**:
 - A network compartment: for all networking resources.
 - A security compartment: for all logging, key management, scanning, and notifications resources. 
 - An application development compartment: for application development related services, including compute, storage, functions, streams, Kubernetes, API Gateway, etc. 
 - A database compartment: for all database resources. 
 - An enclosing compartment: provision the above four Landing Zone compartments within a compartment at any level in the compartment hierarchy. 

The compartment design reflects a basic functional structure observed across different organizations, where IT responsibilities are typically split among networking, security, application development and database admin teams. Each compartment is assigned an admin group, with enough permissions to perform its duties. The provided permissions lists are not exhaustive and are expected to be appended with new statements as new resources are brought into the Terraform template.

 ### <a name="arch-networking"></a>Networking
 The Terraform code deploys a standard three-tier network architecture within one or more Virtual Cloud Network (VCN)s. The three tiers are divided into:
 
 - One public subnet for load balancers and bastion servers;
 - Two private subnets: one for the application tier and one for the database tier.
 
The VCNs are either stand alone networks or in one of the below Hub and Spoke architectures:
- **Access to multiple VCNs in the same region:** This scenario enables communication between an on-premises network and multiple VCNs in the same region over a single FastConnect private virtual circuit or Site-to-Site VPN and uses a DRG as the hub.
- **Access between multiple networks through a single DRG with a firewall between networks:** This scenario connects several VCNs to a single DRG, with all routing configured to send packets through a firewall in a hub VCN before they can be sent to another network.

The above can be deploy without the creation of Internet Gateways and NAT Gateways to provide a more isolated network. 

### <a name="arch-diagram"></a>Diagram
The diagram below shows services and resources that are deployed:

![Architecture](images/Architecture.png)

The greyed out icons in the AppDev and Database compartments indicate services not provisioned by the template.

## <a name="instructions"></a>Executing Instructions

- [Terraform Configuration](terraform.md)
- [Compliance Checking](compliance-script.md)

## <a name="documentation"></a>Documentation
- [CIS OCI Landing Zone Quick Start Template Version 2](https://www.ateam-oracle.com/cis-oci-landing-zone-quick-start-template-version-2)
- [Deployment Modes for CIS OCI Landing Zone](https://www.ateam-oracle.com/deployment-modes-for-cis-oci-landing-zone)
- [Tenancy Pre Configuration For Deploying CIS OCI Landing Zone as a non-Administrator](https://www.ateam-oracle.com/tenancy-pre-configuration-for-deploying-cis-oci-landing-zone-as-a-non-administrator)
- [CIS OCI Landing Zone V2 Networking](https://www.ateam-oracle.com/cis-oci-landing-zone-v2-networking)
- [Strong Security posture monitoring with Cloud Guard](https://www.ateam-oracle.com/cloud-guard-support-in-cis-oci-landing-zone)
- [Vulnerability Scanning in CIS OCI Landing Zone](https://www.ateam-oracle.com/vulnerability-scanning-in-cis-oci-landing-zone)
- [Logging consolidation with Service Connector Hub](https://www.ateam-oracle.com/security-log-consolidation-in-cis-oci-landing-zone)

## <a name="acknowledgements"></a>Acknowledgements
- Parts of the Terraform code reuses and adapts from [Oracle Terraform Modules](https://github.com/oracle-terraform-modules).
- The Compliance Checking script builds on [Adi Zohar's showoci OCI Reporting tool](https://github.com/adizohar/showoci).

## <a name="team"></a>The Team
- **Owners**: [Andre Correa](https://github.com/andrecorreaneto), [Josh Hammer](https://github.com/Halimer)
- **Contributors**: Pulkit Sharma, [KC Flynn](https://github.com/flynnkc), [Logan Kleier](https://github.com/herosjourney)

## <a name="feedback"></a>Feedback
We welcome your feedback. To post feedback, submit feature ideas or report bugs, please use the Issues section on this repository.	

## <a name="known-issues"></a>Known Issues
- By default, OCI compartments are not deleted as part of *terraform destroy*. Deletion can be enabled by setting *enable_cmp_delete* variable to true in locals.tf file. Note, however, that compartments may take a long time to delete. Not deleting compartments is ok if you plan on reusing them. For more information about deleting compartments in OCI via Terraform, check [here](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/identity_compartment)

- Terraform or Resource Manager fails to Apply with 401 Unauthorized error.  This is due to an eventual consistency issue were the IAM policy for Cloud Guard is avialble yet.

- Enabling `no_internet-access` on currently deployed stack fails to apply due to timeout.  This is due to the the OCI terraform provider, to resolve the IGW(s) and and NATGW(s) must be deleted manually before applying. 