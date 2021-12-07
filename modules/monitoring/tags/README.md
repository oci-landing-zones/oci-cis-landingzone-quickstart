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
| [oci_identity_tag_default](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/identity_tag_default) |
| [oci_identity_tag_defaults](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/identity_tag_defaults) |
| [oci_identity_tag_namespace](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/identity_tag_namespace) |
| [oci_identity_tag_namespaces](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/identity_tag_namespaces) |
| [oci_identity_tag](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/identity_tag) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| is\_namespace\_retired | Whether or not the namespace is retired | `string` | `false` | no |
| oracle\_default\_namespace\_name | The Oracle default tag namespace name | `string` | `"Oracle-Tags"` | no |
| tag\_defaults\_compartment\_id | The default compartment ocid for tag defaults. | `string` | `""` | no |
| tag\_namespace\_compartment\_id | The default compartment ocid for tag namespace. | `string` | `""` | no |
| tag\_namespace\_description | The tag namespace description | `string` | `""` | no |
| tag\_namespace\_defined\_tags | Map of key-value pairs of defined tags. | `map(string)` | null | no |
| tag\_namespace\_freeform\_tags | Map of key-value pairs of freeform tags. | `map(string)` | nul| tag\_namespace\_name | The tag namespace name | `string` | `""` | no |
| tags | n/a | <pre>map(object({<br>    tag_description         = string,<br>    tag_is_cost_tracking    = bool,<br>    tag_is_retired          = bool,<br>    make_tag_default        = bool,<br>    tag_default_value       = string,<br>    tag_default_is_required = bool<br>  }))</pre> | n/a | yes |
| tenancy\_ocid | The tenancy ocid. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| custom\_tag\_namespace\_name | n/a |
| custom\_tags | n/a |
