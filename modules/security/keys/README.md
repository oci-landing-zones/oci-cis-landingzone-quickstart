## CIS OCI Landing Zone KMS Keys Module.

This module manages OCI KMS keys resources and IAM policies resources determining the grants over these keys.  
It manages multiple keys given in var.managed\_keys. Keys are expected to specify the grantees (service\_grantees and group\_grantees) allowed to use them.  
The module can also take a map of existing keys in var.existing\_keys to manage their IAM policies. For existing keys, the module manages one policy to each  
key, as these keys can exist in different compartments.

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
| [oci_identity_compartment](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/identity_compartment) |
| [oci_identity_policy](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_policy) |
| [oci_kms_key](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/kms_key) |
| [oci_kms_vault](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/kms_vault) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| compartment\_id | The compartment OCID where managed\_keys are created. | `string` | n/a | yes |
| defined\_tags | Map of key-value pairs of defined tags for all resources managed by this module. | `map(string)` | `null` | no |
| existing\_keys | Existing keys to manage policies for. A policy is managed for each existing key, but keys themselves are not managed. | <pre>map(object({<br>    key_id = string,<br>    compartment_id = string,<br>    service_grantees = list(string),<br>    group_grantees = list(string)<br>  }))</pre> | `{}` | no |
| freeform\_tags | Map of key-value pairs of freeform tags for all resources managed by this module. | `map(string)` | `null` | no |
| managed\_keys | The keys to manage. | <pre>map(object({<br>    vault_id = string,<br>    key_name = string,<br>    key_shape_algorithm = string,<br>    key_shape_length = string,<br>    service_grantees = list(string),<br>    group_grantees = list(string)<br>  }))</pre> | `{}` | no |
| policy\_compartment\_id | The compartment OCID where the managed\_keys policies are managed. | `string` | n/a | yes |
| policy\_name | The policy name for the managed\_keys. | `string` | `"lz-keys-policy"` | no |

## Outputs

| Name | Description |
|------|-------------|
| keys | The managed keys. |
