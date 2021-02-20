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
| [oci_identity_group](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/identity_group) |
| [oci_identity_user_group_membership](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/identity_user_group_membership) |
| [oci_identity_users](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/identity_users) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| group\_description | The description you assign to the Group. Does not have to be unique, and it's changeable. | `string` | `""` | no |
| group\_name | The name you assign to the group during creation. The name must be unique across all compartments in the tenancy. | `any` | n/a | yes |
| tenancy\_ocid | The OCID of the tenancy. | `any` | n/a | yes |
| user\_names | List of user names. | `list` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| group\_id | n/a |
| group\_name | n/a |
