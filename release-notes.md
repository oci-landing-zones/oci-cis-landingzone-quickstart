# June 2021 Release Notes

It's June 2021. And we have just rolled out some exciting features in CIS OCI Landing Zone:

1. [Ability to provision the Landing Zone with narrower permissions](#narrower_permissions)
1. [Ability to provision Landing Zone within an enclosing compartment at any level in the compartment hierarchy](#enclosing_compartment)
1. [Ability to reuse existing groups when provisioning the Landing Zone](#existing_groups)
1. [Logging Consolidation with Service Connector Hub](#logging_consolidation)

## <a name="narrower_permissions"></a>1 - Ability to provision the Landing Zone with narrower permissions

Before this release, the Landing Zone required a user with wide permissions in the tenancy in order to be provisioned. Typically, but not necessarily, this user was a member of the *Administrators* group. That has changed. Now the Landing Zone can be provisioned by a user with narrower permissions. However, some pre-requisites need to be satisfied. Specifically, the Landing Zone requires policies created at the tenancy level and broad permissions at the compartment where it is going to be provisioned. 

The Landing Zone handles these requirements with a new Terraform root module that's expected to be executed by a user with wide permissions (typically a member of the *Administrators* group). The module is available in the *pre-config* folder and provisions the following:
	
1. An enclosing compartment for the Landing Zone compartments. 
2. Optionally, a group with the required permissions to provision the Landing Zone in the enclosing compartment.
3. Optionally, Landing Zone required groups for segregation of duties. These groups can then simply be reused when provisioning the Landing Zone.
4. Optionally, required permissions at the tenancy level granted to Landing Zone groups, like permissions granted to Security and IAM administrators.
	
The following input variables control the *pre-config* module behavior:
	
**unique_prefix**: a label that gets prefixed to all default resource names created by the module. It's required.
	
**use_existing_provisioning_group**: a boolean flag indicating whether or not an existing group will be used for Landing Zone provisioning. If false, one group is created for each compartment defined by enclosing_compartment_names variable. Default is false.
	
**existing_provisioning_group_name(*)**: The name of an existing group to be used for provisioning all resources in the compartments defined by enclosing_compartment_names variable. Ignored if use_existing_provisioning_group is false.
	
**enclosing_compartment_names**: The compartment names that will hold the Landing Zone compartments. If no compartment name is given, the module creates one compartment with a default name (<unique_prefix>-top-cmp).
	
**existing_enclosing_compartments_parent_ocid**: the parent compartment ocid of the top compartment, indicating where to insert the enclosing compartment in the hierarchy. Remember that OCI has a max six level compartment hierarchy. If you create the enclosing compartment at level five, the Landing Zone compartments will be at level six and adding sub-compartments to Landing Zone compartments will not be possible.
	
**use_existing_lz_groups**: a boolean flag indicating whether or not existing groups are to be reused for Landing Zone. If false, one set of groups is created for each compartment defined by enclosing_compartment_names variable. If true, existing group names must be provided and this single set will be able to manage resources in all those compartments. Default is false. 

**create_tenancy_level_policies**: Whether or not policies for Landing Zone groups are created at the root compartment. If false, Landing Zone groups will not be able to manage resources at the root compartment level. **Please notice this affects Landing Zone groups to operate at their full capacity**. Default is true.

**existing_iam_admin_group_name**: An existing group name for IAM administrators. Ignored if create_lz_groups is true.

**existing_cred_admin_group_name**: An existing group name for credential administrators. Ignored if create_lz_groups is true.

**existing_security_admin_group_name**: An existing group name for security administrators. Ignored if create_lz_groups is true.

**existing_network_admin_group_name**: An existing group name for network administrators. Ignored if create_lz_groups is true.

**existing_appdev_admin_group_name**: An existing group name for application development administrators. Ignored if create_lz_groups is true.

**existing_database_admin_group_name**: An existing group name for database administrators. Ignored if create_lz_groups is true.

**existing_auditor_group_name**: An existing group name for auditors. Ignored if create_lz_groups is true.

**existing_announcement_reader_group_name**: An existing group name for announcement readers. Ignored if create_lz_groups is true.

(*) A user with an API key must be assigned to the provisioning group. The module does not create or assign the user.
	

## <a name="enclosing_compartment"></a>2 - Ability to provision Landing Zone within an enclosing compartment at any level in the compartment hierarchy

This can be done by a *wide-permissioned* user or a *narrower-permissioned* user. If done by the *wide-permissioned* user, the steps described in the previous section MUST be skipped. If done by a *narrower-permissioned* user, the steps in the previous section are required. **A _narrower-permissioned_ user is only allowed to provision the Landing Zone in a enclosing compartment previously designated by a _wide-permissioned_ user.**
	
The existing Landing Zone config module has been extended to support this use case. The module keeps backwards compatibility, i.e., the new variables default values keeps the module current behavior unchanged. In other words, if you execute the config module as-is, the four Landing Zone compartments are created directly under the root compartment with all policies created at the root compartment. The module behavior is controlled by variables described in the [Enclosing Compartment Variables section](terraform.md#enc_cmp_variables).
	
## <a name="existing_groups"></a>3 - Ability to reuse existing groups when provisioning the Landing Zone

Previously, every Landing Zone execution would create groups. However, it's acknowledged that a customer may want to create multiple Landing Zones but only one set of groups, reusing them across the Landing Zones. The module behavior is controlled by variables described in the [Existing Groups Reuse Variables section](terraform.md#existing_groups_variables).
	
## <a name="logging_consolidations"></a>4 - Logging Consolidation with Service Connector Hub

The Landing Zone enables/collects logs for a few services, like VCN and Audit services. From a governance perspective, it's interesting that these logs get consolidated and made available to security management tools. This capability is now availabe in the Landing Zone with the Service Connector Hub, that reads logs from different sources and sends them to a target that the user chooses. By default, this target is a bucket in the Object Storage service, but functions and streams can also be configured as targets. As the usage of a bucket, function or stream may incur in costs to our customers, Landing Zone users must explicitly activate Service Connector Hub by setting variables in the Terraform configuration, as described in [Logging Variables section](terraform.md#logging_variables).