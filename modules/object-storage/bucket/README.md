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
| [oci_objectstorage_bucket](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/objectstorage_bucket) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| buckets | n/a | <pre>map(object({<br>    compartment_id = string,<br>    name           = string,<br>    namespace      = string<br>  }))</pre> | n/a | yes |
| kms\_key\_id | KMS Key ID | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| oci\_objectstorage\_buckets | The buckets, indexed by bucket name. |
