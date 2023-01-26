## CIS OCI Landing Zone Security Zone Module.

This module manages Cloud Guard Security Zones targets and recipes.
It manages multiple Security Zones and recipes in var.sz\_target\_compartments and the policies for those recipes in var.security\_policies
The module will create one recipe for each compartment and create a Security Zone for each compartment with the associated recipe.
Each recipe will include CIS Level 1 or CIS Level 2 polices based on var.cis\_level and append the customer provided polices in var.security\_policies

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_cloud_guard_security_recipe.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/cloud_guard_security_recipe) | resource |
| [oci_cloud_guard_security_zone.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/cloud_guard_security_zone) | resource |
| [oci_cloud_guard_security_policies.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/cloud_guard_security_policies) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cis_level"></a> [cis\_level](#input\_cis\_level) | Determines CIS OCI Benchmark Level to apply on Landing Zone managed resources. Level 1 is be practical and prudent. Level 2 is intended for environments where security is more critical than manageability and usability. More info: https://www.cisecurity.org/benchmark/oracle_cloud | `string` | `"1"` | no |
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | The compartment OCID where default Security Zones recipes are defined. Typically, this is the tenancy OCID. | `string` | n/a | yes |
| <a name="input_defined_tags"></a> [defined\_tags](#input\_defined\_tags) | Security Zone and Security Zone recipe defined tags. | `map(string)` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the Security Zone and Security Zone recipe it will be appended to the security zone and security recipe name. | `string` | `""` | no |
| <a name="input_freeform_tags"></a> [freeform\_tags](#input\_freeform\_tags) | Security Zone and Security Zone recipe freeform tags. | `map(string)` | `null` | no |
| <a name="input_security_policies"></a> [security\_policies](#input\_security\_policies) | List of Security Zone Policies OCIDs which will be merged with CIS security zone policies. | `list` | `null` | no |
| <a name="input_sz_target_compartments"></a> [sz\_target\_compartments](#input\_sz\_target\_compartments) | Map of compartment OCIDs and Security Zone Compartment names to create and attach a security zones to. | <pre>map(object({<br>    sz_compartment_id = string<br>    sz_compartment_name = string<br>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_security_zone_recipes"></a> [security\_zone\_recipes](#output\_security\_zone\_recipes) | The seccurity zones recipes, indexed by keys. |
| <a name="output_security_zones"></a> [security\_zones](#output\_security\_zones) | The seccurity zones, indexed by keys. |
