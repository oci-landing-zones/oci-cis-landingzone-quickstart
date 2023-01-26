## CIS Landing Zone Service Connector Hub (SCH) Module.

This module manages OCI SCH resources per CIS OCI Benchmark.
It manages a single Service Connector for all log sources provided in log\_sources variable and a designated target provided in target\_kind variable.
If target\_kind is 'objectstorage', an Object Storage bucket is created. The bucket is encrypted with either an Oracle managed key or customer managed key.
For target\_kind is 'objectstorage', if cis\_level = 1 and var.target\_bucket\_kms\_key\_id is not provided, the bucket is encrypted with an Oracle managed key.
If cis\_level = 2 and var.target\_bucket\_kms\_key\_id is not provided, the module produces an error.
If target kind is 'streaming, a Stream is either created or used, depending on what is provided in the target\_stream variable. If a name is provided,
a stream is created. If an OCID is provided, the stream is used.
If target\_kind is 'functions', a function OCID must be provided in target\_function\_id variable.
If target\_kind is 'logginganalytics', aa log group for Logging Analytics service is created, named by target\_log\_group\_name variable. Logging Analytics service is enabled if not already.
The target resource is created in the compartment provided in compartment\_id variable.
An IAM policy is created to allow the Service Connector Hub service to push data to the chosen target.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | >= 4.80.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | >= 4.80.0 |
| <a name="provider_oci.home"></a> [oci.home](#provider\_oci.home) | >= 4.80.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_identity_policy.service_connector](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_policy) | resource |
| [oci_logging_log.bucket](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/logging_log) | resource |
| [oci_logging_log_group.bucket](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/logging_log_group) | resource |
| [oci_objectstorage_bucket.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/objectstorage_bucket) | resource |
| [oci_sch_service_connector.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/sch_service_connector) | resource |
| [oci_streaming_stream.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/streaming_stream) | resource |
| [oci_functions_function.existing_function](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/functions_function) | data source |
| [oci_identity_compartment.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/identity_compartment) | data source |
| [oci_objectstorage_namespace.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/objectstorage_namespace) | data source |
| [oci_streaming_stream.existing_stream](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/streaming_stream) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_activate"></a> [activate](#input\_activate) | Whether the Service Connector should be activated. | `bool` | `false` | no |
| <a name="input_cis_level"></a> [cis\_level](#input\_cis\_level) | The CIS OCI Benchmark profile level for buckets. Level 1 is be practical and prudent. Level 2 is intended for environments where security is more critical than manageability and usability. | `string` | `"1"` | no |
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | The compartment ocid where to create the Service Connector. | `string` | n/a | yes |
| <a name="input_defined_tags"></a> [defined\_tags](#input\_defined\_tags) | The Service Connector defined tags. | `map(string)` | `null` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | The Service Connector display name. | `string` | `"lz-service-connector"` | no |
| <a name="input_freeform_tags"></a> [freeform\_tags](#input\_freeform\_tags) | The Service Connector freeform tags. | `map(string)` | `null` | no |
| <a name="input_logs_sources"></a> [logs\_sources](#input\_logs\_sources) | The Service Connector logs sources. | <pre>list(object({<br>        compartment_id = string,<br>        log_group_id   = string,<br>        log_id         = string<br>    }))</pre> | n/a | yes |
| <a name="input_policy_defined_tags"></a> [policy\_defined\_tags](#input\_policy\_defined\_tags) | The Service Connector policy defined tags. | `map(string)` | `null` | no |
| <a name="input_policy_freeform_tags"></a> [policy\_freeform\_tags](#input\_policy\_freeform\_tags) | The Service Connector policy freeform tags. | `map(string)` | `null` | no |
| <a name="input_target_bucket_kms_key_id"></a> [target\_bucket\_kms\_key\_id](#input\_target\_bucket\_kms\_key\_id) | The KMS key ocid used to encrypt the target Object Storage bucket. | `string` | n/a | yes |
| <a name="input_target_bucket_name"></a> [target\_bucket\_name](#input\_target\_bucket\_name) | The target Object Storage bucket name to be created. | `string` | `"lz-service-connector-bucket"` | no |
| <a name="input_target_bucket_namespace"></a> [target\_bucket\_namespace](#input\_target\_bucket\_namespace) | The target Object Storage bucket namespace. If null, the module retrives the namespace based on the tenancy ocid. | `string` | `null` | no |
| <a name="input_target_compartment_id"></a> [target\_compartment\_id](#input\_target\_compartment\_id) | The target compartment ocid. | `string` | n/a | yes |
| <a name="input_target_defined_tags"></a> [target\_defined\_tags](#input\_target\_defined\_tags) | The Service Connector target defined tags. | `map(string)` | `null` | no |
| <a name="input_target_freeform_tags"></a> [target\_freeform\_tags](#input\_target\_freeform\_tags) | The Service Connector target freeform tags. | `map(string)` | `null` | no |
| <a name="input_target_function_id"></a> [target\_function\_id](#input\_target\_function\_id) | The target function ocid. | `string` | `null` | no |
| <a name="input_target_kind"></a> [target\_kind](#input\_target\_kind) | The target kind. | `string` | `"objectstorage"` | no |
| <a name="input_target_log_group_id"></a> [target\_log\_group\_id](#input\_target\_log\_group\_id) | The target log group ocid. Used when target\_kind = logginganalytics. | `string` | `null` | no |
| <a name="input_target_object_name_prefix"></a> [target\_object\_name\_prefix](#input\_target\_object\_name\_prefix) | The target Object Storage object name prefix. | `string` | `"lz-sch"` | no |
| <a name="input_target_object_store_batch_rollover_size_in_mbs"></a> [target\_object\_store\_batch\_rollover\_size\_in\_mbs](#input\_target\_object\_store\_batch\_rollover\_size\_in\_mbs) | The batch rollover size in megabytes. | `number` | `100` | no |
| <a name="input_target_object_store_batch_rollover_time_in_ms"></a> [target\_object\_store\_batch\_rollover\_time\_in\_ms](#input\_target\_object\_store\_batch\_rollover\_time\_in\_ms) | The batch rollover time in milliseconds. | `number` | `420000` | no |
| <a name="input_target_policy_name"></a> [target\_policy\_name](#input\_target\_policy\_name) | The Service Connector target policy name. | `string` | `"lz-service-connector-target-policy"` | no |
| <a name="input_target_stream"></a> [target\_stream](#input\_target\_stream) | The target stream name or ocid. If a name is given, a new stream is created. If an ocid is given, the existing stream is used. | `string` | `"lz-service-connector-stream"` | no |
| <a name="input_target_stream_partitions"></a> [target\_stream\_partitions](#input\_target\_stream\_partitions) | The number of partitions in the target stream. Applicable if target\_stream is not an ocid. | `number` | `1` | no |
| <a name="input_target_stream_retention_in_hours"></a> [target\_stream\_retention\_in\_hours](#input\_target\_stream\_retention\_in\_hours) | The retention period of the target stream, in hours. Applicable if target\_stream is not an ocid. | `number` | `24` | no |
| <a name="input_tenancy_id"></a> [tenancy\_id](#input\_tenancy\_id) | The tenancy ocid. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_connector"></a> [service\_connector](#output\_service\_connector) | Managed Service Connector information. |
| <a name="output_service_connector_target"></a> [service\_connector\_target](#output\_service\_connector\_target) | Managed Service Connector target. |
