# CIS OCI Landing Zone Quick Start Template

## Table of Contents
1. [Overview](#overview)
1. [Deliverables](#deliverables)
1. [Architecture](#architecture)
1. [Executing Instructions](#instructions)
    1. [Terraform Configuration](terraform.md)
    1. [Compliance Checking](compliance-script.md)
1. [Acknowledgements](#acknowledgements)
1. [The Team](#team)
1. [Feedback](#feedback)
1. [Contribute](#contribute)

## <a name="overview"></a>Overview
This Landing Zone template deploys a standardized environment in an Oracle Cloud Infrastructure (OCI) tenancy that helps organizations to comply with the CIS OCI Foundations Benchmark v1.1.    

The template uses multiple compartments, groups, and IAM policies to segregate access to resources based on job function. The resources within the template are configured to meet the CIS OCI Foundations Benchmark settings related to:

- IAM (Identity & Access Management)
- Networking
- Keys
- Cloud Guard
- Logging
- Events
- Notifications
- Object Storage

 ## <a name="deliverables"></a>Deliverables
 This repository encloses two deliverables:

- A reference implementation written in Terraform HCL (Hashicorp Language) that provisions fully functional resources in an OCI tenancy.
- A Python script that performs compliance checks for most of the CIS OCI Foundations Benchmark recommendations. The script is completely independent of the Terraform code and can be used against any existing tenancy.

 ## <a name="architecture"></a>Architecture 
 The Terraform code deploys a standard three-tier network architecture within a single Virtual Cloud Network (VCN). The three tiers are divided into:
 
 - One public subnet for load balancers and bastion servers;
 - Two private subnets: one for the application tier and one for the database tier.
 
 The Landing Zone template also creates four compartments in the tenancy:
 
 - A network compartment: for all networking resources.
 - A security compartment: for all logging, key management, and notifications resources. 
 - An application development compartment: for application development related services, including compute, storage, functions, streams, Kubernetes, API Gateway, etc. 
 - A database compartment: for all database resources. 

The compartment design reflects a basic functional structure observed across different organizations, where IT responsibilities are typically split among networking, security, application development and database admin teams. Each compartment is assigned an admin group, with enough permissions to perform its duties. The provided permissions lists are not exhaustive and are expected to be appended with new statements as new resources are brought into the Terraform template.

The diagram below shows services and resources that are deployed:

![Architecture](images/Architecture.png)

The greyed out icons in the AppDev and Database compartments indicate services not provisioned by the template.

The resources are provisioned using a single user account with broad tenancy administration privileges.

## <a name="instructions"></a>Executing Instructions

- [Terraform Configuration](terraform.md)
- [Compliance Checking](compliance-script.md)

## <a name="acknowledgements"></a>Acknowledgements
- Parts of the Terraform code reuses and adapts from [Oracle Terraform Modules](https://github.com/oracle-terraform-modules).
- The Compliance Checking script builds on [Adi Zohar's showoci OCI Reporting tool](https://github.com/adizohar/showoci).

## <a name="team"></a>The Team
- **Owners**: [Andre Correa](https://github.com/andrecorreaneto), [Josh Hammer](https://github.com/Halimer)
- **Contributors**: [Logan Kleier](https://github.com/herosjourney), [KC Flynn](https://github.com/flynnkc), Ryan Cronk 

## <a name="feedback">Feedback
We welcome your feedback. To post feedback, submit feature ideas or report bugs, please use the Issues section on this repository.	

## <a name="contribute"></a>Contribute

Interested in contributing?  See our contribution [guidelines](CONTRIBUTING.md) for details.