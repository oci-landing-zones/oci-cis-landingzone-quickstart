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
| [oci_cloud_guard_security_recipe.these](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/cloud_guard_security_recipe) | resource |
| [oci_cloud_guard_security_zone.these](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/cloud_guard_security_zone) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_security_zones"></a> [security\_zones](#input\_security\_zones) | --------------------------------------------------------------- --- Cloud Guard Security Zone Recipe variables ---------------- --------------------------------------------------------------- | <pre>map(object({<br>    tenancy_ocid        = string<br>    service_label       = string<br>    compartment_id      = string<br>    description         = string<br>    security_policies   = list(string)<br>    cis_level           = string<br>    defined_tags        = map(string)<br>    freeform_tags       = map(string)<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_security_zone_recipes"></a> [security\_zone\_recipes](#output\_security\_zone\_recipes) | The seccurity zones, indexed by keys. |
| <a name="output_security_zones"></a> [security\_zones](#output\_security\_zones) | The seccurity zones, indexed by keys. |
