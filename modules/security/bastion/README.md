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
| [oci_bastion_bastion](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/bastion_bastion) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bastions | Details of the Bastion resources to be created. | <pre>map(object({<br>      name = string,<br>      compartment_id = string,<br>      target_subnet_id = string,<br>      client_cidr_block_allow_list = list(string),<br>      max_session_ttl_in_seconds = number,<br>      defined_tags = map(string),<br>      freeform_tags = map(string)<br>    }))</pre> | n/a | yes |

## Outputs

No output.
