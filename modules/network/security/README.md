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
| [oci_core_network_security_group.these](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group) | resource |
| [oci_core_network_security_group_security_rule.egress](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.ingress](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_security_list.these](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_security_list) | resource |
| [oci_core_network_security_groups.these](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_network_security_groups) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_anywhere_cidr"></a> [anywhere\_cidr](#input\_anywhere\_cidr) | n/a | `string` | `"0.0.0.0/0"` | no |
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | The compartment ocid to create resources. | `string` | n/a | yes |
| <a name="input_nsgs"></a> [nsgs](#input\_nsgs) | Parameters for customizing Network Security Group(s). | <pre>map(object({<br>    vcn_id        = string,<br>    ingress_rules = map(object({<br>      is_create    = bool<br>      description  = string<br>      protocol     = string,<br>      stateless    = bool,<br>      src          = string,<br>      src_type     = string,<br>      dst_port_min = number,<br>      dst_port_max = number,<br>      src_port_min = number,<br>      src_port_max = number,<br>      icmp_type    = number,<br>      icmp_code    = number<br>    })),<br>    egress_rules = map(object({<br>      is_create    = bool<br>      description  = string<br>      protocol     = string,<br>      stateless    = bool,<br>      dst          = string,<br>      dst_type     = string,<br>      dst_port_min = number,<br>      dst_port_max = number,<br>      src_port_min = number,<br>      src_port_max = number,<br>      icmp_type    = number,<br>      icmp_code    = number<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_ports_not_allowed_from_anywhere_cidr"></a> [ports\_not\_allowed\_from\_anywhere\_cidr](#input\_ports\_not\_allowed\_from\_anywhere\_cidr) | n/a | `list(number)` | <pre>[<br>  22,<br>  3389<br>]</pre> | no |
| <a name="input_security_lists"></a> [security\_lists](#input\_security\_lists) | Parameters for customizing Security List(s). | <pre>map(object({<br>    vcn_id          = string,<br>    compartment_id  = string,<br>    defined_tags    = map(string),<br>    ingress_rules   = list(object({<br>      stateless     = bool,<br>      protocol      = string,<br>      src           = string,<br>      src_type      = string,<br>      src_port      = object({<br>        min         = number,<br>        max         = number<br>      }),<br>      dst_port      = object({<br>        min         = number,<br>        max         = number<br>      }),<br>      icmp_type     = number,<br>      icmp_code     = number<br>    })),<br>    egress_rules    = list(object({<br>      stateless     = bool,<br>      protocol      = string,<br>      dst           = string,<br>      dst_type      = string,<br>      src_port      = object({<br>        min         = number,<br>        max         = number<br>      }),<br>      dst_port      = object({<br>        min         = number,<br>        max         = number<br>      }),<br>      icmp_type     = number,<br>      icmp_code     = number<br>    }))<br>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nsgs"></a> [nsgs](#output\_nsgs) | he Network Security Group(s) (NSGs) created/managed. Indexed by display\_name |
| <a name="output_security_lists"></a> [security\_lists](#output\_security\_lists) | The security list(s) created/managed. |
