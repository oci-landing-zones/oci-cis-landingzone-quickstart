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
| defined\_tags | Any defined tags to apply on the VSS resources. | `map(string)` | `{}` | no |
| freeform\_tags | Any freeform tags to apply on the VSS resources. | `map(string)` | `{}` | no |
| name\_prefix | A prefix used when naming resources created by this module. | `string` | `null` | no |
| tenancy\_id | The tenancy ocid. | `string` | n/a | yes |
| vss\_create | Whether or not VSS resources (recipes, targets and policies) are to be created. | `bool` | `true` | no |
| vss\_custom\_recipes | VSS custom recipes. Use it to override the default recipe. | <pre>map(object({<br>    compartment_id                          = string,<br>    name                                    = string,<br>    agent_scan_level                        = string,<br>    agent_configuration_vendor              = string,<br>    agent_cis_benchmark_settings_scan_level = string,<br>    port_scan_level                         = string,<br>    schedule_type                           = string,<br>    schedule_day_of_week                    = string,<br>    defined_tags                            = map(string),<br>    freeform_tags                           = map(string)<br>  }))</pre> | `{}` | no |
| vss\_custom\_targets | VSS custom targets. Use it to override the default targets. For recipe\_key, pass the corresponding key in vss\_custom\_recipes. | <pre>map(object({<br>    compartment_id        = string,<br>    name                  = string,<br>    description           = string,<br>    recipe_key            = string,<br>    target_compartment_id = string,<br>    defined_tags          = map(string),<br>    freeform_tags         = map(string)<br>  }))</pre> | `{}` | no |
| vss\_policy\_name | The VSS policy name. Use it to override the default policy name, which is either <name-prefix>-vss-policy or vss-policy. | `string` | `null` | no |
| vss\_recipe\_name | The recipe name. Use it to override the default one, that is either <name-prefix>-default-scan-recipe or default-scan-recipe. | `string` | `null` | no |
| vss\_scan\_day | The week day for the VSS recipe, if enabled. Only applies if vss\_scan\_schedule is WEEKLY (case insensitive). | `string` | `"SUNDAY"` | no |
| vss\_scan\_schedule | The scan schedule for the VSS recipe, if enabled. Valid values are WEEKLY or DAILY (case insensitive). | `string` | `"WEEKLY"` | no |
| vss\_target\_names | A list with the VSS target names. | `list(string)` | n/a | yes |
| vss\_targets | The VSS targets. The map indexes MUST match the values in vss\_target\_names. | <pre>map(object({<br>    target_compartment_id = string<br>    target_compartment_name = string<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| vss\_custom\_recipes | The VSS custom recipes. |
| vss\_custom\_targets | The VSS custom targets. |
| vss\_recipes | The VSS recipes. |
| vss\_targets | The VSS targets. |
