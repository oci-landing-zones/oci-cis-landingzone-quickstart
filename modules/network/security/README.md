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
| [oci_core_network_security_group_security_rule](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group_security_rule) |
| [oci_core_network_security_group](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group) |
| [oci_core_network_security_groups](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_network_security_groups) |
| [oci_core_security_list](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_security_list) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| anywhere\_cidr | n/a | `string` | `"0.0.0.0/0"` | no |
| compartment\_id | The compartment ocid to create resources. | `string` | n/a | yes |
| nsgs | Parameters for customizing Network Security Group(s). | <pre>map(object({<br>    vcn_id        = string,<br>    ingress_rules = map(object({<br>      is_create    = bool<br>      description  = string<br>      protocol     = string,<br>      stateless    = bool,<br>      src          = string,<br>      src_type     = string,<br>      dst_port_min = number,<br>      dst_port_max = number,<br>      src_port_min = number,<br>      src_port_max = number,<br>      icmp_type    = number,<br>      icmp_code    = number<br>    })),<br>    egress_rules = map(object({<br>      is_create    = bool<br>      description  = string<br>      protocol     = string,<br>      stateless    = bool,<br>      dst          = string,<br>      dst_type     = string,<br>      dst_port_min = number,<br>      dst_port_max = number,<br>      src_port_min = number,<br>      src_port_max = number,<br>      icmp_type    = number,<br>      icmp_code    = number<br>    }))<br>  }))</pre> | `{}` | no |
| ports\_not\_allowed\_from\_anywhere\_cidr | n/a | `list(number)` | <pre>[<br>  22,<br>  3389<br>]</pre> | no |
| security\_lists | Parameters for customizing Security List(s). | <pre>map(object({<br>    vcn_id          = string,<br>    compartment_id  = string,<br>    defined_tags    = map(string),<br>    freeform_tags   = map(string),<br>    ingress_rules   = list(object({<br>      stateless     = bool,<br>      protocol      = string,<br>      src           = string,<br>      src_type      = string,<br>      src_port      = object({<br>        min         = number,<br>        max         = number<br>      }),<br>      dst_port      = object({<br>        min         = number,<br>        max         = number<br>      }),<br>      icmp_type     = number,<br>      icmp_code     = number<br>    })),<br>    egress_rules    = list(object({<br>      stateless     = bool,<br>      protocol      = string,<br>      dst           = string,<br>      dst_type      = string,<br>      src_port      = object({<br>        min         = number,<br>        max         = number<br>      }),<br>      dst_port      = object({<br>        min         = number,<br>        max         = number<br>      }),<br>      icmp_type     = number,<br>      icmp_code     = number<br>    }))<br>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| nsgs | he Network Security Group(s) (NSGs) created/managed. Indexed by display\_name |
| security\_lists | The security list(s) created/managed. |
