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
| [oci_identity_dynamic_group.these](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/identity_dynamic_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dynamic_groups"></a> [dynamic\_groups](#input\_dynamic\_groups) | n/a | <pre>map(object({<br>    description    = string<br>    compartment_id = string<br>    matching_rule  = string<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dynamic_groups"></a> [dynamic\_groups](#output\_dynamic\_groups) | The dynamic-groups indexed by group name. |
