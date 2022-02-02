# February 02, 2022 Release Notes - Stable 2.3.0
1. [Cross Region Landing Zone](#cross_region_lz_2_3_0)
1. [Bring Existing Dynamic Groups](#byodg_2_3_0)
1. [Landing Zone Logo](#lz_logo_2_3_0)

## <a name="cross_region_lz_2_3_0">Cross Region Landing Zone</a>
When you run Landing Zone's Terraform, some resources are created in the home region, while others are created in a region of choice. Among home region resources are compartments, groups, dynamic groups, policies, tag defaults and an infrastructure for IAM related notifications (including events, topics and subscriptions). Among resources created in the region of choice are VCNs, Log Groups, and those pertaining to security services like Vault Service, Vulnerability Scanning, Service Connector Hub, Bastion. The home region resources are automatically made available by OCI in all subscribed regions.

Some customers want to extend their Landing Zone to more than one region of choice, while reusing the home region resources. One typical use case is setting up a second region of choice for disaster recovery, reusing the same home region Landing Zone resources. A more broad use case is implementing a single global Landing Zone across all subscribed regions. These use cases are now supported via the newly introduced *extend_landing_zone_to_new_region*. When set to true, compartments, groups, dynamic groups, policies and resources pertaining to home region are not provisioned, but reused instead.

## <a name="byodg_2_3_0">Bring Existing Dynamic Groups</a>
As with groups, Landing Zone now supports reusing existing *dynamic* groups. These dynamic groups are thought to be used by OCI Functions, Compute's management agent and databases for calling out other services. 
## <a name="lz_logo_2_3_0">Landing Zone Logo</a>
Landing Zone has been gifted with a logo. A courtesy from our colleague [Chris Johnson](https://github.com/therealcmj).

# December 02, 2021 Release Notes - Stable 2.2.0
1. [Updated Topics and Subscription Module (Impacts existing deployments)](#topics_2_2_0)
1. [Enablement of Operational Events and Alarms Specific to Compute, Storage, Database and Governance](#events_and_alarms_2_2_0)
1. [Compliance Checking Script Runs in All Regions](#script_update_2_2_0)
1. [Click to Deploy button](#click_to_deploy_2_2_0)
1. [Added SVG versions of Core Architecture Files](#svg_architecture_files)
1. [Added an optional Budget and Budget Alert Rule](#budget_2_2_0)


## <a name="topics_2_2_0">Updated Topics and Subscription Module (Impacts existing deployments)</a>
In previous versions of the Landing Zone Topics and Subscriptions were a single module.  Going forward there will be a [Topics Module](modules/topics-v2/toopics/README.md) and a [Subscription Module](modules/topics-v2/subscriptions/README.md). **Due to this change upgrading an existing Landing Zone deployment will cause the Security Topic and Subscriptions as well as the Network Topic and Subscriptions to be deleted and recreated.** This will require users receiving these email notifications to re-accept their subscriptions.

## <a name="events_and_alarms_2_2_0">Enablement of Operational Events and Alarms Specific to Compute, Storage, Database and Governance</a>
Customers can now deploy events and alarms specific to operational areas including Compute, Storage, Database and Governance as part of the default Landing Zone deployment. Operational alarms and events can be enabled by entering an email address in. This includes following alarms:
- AppDev Compartment
    - Instance based monitoring and alerting of high cpu and high memory usage for instances deployed in the AppDev compartment.
    - Bare metal unhealthy and VM maintenance alarms are also part of the new core compute alarm set.
- Database Compartment 
    - Databases deployed in the Database compartment operational events and alerts have been enabled for for high ADB CPU and high ADB Storage usage.
    - Autonomous Database Critical Events and ExaData CS Infrastructure events are now tracked in this release.
- Network Compartment
    - Up/Down status for VPN and FastConnect services in the Network compartment of the Landing Zone.

## <a name="script_update_2_2_0">Compliance Checking Script Runs in All Regions</a>
The compliance checking script now runs checks on all available regions in the tenancy and has improved handling of Oracle PSM policy statements.

## <a name="click_to_deploy_2_2_0">Click to Deploy button</a>
Resource Manager stack can be created directly from GitHub repository through a single button click. The zip file with the source code is passed directly to Resource Manager Create Stack API. 

## <a name="svg_architecture_files">Added SVG versions of Core Architecture Files</a>
Added SVG versions of Core Architecture Files so users can modify the architectures using Draw.io.

## <a name="budget_2_2_0">Added an optional Budget and Budget Alert Rule</a>
Customers can now choose to deploy a budget at the root or enclosing compartment level to track monthly spending and be alerted if a forcasted spending breaches a defined threshold. 

A Cost Managment Admin group is also created that grants permission to Create,Update,Delete budgets and also review Cost Data in the UI or by downloading the detailed Cost Reports.
Cost Data View Only permissions have been added to the policies for: Auditor, Database Admin, AppDev Admin, Network Admin and Security Admin allowing members of these groups to review spending. 
  
# October 13, 2021 Release Notes - Stable 2.1.1
1. [CIS Compliance Checking Script Updates](#cis_script_2_1_1)
1. [Bastion Service Enabled by public_src_bastion_cidrs](#bastion_service_update)

## <a name="cis_script_2_1_1">CIS Compliance Checking Script Updates</a>
CIS Compliance checking script will now prepend the OCI tenancy's display name to the output directory it creates if no directory is specified.  An example output directory `tenancy_display_name-20211013`.

## <a name="bastion_service_update">Bastion Service Enabled by public_src_bastion_cidrs</a>
Now [OCI Bastion service] (https://docs.oracle.com/en-us/iaas/Content/Bastion/Concepts/bastionoverview.htm) is enabled when one or more *public_src_bastion_cidrs* are provided **and** a single VCN deployment is selected.  In the previous version it was enabled by default in a single VCN deployment.

# September 24, 2021 Release Notes - Stable 2.1.0
1. [Ability to Provision Infrastructure for Exadata Cloud Service Deployments](#exadata_2_1_0)
1. [OCI Bastion Service Integration](#bastion_2_1_0)
1. [Individual Security Lists for Subnets](#sec_lists_2_1_0)
1. [Ability to Rename Compartments](#cmp_renaming_2_1_0)
1. [Updates to NSGs and Route Rules Descriptions](#rules_descriptions_update_2_1_0)
1. [Input Variable for SSH Connectivity from On-premises Network](#on_prem_ssh_cidrs_2_1_0)
1. [Updates to Resource Manager Interface](#orm_update_2_1_0)

## <a name="exadata_2_1_0">Ability to Provision Infrastructure for Exadata Cloud Service Deployments</a>
Landing Zone can now provision VCNs, compartment, group and policies for Exadata Cloud Service (ExaCS) deployments. The provisioned resources are deployed in tandem with the overall Landing Zone configuration. VCNs are provisioned with client and backup subnets. If a Hub & Spoke network architecture is being deployed, the ExaCS VCNs are configured as spoke VCNs. A compartment is by default created for the ExaCS infrastructure and an extra group and policies are configured accordingly. Optionally, users may opt for deploying ExaCS infrastructure in the database compartment with appropriate permissions granted to database administrators.

## <a name="bastion_2_1_0">OCI Bastion Service Integration</a>
Customers can now leverage OCI Bastion Service in Landing Zone. A Bastion resource is provisioned into a VCN if a single VCN or a single ExaCS VCN is being deployed. Customers can later on create a Bastion session using the provisioned Bastion resource. The Bastion resource is not provisioned for Hub & Spoke architecture or if the Landing Zone VCNs are connected to an on-premises network. In these cases, SSH inbound access is expected to be provided by Bastion servers in the DMZ (Hub) or hosts in the on-premises network.

## <a name="sec_lists_2_1_0">Individual Security Lists for Subnets</a>
Individual security lists are now created for all subnets. This is useful for customers planning on deploying services that require Security Lists instead of Network Security Groups.

## <a name="cmp_renaming_2_1_0">Ability to Rename Compartments</a>
Landing Zone creates compartments with auto-generated names, prefixed by the service_label variable value. Landing Zone compartments can be renamed at any point in time with all policies adjusted accordingly. 

## <a name="rules_descriptions_update_2_1_0">Updates to NSGs and Route Rules Descriptions</a>
The descriptions of rules in NSGs and route tables have been updated aiming at more clarity and verbiage standardization.

## <a name="on_prem_ssh_cidrs_2_1_0">Input Variable for SSH Connectivity from On-premises Network</a>
Variable *onprem_src_ssh_cidrs* is introduced. It is a list of on-premises CIDR blocks allowed to connect to Landing Zone over SSH. It is added to network security rules for ingress connectivity to Landing Zone networks. The *on_prem_ssh_cidrs* must be a subset of the *onprem_cidrs* variable, which are used for routing between on-premises and Landing Zone networks.

## <a name="orm_update_2_1_0">Updates to Resource Manager Interface</a>
With the introduction of Exadata Cloud Service support, Landing Zone schema.yaml has been updated for better usability in OCI Resource Manager. A new variable group named 'Connectivity' has been introduced, containing variables for defining properties that control the sources and destinations for Landing Zone connectivity. 


# August 12, 2021 Release Notes - Stable 2.0.3
1. [Ability to use existing Dynamic Routing Gateway (DRG) v2 with the Landing Zone](#existing_drg_2_0_3)
1. [Consolidated Network and IAM Notifications](#notifications_consolidation_2_0_3)
1. [Database Customer Managed Key Support](#database_key_support_2_0_3)
1. [Compliance Checking supports free tier tenancy](#cis_report_update_2_0_3)


## <a name="existing_drg_2_0_3"></a>1. Ability to use existing Dynamic Routing Gateway (DRG) with the Landing Zone
Customers that have an existing DRG v2 (a DRG created after April 15, 2021) can now use that existing DRG v2 instead of having the Landing Zone create a new DRG v2. This is useful for customers that have connected a FastConnect to an existing DRG.

## <a name="notifications_consolidation_2_0_3"></a>2. Consolidated Network and IAM Notifications
In previous versions of the Landing Zone notification event rules were created for each CIS benchmark monitoring recommendation.  To help reduce the number of event rules created all the IAM recommendations are combined into a single event rule and all the network recommendations are combined into another event rule. 

## <a name="database_key_support_2_0_3"></a>3. Autonomous Database Customer Managed Key Support
Database Administrators now have the ability to use keys from OCI Vaults in the security compartment to encrypt databases in the database compartment.

## <a name="cis_report_update_2_0_3"></a>4. Compliance Checking supports free tier tenancy
Compliance Checking script can now be run free tier OCI tenancy.

# July 2021 Release Notes - Stable 2.0.0
1. [Ability to provision the Landing Zone with narrower permissions](#narrower_permissions)
1. [Ability to provision Landing Zone within an enclosing compartment at any level in the compartment hierarchy](#enclosing_compartment)
1. [Ability to reuse existing groups when provisioning the Landing Zone](#existing_groups)
1. [Hub and Spoke Network Architecture plus networking enhancements](#hub_spoke_network)


## <a name="narrower_permissions"></a>1. Ability to provision the Landing Zone with narrower permissions
Before this release, the Landing Zone required a user with wide permissions in the tenancy in order to be provisioned. Typically, but not necessarily, this user was a member of the *Administrators* group. That has changed. Now the Landing Zone can be provisioned by a user with narrower permissions. However, some pre-requisites need to be satisfied. Specifically, the Landing Zone requires policies created at the tenancy level and broad permissions at the compartment where it is going to be provisioned. 

The Landing Zone handles these requirements with a new Terraform root module that's expected to be executed by a user with wide permissions (typically a member of the *Administrators* group). The module is available in the *pre-config* folder and provisions the following:
	
1. An enclosing compartment for the Landing Zone compartments. 
2. Optionally, a group with the required permissions to provision the Landing Zone in the enclosing compartment.
3. Optionally, Landing Zone required groups for segregation of duties. These groups can then simply be reused when provisioning the Landing Zone.
4. Optionally, required permissions at the tenancy level granted to Landing Zone groups, like permissions granted to Security and IAM administrators.

The variables controlling the pre-config module behavior are described in [Pre-Config Module Variables section](VARIABLES.md#pre_config_input_variables).
	
## <a name="enclosing_compartment"></a>2. Ability to provision Landing Zone within an enclosing compartment at any level in the compartment hierarchy
This can be done by a *wide-permissioned* user or a *narrower-permissioned* user. If done by the *wide-permissioned* user, the steps described in the previous section MUST be skipped. If done by a *narrower-permissioned* user, the steps in the previous section are required. **A _narrower-permissioned_ user is only allowed to provision the Landing Zone in a enclosing compartment previously designated by a _wide-permissioned_ user.**
	
The existing Landing Zone config module has been extended to support this use case. The module keeps backwards compatibility, i.e., the new variables default values keeps the module current behavior unchanged. In other words, if you execute the config module as-is, the four Landing Zone compartments are created directly under the root compartment with all policies created at the root compartment. 

The module behavior is controlled by variables described in the [Enclosing Compartment Variables section](VARIABLES.md#enc_cmp_variables).
	
## <a name="existing_groups"></a>3. Ability to reuse existing groups when provisioning the Landing Zone
Previously, every Landing Zone execution would create groups. However, it's acknowledged that a customer may want to create multiple Landing Zones but only one set of groups, reusing them across the Landing Zones. 

The module behavior is controlled by variables described in the [Existing Groups Reuse Variables section](VARIABLES.md#existing_groups_variables).

## <a name="hub_spoke_network"></a>4. Hub and Spoke Network Architecture plus networking enhancements

Before this release, the Landing Zone would deploy a single VCN with three subnets designed for a 3-tier application with DRG if on-premises connectivity was required.  In this new release we enhanced the networking and network security modules to can support the creation of multiple VCNs (spokes or stand-alone) and the following Hub and Spoke network architectures:
- **Access to multiple VCNs in the same region:** This scenario enables communication between an on-premises network and multiple VCNs in the same region over a single FastConnect private virtual circuit or Site-to-Site VPN and uses a DRG as the hub.
- **Access between multiple networks through a single DRG with a firewall between networks:** This scenario connects several VCNs to a single DRG, with all routing configured to send packets through a firewall in a hub VCN before they can be sent to another network.

In addition to the above architectures, you can choose if want to allow the creation of Internet Gateways and NAT Gateways to provide a more isolated network. Lastly, we have also added support for various network variables to take lists of CIDR ranges instead of a single CIDR. 

The module behavior is controlled by variables described in the [Networking Variables section](VARIABLES.md#networking-variables).


# June 2021 Release Notes - Stable 1.1.1
1. [Logging Consolidation with Service Connector Hub](#logging_consolidation)
1. [Vulnerability Scanning](#vulnerability_scanning)

	
## <a name="logging_consolidations"></a>1. Logging Consolidation with Service Connector Hub
The Landing Zone enables/collects logs for a few services, like VCN and Audit services. From a governance perspective, it's interesting that these logs get consolidated and made available to security management tools. This capability is now availabe in the Landing Zone with the Service Connector Hub, that reads logs from different sources and sends them to a target that the user chooses. By default, this target is a bucket in the Object Storage service, but functions and streams can also be configured as targets. As the usage of a bucket, function or stream may incur in costs to our customers, Landing Zone users must explicitly activate Service Connector Hub by setting variables in the Terraform configuration, as described in [Logging Variables](terraform.md#logging_variables) section.

To delete or change a Service Connector that has an Object Storage bucket as a target, you must manually remove the target from the Service Connector and manually delete the bucket. A bucket with objects cannot be deleted via Terraform.

## <a name="vulnerability_scanning"></a>2. Vulnerability Scanning
The Landing Zone now enables scanning through the Vulnerability Scanning Service (VSS), creating a scan recipe and scan targets by default. The recipe is set to run every week on sundays and the targets are set to all four Landing Zone compartments. Running the Landing Zone as is, weekly scans are automatically executed for any instances deployed in any of the Landing Zone compartments. The scan results are made available in the Security compartment and can be verified in the OCI Console. 

Scanning can be disabled in the Landing Zone, and the scan frequency and targets can be changed as well. Disabling scanning and changing the frequency are controlled by setting variables in the Terraform configuration, as described in [Scanning Variables](terraform.md#vss_variables) section, while targets can be changed in the vss.tf file. The Vulnerability Scanning Service is free.