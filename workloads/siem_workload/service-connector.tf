# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  compartment_id_for_service_connector = (local.is_stream_based == true) ? var.compartment_id_for_service_connector_stream : "bla"
  sch_description                      = "This Service Connector Hub is part of the SIEM integration, sending all OCI audit logs from this region to a stream."
  service_connectors_configuration = {
    default_compartment_id : local.compartment_id_for_service_connector
    service_connectors : {
      SIEM-INTEGRATION-SERVICE-CONNECTOR : {
        display_name : "${var.service_label}-${var.name_for_service_connector_stream}"
        description : local.sch_description
        activate : true
        source : {
          kind : "logging"
          audit_logs : [
            { cmp_id : "ALL" } # "ALL" means all tenancy audit logs. Only applicable if kind = "logging".
          ]
          #non_audit_logs : [for ocid in var.compartment_id_for_logs : 
          #  {cmp_id = ocid} # Bucket logs, flow logs compartment - 
          #] 
        }
        target : {
          kind : "streaming"
          stream_id : module.vision_streams[0].streams["SIEM-INTEGRATION-STREAM"].id
        }
      }
    }
  }
}

module "vision_connector" {
  source = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-observability//service-connectors?ref=v0.1.5"
  providers = {
    oci      = oci
    oci.home = oci.home
  }
  tenancy_ocid                     = var.tenancy_ocid
  service_connectors_configuration = local.service_connectors_configuration
}
