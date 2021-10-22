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
| [oci_budget_alert_rule.this](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/budget_alert_rule) | resource |
| [oci_budget_budget.this](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/budget_budget) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_budget_alert_recipients"></a> [budget\_alert\_recipients](#input\_budget\_alert\_recipients) | List of email recipients. | `any` | n/a | yes |
| <a name="input_budget_alert_threshold"></a> [budget\_alert\_threshold](#input\_budget\_alert\_threshold) | Budget percent threshold for alerting | `any` | n/a | yes |
| <a name="input_budget_amount"></a> [budget\_amount](#input\_budget\_amount) | Budget Amount | `any` | n/a | yes |
| <a name="input_budget_description"></a> [budget\_description](#input\_budget\_description) | Budget Description | `any` | n/a | yes |
| <a name="input_budget_display_name"></a> [budget\_display\_name](#input\_budget\_display\_name) | Budget Display Name | `any` | n/a | yes |
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | Compartment's OCID where VCN will be created. | `any` | n/a | yes |
| <a name="input_service_label"></a> [service\_label](#input\_service\_label) | A service label to be used as part of resource names. | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_budget"></a> [budget](#output\_budget) | Budget information. |
<!-- END_TF_DOCS -->