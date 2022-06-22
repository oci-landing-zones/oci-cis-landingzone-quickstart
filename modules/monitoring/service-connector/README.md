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
| [oci_sch_service_connector](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/sch_service_connector) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| service\_connector | Details of the Service Connector to be created | <pre>object ({<br>        compartment_id  = string,<br>        defined_tags = map(string),<br>        freeform_tags = map(string),<br>        service_connector_display_name = string,<br>        service_connector_source_kind  = string,<br>        service_connector_state = string,<br>        log_sources = list(object({<br>            compartment_id = string,<br>            log_group_id   = string,<br>            log_id         = string<br>        })),<br>        target = object({<br>            target_kind             = string,<br>            compartment_id             = string,<br>            object_store_details = object({<br>                namespace = string,<br>                bucket_name = string,<br>                object_name_prefix = string,<br>                batch_rollover_size_in_mbs = number,<br>                batch_rollover_time_in_ms  = number<br>            }),<br>            stream_id = string,<br>            function_id = string<br>        })<br>    })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| service\_connector | service connector information |
