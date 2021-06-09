# June 2021 Release Notes
1. [Logging Consolidation with Service Connector Hub](#logging_consolidation)
2. [Vulnerability Scanning](#vulnerability_scanning)
3. [Ability to provision the Landing Zone with narrower permissions](#narrower_permissions)
4. [Ability to provision Landing Zone within an enclosing compartment at any level in the compartment hierarchy](#enclosing_compartment)
5. [Ability to reuse existing groups when provisioning the Landing Zone](#existing_groups)
	
## <a name="logging_consolidations"></a>1. Logging Consolidation with Service Connector Hub
The Landing Zone enables/collects logs for a few services, like VCN and Audit services. From a governance perspective, it's interesting that these logs get consolidated and made available to security management tools. This capability is now availabe in the Landing Zone with the Service Connector Hub, that reads logs from different sources and sends them to a target that the user chooses. By default, this target is a bucket in the Object Storage service, but functions and streams can also be configured as targets. As the usage of a bucket, function or stream may incur in costs to our customers, Landing Zone users must explicitly activate Service Connector Hub by setting variables in the Terraform configuration, as described in [Logging Variables](terraform.md#logging_variables) section.

To delete or change a Service Connector that has an Object Storage bucket as a target, you must manually remove the target from the Service Connector and manually delete the bucket. A bucket with objects cannot be deleted via Terraform.

## <a name="vulnerability_scanning"></a>2. Vulnerability Scanning
The Landing Zone now enables scanning through the Vulnerability Scanning Service (VSS), creating a scan recipe and scan targets by default. The recipe is set to run every week on sundays and the targets are set to all four Landing Zone compartments. Running the Landing Zone as is, weekly scans are automatically executed for any instances deployed in any of the Landing Zone compartments. The scan results are made available in the Security compartment and can be verified in the OCI Console. 

Scanning can be disabled in the Landing Zone, and the scan frequency and targets can be changed as well. Disabling scanning and changing the frequency are controlled by setting variables in the Terraform configuration, as described in [Scanning Variables](terraform.md#vss_variables) section, while targets can be changed in the vss.tf file. The Vulnerability Scanning Service is free.

## <a name="narrower_permissions"></a>3. Ability to provision the Landing Zone with narrower permissions
Before this release, the Landing Zone required a user with wide permissions in the tenancy in order to be provisioned. Typically, but not necessarily, this user was a member of the *Administrators* group. That has changed. Now the Landing Zone can be provisioned by a user with narrower permissions. However, some pre-requisites need to be satisfied. Specifically, the Landing Zone requires policies created at the tenancy level and broad permissions at the compartment where it is going to be provisioned. 

The Landing Zone handles these requirements with a new Terraform root module that's expected to be executed by a user with wide permissions (typically a member of the *Administrators* group). The module is available in the *pre-config* folder and provisions the following:
	
1. An enclosing compartment for the Landing Zone compartments. 
2. Optionally, a group with the required permissions to provision the Landing Zone in the enclosing compartment.
3. Optionally, Landing Zone required groups for segregation of duties. These groups can then simply be reused when provisioning the Landing Zone.
4. Optionally, required permissions at the tenancy level granted to Landing Zone groups, like permissions granted to Security and IAM administrators.

The variables controlling the pre-config module behavior are described in [Pre-Config Module Variables section](VARIABLES.md#pre_config_input_variables).
	
## <a name="enclosing_compartment"></a>4. Ability to provision Landing Zone within an enclosing compartment at any level in the compartment hierarchy
This can be done by a *wide-permissioned* user or a *narrower-permissioned* user. If done by the *wide-permissioned* user, the steps described in the previous section MUST be skipped. If done by a *narrower-permissioned* user, the steps in the previous section are required. **A _narrower-permissioned_ user is only allowed to provision the Landing Zone in a enclosing compartment previously designated by a _wide-permissioned_ user.**
	
The existing Landing Zone config module has been extended to support this use case. The module keeps backwards compatibility, i.e., the new variables default values keeps the module current behavior unchanged. In other words, if you execute the config module as-is, the four Landing Zone compartments are created directly under the root compartment with all policies created at the root compartment. The module behavior is controlled by variables described in the [Enclosing Compartment Variables section](VARIABLES.md#enc_cmp_variables).
	
## <a name="existing_groups"></a>5. Ability to reuse existing groups when provisioning the Landing Zone
Previously, every Landing Zone execution would create groups. However, it's acknowledged that a customer may want to create multiple Landing Zones but only one set of groups, reusing them across the Landing Zones. The module behavior is controlled by variables described in the [Existing Groups Reuse Variables section](VARIABLES.md#existing_groups_variables).
