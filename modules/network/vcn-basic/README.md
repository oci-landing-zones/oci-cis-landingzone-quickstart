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
| [oci_core_default_security_list](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_default_security_list) |
| [oci_core_drg_attachment](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_drg_attachment) |
| [oci_core_internet_gateway](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_internet_gateway) |
| [oci_core_nat_gateway](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_nat_gateway) |
| [oci_core_security_list](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_security_list) |
| [oci_core_service_gateway](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_service_gateway) |
| [oci_core_services](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_services) |
| [oci_core_subnet](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_subnet) |
| [oci_core_vcn](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_vcn) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| compartment\_id | Compartment's OCID where VCN will be created. | `any` | n/a | yes |
| drg\_id | DRG to be attached | `string` | `null` | no |
| service\_gateway\_cidr | The OSN service cidr accessible through Service Gateway | `string` | n/a | yes |
| service\_label | A service label to be used as part of resource names. | `any` | n/a | yes |
| vcns | The VCNs. | <pre>map(object({<br>    compartment_id    = string,<br>    cidr              = string,<br>    dns_label         = string,<br>    is_create_igw     = bool,<br>    is_attach_drg     = bool,<br>    block_nat_traffic = bool,<br>    defined_tags      = map(string),<br>    freeform_tags     = map(string),<br>    subnets = map(object({<br>      compartment_id    = string,<br>      name              = string,<br>      cidr              = string,<br>      dns_label         = string,<br>      private           = bool,<br>      dhcp_options_id   = string,<br>      defined_tags      = map(string),<br>      freeform_tags     = map(string),<br>      security_lists    = map(object({<br>        is_create      = bool,<br>        compartment_id = string,<br>        defined_tags   = map(string),<br>        freeform_tags  = map(string),<br>        ingress_rules  = list(object({<br>          is_create    = bool,<br>          stateless    = bool,<br>          protocol     = string,<br>          description  = string,<br>          src          = string,<br>          src_type     = string,<br>          src_port_min = number,<br>          src_port_max = number,<br>          dst_port_min = number,<br>          dst_port_max = number,<br>          icmp_type    = number,<br>          icmp_code    = number<br>        })),<br>        egress_rules = list(object({<br>          is_create    = bool,<br>          stateless    = bool,<br>          protocol     = string,<br>          description  = string,<br>          dst          = string,<br>          dst_type     = string,<br>          src_port_min = number,<br>          src_port_max = number,<br>          dst_port_min = number,<br>          dst_port_max = number,<br>          icmp_type    = number,<br>          icmp_code    = number<br>        }))<br>      }))<br>    }))<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| all\_services | All services |
| internet\_gateways | The Internet gateways, indexed by display\_name. |
| nat\_gateways | The NAT gateways, indexed by display\_name. |
| security\_lists | All Network Security Lists |
| service\_gateways | The Service gateways, indexed by display\_name. |
| subnets | The subnets, indexed by display\_name. |
| vcns | The VCNs, indexed by display\_name. |
