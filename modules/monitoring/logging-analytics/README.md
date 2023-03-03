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
| [oci_log_analytics_log_analytics_log_group.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/log_analytics_log_analytics_log_group) | resource |
| [oci_log_analytics_namespace.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/log_analytics_namespace) | resource |
| [oci_log_analytics_namespaces.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/log_analytics_namespaces) | data source |
| [oci_objectstorage_namespace.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/objectstorage_namespace) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_defined_tags"></a> [defined\_tags](#input\_defined\_tags) | Logging Analytics defined tags. | `map(string)` | `null` | no |
| <a name="input_freeform_tags"></a> [freeform\_tags](#input\_freeform\_tags) | Logging Analytics freeform tags. | `map(string)` | `null` | no |
| <a name="input_log_group_compartment_id"></a> [log\_group\_compartment\_id](#input\_log\_group\_compartment\_id) | The compartment ocid for the log group. | `string` | n/a | yes |
| <a name="input_log_group_name"></a> [log\_group\_name](#input\_log\_group\_name) | The log group name. | `string` | `"lz-logging-analytics-log-group"` | no |
| <a name="input_tenancy_id"></a> [tenancy\_id](#input\_tenancy\_id) | The tenancy ocid. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_log_group"></a> [log\_group](#output\_log\_group) | Logging Analytics log group. |
