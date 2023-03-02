## CIS OCI Landing Zone Vulnerability Scanning Service (VSS) Module

This module manages one single VSS recipe, and multiple VSS targets.
The recipe is assigned to all provided targets.
var.vss\_custom\_recipes and var.vss\_custom\_targets, when provided, are added to Landing Zone default recipe and targets.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | >= 4.80.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | >= 4.80.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_vulnerability_scanning_host_scan_recipe.custom](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/vulnerability_scanning_host_scan_recipe) | resource |
| [oci_vulnerability_scanning_host_scan_recipe.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/vulnerability_scanning_host_scan_recipe) | resource |
| [oci_vulnerability_scanning_host_scan_target.custom](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/vulnerability_scanning_host_scan_target) | resource |
| [oci_vulnerability_scanning_host_scan_target.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/vulnerability_scanning_host_scan_target) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | The compartment ocid where VSS recipes and targets are created. | `string` | n/a | yes |
| <a name="input_defined_tags"></a> [defined\_tags](#input\_defined\_tags) | Any defined tags to apply on the VSS resources. | `map(string)` | `null` | no |
| <a name="input_freeform_tags"></a> [freeform\_tags](#input\_freeform\_tags) | Any freeform tags to apply on the VSS resources. | `map(string)` | `null` | no |
| <a name="input_tenancy_id"></a> [tenancy\_id](#input\_tenancy\_id) | The tenancy ocid. | `string` | n/a | yes |
| <a name="input_vss_agent_cis_benchmark_settings_scan_level"></a> [vss\_agent\_cis\_benchmark\_settings\_scan\_level](#input\_vss\_agent\_cis\_benchmark\_settings\_scan\_level) | Valid values: STRICT, MEDIUM, LIGHTWEIGHT, NONE. STRICT: If more than 20% of the CIS benchmarks fail, then the target is assigned a risk level of Critical. MEDIUM: If more than 40% of the CIS benchmarks fail, then the target is assigned a risk level of High. LIGHTWEIGHT: If more than 80% of the CIS benchmarks fail, then the target is assigned a risk level of High. NONE: disables cis benchmark scanning. | `string` | `"MEDIUM"` | no |
| <a name="input_vss_agent_scan_level"></a> [vss\_agent\_scan\_level](#input\_vss\_agent\_scan\_level) | Valid values: STANDARD, NONE. STANDARD enables agent-based scanning. NONE disables agent-based scanning and moots any agent related attributes. | `string` | `"STANDARD"` | no |
| <a name="input_vss_custom_recipes"></a> [vss\_custom\_recipes](#input\_vss\_custom\_recipes) | VSS custom recipes. Use it to override the default recipe. | <pre>map(object({<br>    compartment_id                          = string,<br>    name                                    = string,<br>    agent_scan_level                        = string,<br>    agent_configuration_vendor              = string,<br>    agent_cis_benchmark_settings_scan_level = string,<br>    port_scan_level                         = string,<br>    schedule_type                           = string,<br>    schedule_day_of_week                    = string,<br>    enable_file_scan                        = bool,<br>    file_scan_recurrence                    = string,<br>    folders_to_scan                         = list(string),<br>    folders_to_scan_os                      = string,<br>    defined_tags                            = map(string),<br>    freeform_tags                           = map(string)<br>  }))</pre> | `{}` | no |
| <a name="input_vss_custom_targets"></a> [vss\_custom\_targets](#input\_vss\_custom\_targets) | VSS custom targets. Use it to override the default targets. For recipe\_key, pass the corresponding key in vss\_custom\_recipes. | <pre>map(object({<br>    compartment_id        = string,<br>    name                  = string,<br>    description           = string,<br>    recipe_key            = string,<br>    target_compartment_id = string,<br>    defined_tags          = map(string),<br>    freeform_tags         = map(string)<br>  }))</pre> | `{}` | no |
| <a name="input_vss_enable_file_scan"></a> [vss\_enable\_file\_scan](#input\_vss\_enable\_file\_scan) | Whether file scanning is enabled. | `bool` | `false` | no |
| <a name="input_vss_folders_to_scan"></a> [vss\_folders\_to\_scan](#input\_vss\_folders\_to\_scan) | A list of folders to scan. Only applies if vss\_enable\_folder\_scan is true. | `list(string)` | `[]` | no |
| <a name="input_vss_policy_name"></a> [vss\_policy\_name](#input\_vss\_policy\_name) | The VSS policy name. Use it to override the default policy name, which is either <name-prefix>-vss-policy or vss-policy. | `string` | `null` | no |
| <a name="input_vss_port_scan_level"></a> [vss\_port\_scan\_level](#input\_vss\_port\_scan\_level) | Valid values: STANDARD, LIGHT, NONE. STANDARD checks the 1000 most common port numbers, LIGHT checks the 100 most common port numbers, NONE does not check for open ports. | `string` | `"STANDARD"` | no |
| <a name="input_vss_recipe_name"></a> [vss\_recipe\_name](#input\_vss\_recipe\_name) | The recipe name. Use it to override the default one, that is either <name-prefix>-default-scan-recipe or default-scan-recipe. | `string` | `"lz-scan-recipe"` | no |
| <a name="input_vss_scan_day"></a> [vss\_scan\_day](#input\_vss\_scan\_day) | The week day for the VSS recipe, if enabled. Only applies if vss\_scan\_schedule is WEEKLY (case insensitive). | `string` | `"SUNDAY"` | no |
| <a name="input_vss_scan_schedule"></a> [vss\_scan\_schedule](#input\_vss\_scan\_schedule) | The scan schedule for the VSS recipe, if enabled. Valid values are WEEKLY or DAILY (case insensitive). | `string` | `"WEEKLY"` | no |
| <a name="input_vss_target_names"></a> [vss\_target\_names](#input\_vss\_target\_names) | A list with the VSS target names. | `list(string)` | n/a | yes |
| <a name="input_vss_targets"></a> [vss\_targets](#input\_vss\_targets) | The VSS targets. The map indexes MUST match the values in vss\_target\_names. | <pre>map(object({<br>    target_compartment_id = string<br>    target_compartment_name = string<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vss_recipes"></a> [vss\_recipes](#output\_vss\_recipes) | The VSS recipes, including custom ones. |
| <a name="output_vss_targets"></a> [vss\_targets](#output\_vss\_targets) | The VSS targets, including custom ones. |
