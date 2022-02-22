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
| [oci_ons_notification_topic](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/ons_notification_topic) |
| [oci_ons_subscription](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/ons_subscription) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| compartment\_id | The default compartment OCID to use for resources (unless otherwise specified). | `string` | `""` | no |
| defined\_tags | Map of key-value pairs of defined tags. | `map(string)` | null | no |
| freeform\_tags | Map of key-value pairs of freeform tags. | `map(string)` | null | no |
| notification\_topic\_description | The notification topic description. | `string` | `""` | no |
| notification\_topic\_name | The notification topic name. | `string` | `""` | no |
| subscriptions | n/a | <pre>map(object({<br>    protocol = string<br>    endpoint = string<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| subscriptions | The topic subscriptions. |
| topic | Topic information. |
