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
| [oci_monitoring_alarm](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/monitoring_alarm#destinations) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| Alarms | Alarms | <pre>map(object({<br>    compartment_id      = string,<br>    destinations         = list(string),<br>    display_name           = string,<br>    is_enabled          = bool,<br>    metric_compartment_id = string,<br>    namespace  = string,<br>    query = string,<br>    severity            = string<br>,    defined_tags            = map(string)<br>,    freeform_tags          = map(string)<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| none | none |
