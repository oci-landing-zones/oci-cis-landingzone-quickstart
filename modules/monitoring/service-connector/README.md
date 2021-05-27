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
| [oci_sch_service_connector.this](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/sch_service_connector) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_service_connector"></a> [service\_connector](#input\_service\_connector) | Details of the Service Connector to be created | <pre>object ({<br>        compartment_id  = string,<br>        service_connector_display_name = string,<br>        service_connector_source_kind  = string,<br>        service_connector_state = string,<br>        log_sources = list(object({<br>            compartment_id = string,<br>            log_group_id   = string,<br>            log_id         = string<br>        })),<br>        target = object({<br>            target_kind             = string,<br>            compartment_id             = string,<br>            batch_rollover_size_in_mbs = string,<br>            batch_rollover_time_in_ms  = string,<br>            object_store_details = object({<br>                namespace = string,<br>                bucket_name = string,<br>                object_name_prefix = string<br>            }),<br>            stream_id = string,<br>            function_id = string<br>        })<br>    })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_connector"></a> [service\_connector](#output\_service\_connector) | service connector information |
