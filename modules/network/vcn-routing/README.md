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
| [oci_core_route_table_attachment](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_route_table_attachment) |
| [oci_core_route_table](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_route_table) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| compartment\_id | Compartment OCID. | `string` | n/a | yes |
| subnets\_route\_tables | Subnet Route Tables | <pre>map(object({<br>    compartment_id    = string,<br>    vcn_id            = string,<br>    subnet_id         = string,<br>    route_rules = list(object({<br>      is_create         = bool<br>      destination       = string<br>      destination_type  = string<br>      network_entity_id = string<br>      description       = string<br>    }))<br>    defined_tags      = map(string)<br>    freeform_tags     = map(string)<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| subnets\_route\_tables | The managed subnets\_route tables, indexed by display\_name. |
