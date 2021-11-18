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
| [oci_ons_notification_topic.these](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/ons_notification_topic) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_topics"></a> [topics](#input\_topics) | n/a | <pre>map(object({<br>     compartment_id   = string<br>     name             = string<br>     description      = string<br>     defined_tags     = map(string)<br>     freeform_tags    = map(string)<br>    }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_topics"></a> [topics](#output\_topics) | The topcs, indexed by keys in var.topics. |
