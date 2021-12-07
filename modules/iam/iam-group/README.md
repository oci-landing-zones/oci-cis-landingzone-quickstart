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
| groups | Group parameters | <pre>map(object({<br>    description  = string,<br>    user_ids     = list(string),<br>    defined_tags = map(string),<br>    freeform_tags = map(string),<br>  }))</pre> | n/a | yes |
| tenancy\_ocid | The OCID of the tenancy. | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| groups | n/a |
| memberships | n/a |
