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
| defined\_tags | Map of key-value pairs of defined tags. | `map(string)` | null | no |
| freeform\_tags | Map of key-value pairs of freeform tags. | `map(string)` | null | no |

## Outputs

| Name | Description |
|------|-------------|
| vault | vault information |
