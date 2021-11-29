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
| [oci_ons_subscription.these](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/ons_subscription) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_subscriptions"></a> [subscriptions](#input\_subscriptions) | n/a | <pre>map(object({<br>    compartment_id  = string<br>    topic_id        = string <br>    protocol        = string<br>    endpoint        = string<br>    defined_tags    = map(string)<br>    freeform_tags   = map(string)<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_subscriptions"></a> [subscriptions](#output\_subscriptions) | The subscriptions, indexed by ID. |
