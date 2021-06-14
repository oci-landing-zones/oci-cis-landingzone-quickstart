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
| [oci_cloud_guard_cloud_guard_configuration](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/cloud_guard_cloud_guard_configuration) |
| [oci_cloud_guard_detector_recipes](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/cloud_guard_detector_recipes) |
| [oci_cloud_guard_responder_recipes](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/cloud_guard_responder_recipes) |
| [oci_cloud_guard_target](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/cloud_guard_target) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| compartment\_id | The default compartment OCID where Cloud Guard is enabled. | `string` | n/a | yes |
| default\_target | The default Cloud Guard target. | `object({name=string, type=string, id=string})` | n/a | yes |
| reporting\_region | Cloud Guard reporting region. | `string` | n/a | yes |
| self\_manage\_resources | Whether or not to self manage resources. | `bool` | `false` | no |
| status | Cloud Guard status. | `string` | `"ENABLED"` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloud\_guard\_config | Cloud Guard configuration information. |
| cloud\_guard\_target | Cloud Guard target information. |
