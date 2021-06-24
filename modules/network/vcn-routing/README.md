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
| [oci_core_route_table.these](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_route_table) | resource |
| [oci_core_route_table_attachment.these](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_route_table_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | Compartment OCID. | `string` | n/a | yes |
| <a name="input_subnets_route_tables"></a> [subnets\_route\_tables](#input\_subnets\_route\_tables) | Subnet Route Tables | <pre>map(object({<br>    compartment_id    = string,<br>    vcn_id            = string,<br>    subnet_id         = string,<br>    route_rules = list(object({<br>      is_create         = bool<br>      destination       = string<br>      destination_type  = string<br>      network_entity_id = string<br>      description       = string<br>    }))<br>    defined_tags      = map(string)<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_subnets_route_tables"></a> [subnets\_route\_tables](#output\_subnets\_route\_tables) | The managed subnets\_route tables, indexed by display\_name. |
