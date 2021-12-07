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
| [oci_events_rule](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/events_rule) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| rules | Rules parameters | <pre>map(object({<br>    compartment_id      = string,<br>    description         = string,<br>    condition           = string,<br>    is_enabled          = bool,<br>    actions_action_type = string,<br>    actions_is_enabled  = bool,<br>    actions_description = string,<br>    topic_id            = string,<br>    defined_tags        = map(string)<br>    freeform_defined_tags       = map(string)<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| rules | Events rules |
