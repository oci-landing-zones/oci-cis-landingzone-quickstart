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
| [oci_kms_vault](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/kms_vault) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| compartment\_id | The default compartment OCID to use for resources (unless otherwise specified). | `string` | `""` | no |
| vault\_name | Vault Name | `string` | `""` | no |
| vault\_type | Vault Type - DEFAULT (Shared) | `string` | `"DEFAULT"` | no |

## Outputs

| Name | Description |
|------|-------------|
| vault | vault information |
