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
| [oci_identity_dynamic_group](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/identity_dynamic_group) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| dynamic\_groups | n/a | <pre>map(object({<br>    description    = string<br>    compartment_id = string<br>    matching_rule  = string<br>    defined_tags = map(string)<br>    freeform_tags = map(string)<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| dynamic\_groups | The dynamic-groups indexed by group name. |
