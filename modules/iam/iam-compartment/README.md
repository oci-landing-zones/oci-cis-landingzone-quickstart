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
| compartments | n/a | <pre>map(object({<br>    parent_id     = string<br>    name          = string<br>    description   = string<br>    enable_delete = string<br>    defined_tags = map(string)<br>    freeform_tags = map(string)<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| compartments | The compartments, indexed by keys in var.compartments. |
