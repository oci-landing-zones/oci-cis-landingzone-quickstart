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
| compartment\_id | The default compartment OCID to use for resources (unless otherwise specified). | `string` | `""` | no |
| rule\_actions\_actions\_action\_type | The action to perform if the condition in the rule matches an event. | `string` | `""` | no |
| rule\_actions\_actions\_description | A string that describes the details of the action. | `string` | `""` | no |
| rule\_actions\_actions\_is\_enabled | Whether or not the action is enabled. | `bool` | `true` | no |
| rule\_condition | The rule condition. | `string` | `""` | no |
| rule\_description | The rule description. | `string` | `""` | no |
| rule\_display\_name | The rule display name. | `string` | `""` | no |
| rule\_is\_enabled | Whether or not the rule is enabled. | `bool` | `true` | no |
| topic\_id | The topic id to send the notification to. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| rule | Rule information. |
