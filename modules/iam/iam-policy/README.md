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
| [oci_identity_policy](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/identity_policy) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| policies | n/a | <pre>map(object({<br>    description  = string<br>    compartment_id = string<br>    statements = list(string)<br>    defined_tags = string<br>    freeform_tags = string<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| policies | The policies, are indexed by name. |
