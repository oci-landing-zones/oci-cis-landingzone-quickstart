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
| [oci_core_network_security_group](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group) |
| [oci_core_network_security_group_security_rule](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group_security_rule) |
| [oci_core_network_security_groups](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_network_security_groups) |
| [oci_core_security_list](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_security_list) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| anywhere\_cidr | n/a | `string` | `"0.0.0.0/0"` | no |
| default\_compartment\_id | The default compartment OCID to use for resources (unless otherwise specified). | `string` | `""` | no |
| default\_defined\_tags | The different defined tags that are applied to each object by default. | `map(string)` | `{}` | no |
| default\_freeform\_tags | The different freeform tags that are applied to each object by default. | `map(string)` | `{}` | no |
| default\_security\_list\_id | The id of the default security list. | `string` | `""` | no |
| nsgs | Parameters for customizing Network Security Group(s). | <pre>map(object({<br>    compartment_id  = string,<br>    defined_tags    = map(string),<br>    freeform_tags   = map(string),<br>    ingress_rules   = list(object({<br>      description   = string,<br>      stateless     = bool,<br>      protocol      = string,<br>      src           = string,<br>      # Allowed values: CIDR_BLOCK, SERVICE_CIDR_BLOCK, NETWORK_SECURITY_GROUP, NSG_NAME<br>      src_type      = string,<br>      src_port      = object({<br>        min         = number,<br>        max         = number<br>      }),<br>      dst_port      = object({<br>        min         = number,<br>        max         = number<br>      }),<br>      icmp_type     = number,<br>      icmp_code     = number<br>    })),<br>    egress_rules    = list(object({<br>      description   = string,<br>      stateless     = bool,<br>      protocol      = string,<br>      dst           = string,<br>      # Allowed values: CIDR_BLOCK, SERVICE_CIDR_BLOCK, NETWORK_SECURITY_GROUP, NSG_NAME<br>      dst_type      = string,<br>      src_port      = object({<br>        min         = number,<br>        max         = number<br>      }),<br>      dst_port      = object({<br>        min         = number,<br>        max         = number<br>      }),<br>      icmp_type     = number,<br>      icmp_code     = number<br>    }))<br>  }))</pre> | `{}` | no |
| ports\_not\_allowed\_from\_anywhere\_cidr | n/a | `list(number)` | <pre>[<br>  22,<br>  3389<br>]</pre> | no |
| security\_lists | Parameters for customizing Security List(s). | <pre>map(object({<br>    compartment_id  = string,<br>    defined_tags    = map(string),<br>    freeform_tags   = map(string),<br>    ingress_rules   = list(object({<br>      stateless     = bool,<br>      protocol      = string,<br>      src           = string,<br>      src_type      = string,<br>      src_port      = object({<br>        min         = number,<br>        max         = number<br>      }),<br>      dst_port      = object({<br>        min         = number,<br>        max         = number<br>      }),<br>      icmp_type     = number,<br>      icmp_code     = number<br>    })),<br>    egress_rules    = list(object({<br>      stateless     = bool,<br>      protocol      = string,<br>      dst           = string,<br>      dst_type      = string,<br>      src_port      = object({<br>        min         = number,<br>        max         = number<br>      }),<br>      dst_port      = object({<br>        min         = number,<br>        max         = number<br>      }),<br>      icmp_type     = number,<br>      icmp_code     = number<br>    }))<br>  }))</pre> | `{}` | no |
| standalone\_nsg\_rules | Any standalone NSG rules that should be added (whether or not the NSG is defined here). | <pre>object({<br>    ingress_rules   = list(object({<br>      nsg_id        = string,<br>      description   = string,<br>      stateless     = bool,<br>      protocol      = string,<br>      src           = string,<br>      # Allowed values: CIDR_BLOCK, SERVICE_CIDR_BLOCK, NETWORK_SECURITY_GROUP, NSG_NAME<br>      src_type      = string,<br>      src_port      = object({<br>        min         = number,<br>        max         = number<br>      }),<br>      dst_port      = object({<br>        min         = number,<br>        max         = number<br>      }),<br>      icmp_type     = number,<br>      icmp_code     = number<br>    })),<br>    egress_rules    = list(object({<br>      nsg_id        = string,<br>      description   = string,<br>      stateless     = bool,<br>      protocol      = string,<br>      dst           = string,<br>      # Allowed values: CIDR_BLOCK, SERVICE_CIDR_BLOCK, NETWORK_SECURITY_GROUP, NSG_NAME<br>      dst_type      = string,<br>      src_port      = object({<br>        min         = number,<br>        max         = number<br>      }),<br>      dst_port      = object({<br>        min         = number,<br>        max         = number<br>      }),<br>      icmp_type     = number,<br>      icmp_code     = number<br>    }))<br>  })</pre> | <pre>{<br>  "egress_rules": [],<br>  "ingress_rules": []<br>}</pre> | no |
| vcn\_cidr | The vcn cidr block. | `string` | `""` | no |
| vcn\_id | The VCN id where the Security List(s) should be created. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| nsg\_egress\_rules | The egress NSG rules created/managed. |
| nsg\_ingress\_rules | The ingress NSG rules created/managed. |
| nsg\_rules | The NSG rules created/managed. |
| nsgs | The Network Security Group(s) (NSGs) created/managed. |
| security\_lists | The security list(s) created/managed. |
