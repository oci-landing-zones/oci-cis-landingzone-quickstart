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
| [oci_kms_key](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/kms_key) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| compartment\_id | The default compartment OCID to use for resources (unless otherwise specified). | `string` | `""` | no |
| keys | n/a | <pre>map(object({<br>    key_shape_algorithm = string,<br>    key_shape_length = string<br>  }))</pre> | n/a | yes |
| vault\_mgmt\_endPoint | KMS vault management end point | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| keys | Vault keys, indexed by the key display\_name |
