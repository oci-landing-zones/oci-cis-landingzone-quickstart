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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| compartment\_id | The default compartment OCID to use for resources (unless otherwise specified). | `string` | `""` | no |
| reporting\_region | Cloud Guard reporting region. | `string` | `""` | no |
| self\_manage\_resources | Whether or not to self manage resources. | `bool` | `false` | no |
| service\_label | The service label. | `string` | `""` | no |
| status | Cloud Guard status. | `string` | `"ENABLED"` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloud\_guard\_config | Cloud Guard configuration information. |
