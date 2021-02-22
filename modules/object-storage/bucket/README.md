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
| [oci_objectstorage_namespace](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/objectstorage_namespace) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| buckets | n/a | <pre>map(object({<br>    compartment_id = string,<br>  }))</pre> | n/a | yes |
| compartment\_name | Compartment Name | `string` | `""` | no |
| kms\_key\_id | KMS Key ID | `string` | `""` | no |
| region | Region | `string` | `""` | no |
| tenancy\_ocid | Tenancy OCID | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| oci\_objectstorage\_buckets | The buckets, indexed by bucket name. |
