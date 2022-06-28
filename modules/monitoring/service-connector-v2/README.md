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
| [oci_identity_compartment](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/identity_compartment) |
| [oci_identity_policy](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_policy) |
| [oci_objectstorage_bucket](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/objectstorage_bucket) |
| [oci_objectstorage_namespace](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/objectstorage_namespace) |
| [oci_sch_service_connector](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/sch_service_connector) |
| [oci_streaming_stream](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/streaming_stream) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| compartment\_id | The compartment ocid where to create the Service Connector. | `string` | n/a | yes |
| defined\_tags | The Service Connector defined tags. | `map(string)` | `null` | no |
| display\_name | The Service Connector display name. | `string` | `"service-connector"` | no |
| enable\_service\_connector | Whether the Service Connector should be enabled. | `bool` | `false` | no |
| freeform\_tags | The Service Connector freeform tags. | `map(string)` | `null` | no |
| logs\_sources | The Service Connector logs sources. | <pre>list(object({<br>        compartment_id = string,<br>        log_group_id   = string,<br>        log_id         = string<br>    }))</pre> | n/a | yes |
| policy\_compartment\_id | The Service Connector policy compartment ocid | `string` | `null` | no |
| policy\_defined\_tags | The Service Connector policy defined tags | `map(string)` | `null` | no |
| policy\_freeform\_tags | The Service Connector policy freeform tags | `map(string)` | `null` | no |
| service\_label | The service label. | `string` | n/a | yes |
| target\_bucket\_kms\_key\_id | The KMS key ocid used to encrypt the target Object Storage bucket. | `string` | n/a | yes |
| target\_bucket\_name | The target Object Storage bucket name to be created. | `string` | `"service-connector-bucket"` | no |
| target\_compartment\_id | The target compartment ocid. | `string` | n/a | yes |
| target\_defined\_tags | The Service Connector target defined tags. | `map(string)` | `null` | no |
| target\_freeform\_tags | The Service Connector target freeform tags. | `map(string)` | `null` | no |
| target\_function\_id | The target function ocid. | `string` | `null` | no |
| target\_kind | The target kind. | `string` | `"objectstorage"` | no |
| target\_object\_name\_prefix | The target Object Storage object name prefix. | `string` | `"sch"` | no |
| target\_object\_store\_batch\_rollover\_size\_in\_mbs | The batch rollover size in megabytes. | `number` | `100` | no |
| target\_object\_store\_batch\_rollover\_time\_in\_ms | The batch rollover time in milliseconds. | `number` | `420000` | no |
| target\_policy\_name | The Service Connector target policy name | `string` | `"service-connector-target-policy"` | no |
| target\_stream | The target stream name or ocid. If a name is given, a new stream is created. If an ocid is given, the existing stream is used. | `string` | `"service-connector-stream"` | no |
| target\_stream\_partitions | The number of partitions in the target stream. Applicable if target\_stream is not an ocid. | `number` | `1` | no |
| target\_stream\_retention\_in\_hours | The retention period of the target stream, in hours. Applicable if target\_stream is not an ocid. | `number` | `24` | no |
| tenancy\_ocid | The tenancy ocid. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| service\_connector | Managed Service Connector information |
| service\_connector\_target\_bucket | Managed Object Storage Bucket used as Service Connector target |
| service\_connector\_target\_stream | Managed Stream used as Service Connector target |
