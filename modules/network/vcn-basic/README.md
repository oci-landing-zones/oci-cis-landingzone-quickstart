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
| [oci_core_drg](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_drg) |
| [oci_core_drg_attachment](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_drg_attachment) |
| [oci_core_internet_gateway](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_internet_gateway) |
| [oci_core_nat_gateway](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_nat_gateway) |
| [oci_core_route_table](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_route_table) |
| [oci_core_service_gateway](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_service_gateway) |
| [oci_core_services](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_services) |
| [oci_core_subnet](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_subnet) |
| [oci_core_vcn](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_vcn) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| block\_nat\_traffic | Whether or not to block traffic through NAT gateway. | `bool` | `false` | no |
| compartment\_id | Compartment's OCID where VCN will be created. | `any` | n/a | yes |
| is\_create\_drg | Whether a DRG is to be created. | `bool` | `false` | no |
| route\_tables | Parameters for each route table to be managed. | <pre>map(object({<br>    compartment_id = string<br>    route_rules    = list(object({<br>      is_create         = bool<br>      destination       = string,<br>      destination_type  = string,<br>      network_entity_id = string<br>    }))<br>  }))</pre> | n/a | yes |
| service\_gateway\_cidr | The OSN service cidr accessible through Service Gateway | `string` | `""` | no |
| service\_label | A service label to be used as part of resource names. | `string` | `"cis"` | no |
| subnet\_dns\_label | A DNS label prefix for the subnet, used in conjunction with the VNIC's hostname and VCN's DNS label to form a fully qualified domain name (FQDN) for each VNIC within this subnet. | `string` | `"subnet"` | no |
| subnets | Parameters for each subnet to be managed. | <pre>map(object({<br>    compartment_id    = string,<br>    defined_tags      = map(string),<br>    freeform_tags     = map(string),<br>    dynamic_cidr      = bool,<br>    cidr              = string,<br>    cidr_len          = number,<br>    cidr_num          = number,<br>    enable_dns        = bool,<br>    dns_label         = string,<br>    private           = bool,<br>    ad                = number,<br>    dhcp_options_id   = string,<br>    route_table_id    = string,<br>    security_list_ids = list(string)<br>  }))</pre> | n/a | yes |
| vcn\_cidr | A VCN covers a single, contiguous IPv4 CIDR block of your choice. | `string` | `"10.0.0.0/16"` | no |
| vcn\_display\_name | Name of Virtual Cloud Network. | `any` | n/a | yes |
| vcn\_dns\_label | A DNS label for the VCN, used in conjunction with the VNIC's hostname and subnet's DNS label to form a fully qualified domain name (FQDN) for each VNIC within this subnet. | `string` | `"vcn"` | no |

## Outputs

| Name | Description |
|------|-------------|
| all\_services | All services |
| drg | DRG information. |
| internet\_gateway | Internet Gateway information. |
| nat\_gateway | NAT Gateway information. |
| route\_tables | The managed route tables, indexed by display\_name. |
| service\_gateway | Service Gateway information. |
| subnets | The managed subnets, indexed by display\_name. |
| vcn | VCN information. |
