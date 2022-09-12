## CIS OCI Landing Zone KMS Vaults Module.

This module manages a single OCI KMS vault resource defined by var.name and var.type in compartment var.compartment\_id.

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
| [oci_kms_vault](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/kms_vault) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| compartment\_id | The compartment OCID where the vault is managed. | `string` | n/a | yes |
| defined\_tags | Map of key-value pairs of defined tags for all resources managed by this module. | `map(string)` | `null` | no |
| freeform\_tags | Map of key-value pairs of freeform tags for all resources managed by this module. | `map(string)` | `null` | no |
| name | The vault name. | `string` | `"lz-vault"` | no |
| type | The vault type - DEFAULT (Shared) | `string` | `"DEFAULT"` | no |

## Outputs

| Name | Description |
|------|-------------|
| vault | Vault information. |
