<!-- BEGIN_TF_DOCS -->
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
| [oci_budget_alert_rule.these](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/budget_alert_rule) | resource |
| [oci_budget_budget.these](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/budget_budget) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_budget"></a> [budget](#input\_budget) | n/a | <pre>map(object({<br>        tenancy_id                = string<br>        budget_description        = string<br>        budget_display_name       = string<br>        compartment_id            = string<br>        service_label             = string<br>        budget_alert_threshold    = string<br>        budget_amount             = number<br>        defined_tags              = map(string)<br>        freeform_tags             = map(string)<br>        budget_alert_recipients   = string<br>    }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_budget"></a> [budget](#output\_budget) | Budget information. |
<!-- END_TF_DOCS -->