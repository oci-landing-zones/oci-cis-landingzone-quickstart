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
| [oci_kms_vault.this](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/kms_vault) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | The default compartment OCID to use for resources (unless otherwise specified). | `string` | `""` | no |
| <a name="input_vault_name"></a> [vault\_name](#input\_vault\_name) | Vault Name | `string` | `""` | no |
| <a name="input_vault_type"></a> [vault\_type](#input\_vault\_type) | Vault Type - DEFAULT (Shared) | `string` | `"DEFAULT"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vault"></a> [vault](#output\_vault) | vault information |
