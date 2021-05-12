# May 2021 Release Notes

It's May 2021. And we have just rolled out some exciting features in CIS OCI Landing Zone:

## 1 - Ability to provision the Landing Zone with narrower permissions

Before this release, the Landing Zone required a user with wide permissions in the tenancy in order to be provisioned. Typically, but not necessarily, this user was a member of the *Administrators* group. That has changed. Now the Landing Zone can be provisioned by a user with narrower permissions. However, some pre-requisites need to be satisfied. Specifically, the Landing Zone requires policies created at the tenancy level and broad permissions at the compartment where it is going to be provisioned. 

The Landing Zone handles these requirements with a new Terraform root module that's expected to be executed by a user with wide permissions (typically a member of the *Administrators* group). The module is available in the *pre-config* folder and provisions the following:
	
1. An enclosing compartment for the Landing Zone compartments. 
2. Optionally, a group with the required permissions to provision the Landing Zone in the enclosing compartment.
3. Optionally, Landing Zone required groups for segregation of duties. These groups can then simply be reused when provisioning the Landing Zone.
4. Optionally, required permissions at the tenancy level granted to Landing Zone groups, like permissions granted to Security and IAM administrators.
	
The following input variables control the *pre-config* module behavior:
	
**unique_prefix**: a label that gets prefixed to all default resource names created by the module. It's required.
	
**use_existing_provisioning_group**: a boolean flag indicating whether or not to use an existing group for provisioning. If false, the module creates a group. Default value is false.
	
**existing_provisioning_group_name(*)**: the group name to which Landing Zone required provisioning permissions (IAM policy) are granted. If no group name is given, the module assigns a default name and creates the group if use_existing_provisioning_group is false. The IAM policy is created at the root compartment.
	
**enclosing_compartment_name**: A compartment name that will hold the Landing Zone compartments. If no compartment name is given, the module creates the compartment with a default name.
	
**existing_enclosing_compartment_parent_ocid**: the parent compartment ocid of the top compartment, indicating where to insert the top compartment in the hierarchy. Remember that OCI has a max six level compartment hierarchy. If you create the top level compartment at level five, the Landing Zone compartments will be at level six and adding sub-compartments to Landing Zone compartments will not be possible.
	
**create_lz_groups**: a boolean flag indicating whether or not to create all Landing Zone groups used for segregation of duties. Default is true. 

**create_tenancy_level_policies**: Whether or not tenancy level policies for Landing Zone groups are created. The tenancy administrator has the option of not creating the tenancy level policies. **However, this affects Landing Zone groups to operate at their full capacity**.

**existing_iam_admin_group_name**: An existing group name for IAM administrators. Ignored if create_lz_groups is true.

**existing_cred_admin_group_name**: An existing group name for credential administrators. Ignored if create_lz_groups is true.

**existing_security_admin_group_name**: An existing group name for security administrators. Ignored if create_lz_groups is true.

**existing_network_admin_group_name**: An existing group name for network administrators. Ignored if create_lz_groups is true.

**existing_appdev_admin_group_name**: An existing group name for application development administrators. Ignored if create_lz_groups is true.

**existing_database_admin_group_name**: An existing group name for database administrators. Ignored if create_lz_groups is true.

**existing_auditor_group_name**: An existing group name for auditors. Ignored if create_lz_groups is true.

**existing_announcement_reader_group_name**: An existing group name for announcement readers. Ignored if create_lz_groups is true.

(*) A user with an API key must be assigned to the provisioning group. The module does not create or assign the user.
	

## 2 - Ability to provision Landing Zone within an enclosing compartment at any level in the compartment hierarchy

This can be done by a *wide-permissioned* user or a *narrower-permissioned* user. If done by the *wide-permissioned* user, the steps described in the previous section MUST be skipped. If done by a *narrower-permissioned* user, the steps in the previous section are required. **A *narrower-permissioned* user is only allowed to provision the Landing Zone in a enclosing compartment previously designated by a *wide-permissioned* user.**
	
The existing Landing Zone config module has been extended to support this use case. The module keeps backwards compatibility, i.e., the new variables default values keeps the module current behavior unchanged. In other words, if you execute the config module as-is, the four Landing Zone compartments are created directly under the root compartment with all policies created at the root compartment.
	
The following input variables control the extended config module behavior:
	
**enclosing_compartment**: a boolean flag indicating whether or not to provision the Landing Zone within an enclosing compartment other than the root compartment. Default is false. **When provisioning the Landing Zone as a *narrower-permissioned* user, **make sure to set this variable value to true**.
	
**existing_enclosing_compartment_ocid**: the OCID of a pre-existing enclosing compartment where Landing Zone compartments are to be created. If *enclosing_compartment* is false, the module creates the Landing Zone compartments in the root compartment as long as the executing user has the required permission.
	
**use_existing_tenancy_policies**: the Landing Zone requires policies attached to the root compartment to work at full capacity. For instance, security administrators are expect to manage Cloud Guard, Tag Namespaces, Tag Defaults, Event Rules, and others. Likewise, IAM administrators are expected to manage IAM resources in general. Such capabilities are only enabled if policies are created at the root compartment, as they apply to the tenancy as a whole. A *narrower-permissioned* user will not likely have the permissions to create policies at the tenancy level. As a consequence, it is expected that these policies are previously created by a *wide-permissioned* user. Therefore, when provisioning the Landing Zone as a *narrower-permissioned* user, **make sure to set this variable value to true, in which case tenancy level permissions creation is skipped**. Default is false, meaning the Landing Zone will  provision the tenancy level policies as long as the executing user has the required permission.

## 3 - Ability to reuse existing groups when provisioning the Landing Zone

Previously, every Landing Zone execution would create groups. However, it's acknowledged that a customer may want to create multiple Landing Zones but only one set of groups, reusing them across the Landing Zones.
	
The following input variables control group reuse behavior in the extended config module:
	
**use_existing_iam_groups**: a boolean flag indicating whether or not to reuse pre-existing IAM groups. Default is false, in which case the module MUST be executed with a user with permissions to create IAM groups.
	
**iam_admin_group_name**: the pre-existing group to which IAM related admin permissions are granted to. Ignored if use_existing_iam_groups is false.
	
**cred_admin_group_name**: the pre-existing group to which credential related admin permissions are granted to. Ignored if use_existing_iam_groups is false.
	
**security_admin_group_name**: the pre-existing group to which security related admin permissions are granted to. Ignored if use_existing_iam_groups is false.
	
**network_admin_group_name**: the pre-existing group to which network related admin permissions are granted to. Ignored if use_existing_iam_groups is false.
	
**appdev_admin_group_name**: the pre-existing group to which application development related admin permissions are granted to. Ignored if use_existing_iam_groups is false.
	
**database_admin_group_name**: the pre-existing group to which database related admin permissions are granted to. Ignored if use_existing_iam_groups is false.
	
**auditor_group_name**: the pre-existing group to which auditing related permissions are granted to. Ignored if use_existing_iam_groups is false.
	
**announcement_readers_group_name**: the pre-existing group to which announcement reading related permissions are granted to. Ignored if use_existing_iam_groups is false.