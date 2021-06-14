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
| [oci_vulnerability_scanning_host_scan_recipe](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/vulnerability_scanning_host_scan_recipe) |
| [oci_vulnerability_scanning_host_scan_target](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/vulnerability_scanning_host_scan_target) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| scan\_recipes | n/a | <pre>map(object({<br>    compartment_id                                = string,<br>    agent_scan_level                              = string,<br>    agent_configuration_vendor                    = string,<br>    agent_cis_benchmark_settings_scan_level       = string,<br>    port_scan_level                               = string,<br>    schedule_type                                 = string,<br>    schedule_day_of_week                          = string,<br>    defined_tags                                  = map(string)<br>  }))</pre> | n/a | yes |
| scan\_targets | n/a | <pre>map(object({<br>    compartment_id        = string,<br>    description           = string,<br>    scan_recipe_name      = string,<br>    target_compartment_id = string,<br>    defined_tags          = map(string)<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| vss\_recipes | VSS recipes, indexed by recipe name. |
| vss\_targets | VSS targets, indexed by target name. |
