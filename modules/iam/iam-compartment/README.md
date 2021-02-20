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
| [oci_identity_compartment](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/identity_compartment) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| compartments | n/a | <pre>map(object({<br>    description  = string<br>  }))</pre> | n/a | yes |
| tenancy\_ocid | The OCID of the tenancy. | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| compartments | The compartments, indexed by name. |
