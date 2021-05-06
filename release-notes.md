# May 2021 Release Notes

It's May 2021. And we have just rolled out some exciting features in CIS OCI Landing Zone:

## 1 - Ability to provision the Landing Zone as a non tenancy administrator

Before this release, the Landing Zone required a user with tenancy administrator permissions to be provisioned. That has changed. However, the tenancy administrator still has some work to do, as some pre-requisites need to be satisfied. Specifically, the tenancy administrator needs to provide the following:
	
1. A group with the required permissions for someone else to provision the Landing Zone.
2. A top compartment for enclosing the Landing Zone compartments.
3. Optionally, Landing Zone required groups for segregation of duties. These groups can then simply be reused when provisioning the Landing Zone.
4. Optionally, required permissions at the tenancy level granted to Landing Zone groups.
	
Fortunately, the Landing Zone automates all these steps with a new Terraform root module that's expected to be executed by the tenancy administrator. The module is available in the pre-config folder.
	
The following input variables control the pre-config module behavior:
	
**unique_prefix**: a label that gets prefixed to all default resource names created by the module. It's required.
	
**use_existing_provisioning_group**: a boolean flag indicating whether or not to use an existing group for provisioning. If false, the module creates a group. Default value is false.
	
**lz_provisioning_group_name**: the group name to which Landing Zone required provisioning permissions (IAM policy) are granted. If no group name is given, the module assigns a default name and creates the group if use_existing_provisioning_group is false. The IAM policy is created at the root compartment. (*)
	
**lz_top_compartment_name**: A compartment name that will hold the Landing Zone compartments. If no compartment name is given, the module creates the compartment with a default name.
	
**lz_top_compartment_parent_id**: the parent compartment ocid of the top compartment, indicating where to insert the top compartment in the hierarchy. Remember that OCI has a max six level compartment hierarchy. If you create the top level compartment at level five, the Landing Zone compartments will be at level six and adding subcompartments to Landing Zone compartments will not be possible.
	
**create_lz_groups**: a boolean flag indicating whether or not to create all Landing Zone groups used for segregation of duties. If true, the groups and tenancy level permissions (IAM policy) required by these groups are created. Default is true. The IAM policy is created at the root compartment.
	
(*) A user with an API key must be assigned to the provisioning group. The module does not create or assign the user.
	

## 2 - Ability to provision Landing Zone within a top level compartment at any level in the compartment hierarchy

This can be done by the tenancy administrator or a non tenancy administrator. If done by the tenancy administrator, the steps described in the previous section MUST be skipped. If done by a non tenancy administrator, the steps in the previous section are required. A non tenancy administrator is only allowed to provision the Landing Zone in a enclosing compartment previously created by someone with greater compartment and policy management permissions.
	
The existing Landing Zone config module has been extended to support this use case. Note, however, that the module keeps backwards compatibility, i.e., the new variables default values keeps the module current behavior unchanged.
	
The following input variables control the extended config module behavior:
	
**top_compartment**: a boolean flag indicating whether or not to provision the Landing Zone within a single enclosing compartment. Default is false.
	
**existing_top_compartment_ocid**: the OCID of a pre-existing enclosing compartment where Landing Zone compartments are to be created. Ignored if top_compartment is false.
	
The module now detectes whether or not the executing user is a member of the Administrators group. If not and top_compartment is false, the code aborts as that is not a valid combination.

## 3 - Ability to reuse existing groups when provisioning the Landing Zone

Previously, every Landing Zone execution in a tenancy would create groups. However, it's acknowledged that a customer may want to create multiple Landing Zones but only one set of groups, reusing them across the Landing Zones.
	
The folowwing input variables control group reuse behavior in the extended config module:
	
**use_existing_iam_groups**: a boolean flag indicating whether or not to reuse pre-existing IAM groups. Default is false.
	
**iam_admin_group_name**: the pre-existing group to which IAM related admin permissions are granted to. Ignored if use_existing_iam_groups is false.
	
**cred_admin_group_name**: the pre-existing group to which credential related admin permissions are granted to. Ignored if use_existing_iam_groups is false.
	
**security_admin_group_name**: the pre-existing group to which security related admin permissions are granted to. Ignored if use_existing_iam_groups is false.
	
**network_admin_group_name**: the pre-existing group to which network related admin permissions are granted to. Ignored if use_existing_iam_groups is false.
	
**appdev_admin_group_name**: the pre-existing group to which application development related admin permissions are granted to. Ignored if use_existing_iam_groups is false.
	
**database_admin_group_name**: the pre-existing group to which database related admin permissions are granted to. Ignored if use_existing_iam_groups is false.
	
**auditor_group_name**: the pre-existing group to which auditing related permissions are granted to. Ignored if use_existing_iam_groups is false.
	
**announcement_readers_group_name**: the pre-existing group to which announcement reading related permissions are granted to. Ignored if use_existing_iam_groups is false.