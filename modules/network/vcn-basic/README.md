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
| [oci_core_drg_attachment.these](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_drg_attachment) | resource |
| [oci_core_internet_gateway.these](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_internet_gateway) | resource |
| [oci_core_nat_gateway.these](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_nat_gateway) | resource |
| [oci_core_service_gateway.these](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_service_gateway) | resource |
| [oci_core_subnet.these](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_subnet) | resource |
| [oci_core_vcn.these](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_vcn) | resource |
| [oci_core_services.all_services](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_services) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | Compartment's OCID where VCN will be created. | `any` | n/a | yes |
| <a name="input_drg_id"></a> [drg\_id](#input\_drg\_id) | DRG to be attached | `string` | `null` | no |
| <a name="input_is_create_drg"></a> [is\_create\_drg](#input\_is\_create\_drg) | Whether a DRG is to be created. | `bool` | `false` | no |
| <a name="input_service_gateway_cidr"></a> [service\_gateway\_cidr](#input\_service\_gateway\_cidr) | The OSN service cidr accessible through Service Gateway | `string` | n/a | yes |
| <a name="input_service_label"></a> [service\_label](#input\_service\_label) | A service label to be used as part of resource names. | `any` | n/a | yes |
| <a name="input_vcns"></a> [vcns](#input\_vcns) | The VCNs. | <pre>map(object({<br>    compartment_id    = string,<br>    cidr              = string,<br>    dns_label         = string,<br>    is_create_igw     = bool,<br>    is_attach_drg     = bool,<br>    block_nat_traffic = bool,<br>    subnets           = map(object({<br>      compartment_id    = string,<br>      cidr              = string,<br>      dns_label         = string,<br>      private           = bool,<br>      dhcp_options_id   = string,<br>      defined_tags      = map(string)<br>    })),<br>    defined_tags      = map(string)<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_all_services"></a> [all\_services](#output\_all\_services) | All services |
| <a name="output_drg"></a> [drg](#output\_drg) | DRG information. |
| <a name="output_internet_gateways"></a> [internet\_gateways](#output\_internet\_gateways) | The Internet gateways, indexed by display\_name. |
| <a name="output_nat_gateways"></a> [nat\_gateways](#output\_nat\_gateways) | The NAT gateways, indexed by display\_name. |
| <a name="output_service_gateways"></a> [service\_gateways](#output\_service\_gateways) | The Service gateways, indexed by display\_name. |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | The subnets, indexed by display\_name. |
| <a name="output_vcns"></a> [vcns](#output\_vcns) | The VCNs, indexed by display\_name. |
