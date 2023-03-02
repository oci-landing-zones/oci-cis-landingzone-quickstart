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
| [oci_identity_policy.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_defined_tags"></a> [defined\_tags](#input\_defined\_tags) | Policies defined tags. | `map(string)` | `null` | no |
| <a name="input_enable_tenancy_level_policies"></a> [enable\_tenancy\_level\_policies](#input\_enable\_tenancy\_level\_policies) | Whether policies for OCI services are enabled at the tenancy level. | `bool` | `true` | no |
| <a name="input_freeform_tags"></a> [freeform\_tags](#input\_freeform\_tags) | Policies freeform tags. | `map(string)` | `null` | no |
| <a name="input_policies"></a> [policies](#input\_policies) | Managed policies. Notice that tenancy level policies are not to be passed, preferrably. They are best defined inside the module and enabled via enable\_tenancy\_level\_policies variable. | <pre>map(object({<br>    name           = string<br>    description    = string<br>    compartment_id = string<br>    statements     = list(string)<br>    defined_tags   = map(string)<br>    freeform_tags  = map(string)<br>  }))</pre> | `{}` | no |
| <a name="input_service_label"></a> [service\_label](#input\_service\_label) | The service label, use as a prefix to resource names. | `string` | n/a | yes |
| <a name="input_tenancy_id"></a> [tenancy\_id](#input\_tenancy\_id) | The tenancy ocid. | `string` | n/a | yes |
| <a name="input_tenancy_policy_name"></a> [tenancy\_policy\_name](#input\_tenancy\_policy\_name) | The policy name for tenancy level policies. | `string` | `"services-policy"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_policies"></a> [policies](#output\_policies) | The policies. |
