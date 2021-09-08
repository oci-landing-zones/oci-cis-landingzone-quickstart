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
| [oci_core_drg.this](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_drg) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | Compartment's OCID where VCN will be created. | `any` | n/a | yes |
| <a name="input_is_create_drg"></a> [is\_create\_drg](#input\_is\_create\_drg) | Whether a DRG is to be created. | `bool` | `false` | no |
| <a name="input_service_label"></a> [service\_label](#input\_service\_label) | A service label to be used as part of resource names. | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_drg"></a> [drg](#output\_drg) | DRG information. |
