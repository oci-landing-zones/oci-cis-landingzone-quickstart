## CIS Landing Zone Service Connector Hub (SCH) Module.

This module manages OCI SCH resources per CIS OCI Benchmark.  
It manages a single Service Connector for all log sources provided in log\_sources variable and a designated target provided in target\_kind variable.  
If target\_kind is 'objectstorage', an Object Storage bucket is created. The bucket is encrypted with either an Oracle managed key or customer managed key.  
For target\_kind is 'objectstorage', if cis\_level = 1 and var.target\_bucket\_kms\_key\_id is not provided, the bucket is encrypted with an Oracle managed key.  
If cis\_level = 2 and var.target\_bucket\_kms\_key\_id is not provided, the module produces an error.  
If target kind is 'streaming, a Stream is either created or used, depending on what is provided in the target\_stream variable. If a name is provided,  
a stream is created. If an OCID is provided, the stream is used.  
If target\_kind is 'functions', a function OCID must be provided in target\_function\_id variable.  
The target resource is created in the compartment provided in compartment\_id variable.  
An IAM policy is created to allow the Service Connector Hub service to push data to the chosen target.

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
| [oci_functions_function](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/functions_function) |
| [oci_identity_compartment](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/identity_compartment) |
| [oci_identity_policy](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_policy) |
| [oci_objectstorage_bucket](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/objectstorage_bucket) |
| [oci_objectstorage_namespace](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/objectstorage_namespace) |
| [oci_sch_service_connector](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/sch_service_connector) |
| [oci_streaming_stream](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/streaming_stream) |
| [oci_streaming_stream](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/streaming_stream) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| activate | Whether the Service Connector should be activated. | `bool` | `false` | no |
| cis\_level | The CIS OCI Benchmark profile level for buckets. Level 1 is be practical and prudent. Level 2 is intended for environments where security is more critical than manageability and usability. | `string` | `"2"` | no |
| compartment\_id | The compartment ocid where to create the Service Connector. | `string` | n/a | yes |
| defined\_tags | The Service Connector defined tags. | `map(string)` | `null` | no |
| display\_name | The Service Connector display name. | `string` | `"lz-service-connector"` | no |
| freeform\_tags | The Service Connector freeform tags. | `map(string)` | `null` | no |
| logs\_sources | The Service Connector logs sources. | <pre>list(object({<br>        compartment_id = string,<br>        log_group_id   = string,<br>        log_id         = string<br>    }))</pre> | n/a | yes |
| policy\_defined\_tags | The Service Connector policy defined tags. | `map(string)` | `null` | no |
| policy\_freeform\_tags | The Service Connector policy freeform tags. | `map(string)` | `null` | no |
| target\_bucket\_kms\_key\_id | The KMS key ocid used to encrypt the target Object Storage bucket. | `string` | n/a | yes |
| target\_bucket\_name | The target Object Storage bucket name to be created. | `string` | `"lz-service-connector-bucket"` | no |
| target\_bucket\_namespace | The target Object Storage bucket namespace. If null, the module retrives the namespace based on the tenancy ocid. | `string` | `null` | no |
| target\_compartment\_id | The target compartment ocid. | `string` | n/a | yes |
| target\_defined\_tags | The Service Connector target defined tags. | `map(string)` | `null` | no |
| target\_freeform\_tags | The Service Connector target freeform tags. | `map(string)` | `null` | no |
| target\_function\_id | The target function ocid. | `string` | `null` | no |
| target\_kind | The target kind. | `string` | `"objectstorage"` | no |
| target\_object\_name\_prefix | The target Object Storage object name prefix. | `string` | `"lz-sch"` | no |
| target\_object\_store\_batch\_rollover\_size\_in\_mbs | The batch rollover size in megabytes. | `number` | `100` | no |
| target\_object\_store\_batch\_rollover\_time\_in\_ms | The batch rollover time in milliseconds. | `number` | `420000` | no |
| target\_policy\_name | The Service Connector target policy name. | `string` | `"lz-service-connector-target-policy"` | no |
| target\_stream | The target stream name or ocid. If a name is given, a new stream is created. If an ocid is given, the existing stream is used. | `string` | `"lz-service-connector-stream"` | no |
| target\_stream\_partitions | The number of partitions in the target stream. Applicable if target\_stream is not an ocid. | `number` | `1` | no |
| target\_stream\_retention\_in\_hours | The retention period of the target stream, in hours. Applicable if target\_stream is not an ocid. | `number` | `24` | no |
| tenancy\_id | The tenancy ocid. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| service\_connector | Managed Service Connector information. |
| service\_connector\_target\_bucket | Managed Object Storage Bucket used as Service Connector target. |
| service\_connector\_target\_stream | Managed Stream used as Service Connector target. |
