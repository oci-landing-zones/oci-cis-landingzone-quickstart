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
| [oci_kms_key.these](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/kms_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | The default compartment OCID to use for resources (unless otherwise specified). | `string` | `""` | no |
| <a name="input_keys"></a> [keys](#input\_keys) | n/a | <pre>map(object({<br>    key_shape_algorithm = string,<br>    key_shape_length = string<br>  }))</pre> | n/a | yes |
| <a name="input_vault_mgmt_endPoint"></a> [vault\_mgmt\_endPoint](#input\_vault\_mgmt\_endPoint) | KMS vault management end point | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_keys"></a> [keys](#output\_keys) | Vault keys, indexed by the key display\_name |
