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
| [oci_bastion_bastion.this](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/bastion_bastion) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bastion"></a> [bastion](#input\_bastion) | Details of the Bastion resource to be created | <pre>object ({<br>        name = string,<br>        compartment_id = string,<br>        target_subnet_id = string,<br>        client_cidr_block_allow_list = list(string),<br>        max_session_ttl_in_seconds = number<br>    })</pre> | n/a | yes |

## Outputs

No outputs.
