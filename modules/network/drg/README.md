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
| [oci_core_drg](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_drg) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| compartment\_id | Compartment's OCID where VCN will be created. | `any` | n/a | yes |
| is\_create\_drg | Whether a DRG is to be created. | `bool` | `false` | no |
| service\_label | A service label to be used as part of resource names. | `any` | n/a | yes |
| defined\_tags | Map of key-value pairs of defined tags. | `map(string)` | null | no |
| freeform\_tags | Map of key-value pairs of freeform tags. | `map(string)` | null | no |

## Outputs

| Name | Description |
|------|-------------|
| drg | DRG information. |
