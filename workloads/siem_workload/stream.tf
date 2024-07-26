# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  is_stream_based = contains(local.stream_integrations, var.integration_type)
  streams_configuration = {
    default_compartment_id : var.compartment_id_for_stream
    streams : {
      SIEM-INTEGRATION-STREAM = {
        name : "${var.service_label}-${var.name_for_stream}"
        stream_pool_id         = "SIEM-INTEGRATION-STREAM-POOL"
        num_partitions         = var.stream_partitions_count
        log_retention_in_hours = var.stream_retention_in_hours
      }
    }
    stream_pools = {
      SIEM-INTEGRATION-STREAM-POOL = {
        name           = "${var.service_label}-${var.name_for_stream}-pool"
        compartment_id = var.compartment_id_for_stream
        #kms_key_id = "<REPLACE-BY-VAULT-KEY-OCID>"
      }
      #kafka_settings = {
      #  auto_create_topics_enabled = true
      #  bootstrap_servers = null
      #  log_retention_in_hours = 24
      #  num_partitions = 1
      #}
    }
  }
}

module "vision_streams" {
  source                = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-observability//streams?ref=v0.1.5" //compartments?ref=v0.1.6
  count                 = local.is_stream_based == true ? 1 : 0
  streams_configuration = local.streams_configuration
}
