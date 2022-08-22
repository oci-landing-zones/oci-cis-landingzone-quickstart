## CIS OCI Landing Zone Vulnerability Scanning Service (VSS) Module

This module manages one single VSS recipe, multiple VSS targets and one IAM policy for VSS.  
The recipe is assigned to all provided targets.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| oci | n/a |

## Modules

No Modules.

## Resources

| Name |
|------|
| [oci_identity_policy](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_policy) |
| [oci_vulnerability_scanning_host_scan_recipe](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/vulnerability_scanning_host_scan_recipe) |
| [oci_vulnerability_scanning_host_scan_target](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/vulnerability_scanning_host_scan_target) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| compartment\_id | The compartment ocid where VSS recipes and targets are created. | `string` | n/a | yes |
| defined\_tags | Any defined tags to apply on the VSS resources. | `map(string)` | `null` | no |
| freeform\_tags | Any freeform tags to apply on the VSS resources. | `map(string)` | `null` | no |
| tenancy\_id | The tenancy ocid. | `string` | n/a | yes |
| vss\_agent\_cis\_benchmark\_settings\_scan\_level | Valid values: STRICT, MEDIUM, LIGHTWEIGHT, NONE. STRICT: If more than 20% of the CIS benchmarks fail, then the target is assigned a risk level of Critical. MEDIUM: If more than 40% of the CIS benchmarks fail, then the target is assigned a risk level of High. LIGHTWEIGHT: If more than 80% of the CIS benchmarks fail, then the target is assigned a risk level of High. NONE: disables cis benchmark scanning. | `string` | `"MEDIUM"` | no |
| vss\_agent\_scan\_level | Valid values: STANDARD, NONE. STANDARD enables agent-based scanning. NONE disables agent-based scanning and moots any agent related attributes. | `string` | `"STANDARD"` | no |
| vss\_enable\_file\_scan | Whether file scanning is enabled. | `bool` | `false` | no |
| vss\_folders\_to\_scan | A list of folders to scan. Only applies if vss\_enable\_folder\_scan is true. | `list(string)` | n/a | yes |
| vss\_policy\_name | The VSS policy name. Use it to override the default policy name, which is either <name-prefix>-vss-policy or vss-policy. | `string` | `null` | no |
| vss\_port\_scan\_level | Valid values: STANDARD, LIGHT, NONE. STANDARD checks the 1000 most common port numbers, LIGHT checks the 100 most common port numbers, NONE does not check for open ports. | `string` | `"STANDARD"` | no |
| vss\_recipe\_name | The recipe name. Use it to override the default one, that is either <name-prefix>-default-scan-recipe or default-scan-recipe. | `string` | `"lz-scan-recipe"` | no |
| vss\_scan\_day | The week day for the VSS recipe, if enabled. Only applies if vss\_scan\_schedule is WEEKLY (case insensitive). | `string` | `"SUNDAY"` | no |
| vss\_scan\_schedule | The scan schedule for the VSS recipe, if enabled. Valid values are WEEKLY or DAILY (case insensitive). | `string` | `"WEEKLY"` | no |
| vss\_target\_names | A list with the VSS target names. | `list(string)` | n/a | yes |
| vss\_targets | The VSS targets. The map indexes MUST match the values in vss\_target\_names. | <pre>map(object({<br>    target_compartment_id = string<br>    target_compartment_name = string<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| vss\_recipes | The VSS recipes. |
| vss\_targets | The VSS targets. |
