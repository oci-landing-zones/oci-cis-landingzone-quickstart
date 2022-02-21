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
| [oci_logging_log_group](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/logging_log_group) |
| [oci_logging_log](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/logging_log) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| compartment\_id | n/a | `string` | `""` | no |
| log\_group\_description | n/a | `string` | `""` | no |
| log\_group\_display\_name | n/a | `string` | `""` | no |
| defined\_tags | Map of key-value pairs of defined tags. | `map(string)` | null | no |
| freeform\_tags | Map of key-value pairs of defined tags. | `map(string)` | null | no |
| target\_resources | n/a | <pre>map(object({<br>        log_display_name              = string<br>        log_type                      = string<br>        log_config_source_resource    = string<br>        log_config_source_category    = string<br>        log_config_source_service     = string<br>        log_config_source_source_type = string<br>        log_config_compartment        = string<br>        log_is_enabled                = bool<br>        log_retention_duration        = number<br>        defined_tags                  = map(string)<br>        freeform_tags                 = map(string)<br>    }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| log\_group | Log Group information. |
| logs | The logs, indexed by display name. |
