# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  ### Discovering the home region name and region key.
  home_region_key = data.oci_identity_tenancy.this.home_region_key # Home region key obtained from the tenancy data source

  ### Discover tenancy name
  tenancy_name = data.oci_identity_tenancy.this.name
  ### Discovering the home region name and region key.
  regions_map         = { for r in data.oci_identity_regions.these.regions : r.key => r.name } # All regions indexed by region key.
  regions_map_reverse = { for r in data.oci_identity_regions.these.regions : r.name => r.key } # All regions indexed by region name.
  region_key          = lower(local.regions_map_reverse[var.region])                           # Region key obtained from the region name

  #List of Stream-based integration
  stream_integrations = ["Splunk", "Stellar Cyber", "Generic Stream-based"]

  # Outputs display
  #display_outputs = true

  # SIEM Specific Information
  splunk_integration_info = "Stream OCID:${module.vision_streams[0].streams.SIEM-INTEGRATION-STREAM.id}\nStream Endpoint:${module.vision_streams[0].streams.SIEM-INTEGRATION-STREAM.messages_endpoint}\nOCI Region:${var.region}\nTenancy OCID:${var.tenancy_ocid}"
  splunk_doc_link         = "https://github.com/splunk/Splunk-Addon-for-OCI/tree/main/README"
  splunk_steps            = (var.create_iam_resources_stream == false || var.homeregion == false) ? "1. Ensure IAM requirements have been meet.\n2. Continue with the Splunk App configuration using: ${local.splunk_doc_link}\n3. Repeat the Integration for all subscribed regions." : var.access_method_stream == "API Signing Key" ? "1. Create an OCI User in the default Identity Domain\n2. Create an API Key and collect the Private Key and Fingerprint.\n3. Add the user to the ${local.groups_configuration.groups.STREAM-READ-GROUP.name} group.\n4. Continue with the Splunk App configuration using: https://github.com/splunk/Splunk-Addon-for-OCI/tree/main/README\n5. Repeat the integration for all subscribed regions." : "1. Continue with the Splunk App configuration using: https://github.com/splunk/Splunk-Addon-for-OCI/tree/main/README\n2. Repeat the Integration for all subscribed regions."
  splunk_next_steps       = "Your OCI resources have been provisioned.\nPlease follow the below steps:\n${local.splunk_steps}\n\nOCI specific details:\n${local.splunk_integration_info}\n\nSIEM integration doc:${local.splunk_doc_link}"

  generic_stream_doc_link = "https://github.com/oracle-quickstart/oci-self-service-security-guide/tree/main/1-Logging-Monitoring-and-Alerting"


  stellar_cyber_integration_info = "Bootstrap Server:${module.vision_streams[0].stream_pools.SIEM-INTEGRATION-STREAM-POOL.kafka_settings[0].bootstrap_servers}\nUsername:${local.tenancy_name}/<your_OCI_username>/${module.vision_streams[0].stream_pools.SIEM-INTEGRATION-STREAM-POOL.id}\nStream Name:${module.vision_streams[0].streams.SIEM-INTEGRATION-STREAM.name}"
  stellar_cyber_doc_link         = "https://docs.stellarcyber.ai/prod-docs/4.3.x/Configure/Connectors/Oracle-Cloud-Infra-Connectors.htm"
  stellar_cyber_steps            = (var.create_iam_resources_stream == false || var.homeregion == false) ? "1. Ensure IAM requirements have been meet.\n2. Continue with the Stellar Cyber configuration using: ${local.stellar_cyber_doc_link}\n3. Repeat the Integration for all subscribed regions." : "1. Create an OCI User in the default Identity Domain\n2. Create an Auth Token.\n3. Add the user to the ${local.groups_configuration.groups.STREAM-READ-GROUP.name} group.\n4. Continue with the Stellar Cyber configuration using: ${local.stellar_cyber_doc_link}\n5. Repeat the integration for all subscribed regions."
  stellar_cyber_next_steps       = "Your OCI resources have been provisioned.\nPlease the follow below steps:\n${local.stellar_cyber_steps}\n\nOCI specific details:\n${local.stellar_cyber_integration_info}\n\nSIEM integration doc:${local.stellar_cyber_doc_link}"

  resource_location = var.tenancy_ocid == var.compartment_id_for_stream ? "tenancy" : "compartment id ${var.compartment_id_for_stream}"
  siem_info = {
    "Splunk" = {
      doc_link                      = local.splunk_doc_link
      next_steps                    = local.splunk_next_steps
      iam_policy_api_key            = "allow group ${local.groups_configuration.groups.STREAM-READ-GROUP.name} to use stream-pull in ${local.resource_location} where all {target.stream.id='${module.vision_streams[0].streams.SIEM-INTEGRATION-STREAM.id}'}"
      iam_policy_instance_principal = "allow dynamic-group ${local.dynamic_groups_configuration.dynamic_groups.STREAM-READ-DYN-GROUP.name} to use stream-pull in ${local.resource_location} where all {target.stream.id='${module.vision_streams[0].streams.SIEM-INTEGRATION-STREAM.id}'}"
    }
    "Stellar Cyber" = {
      doc_link           = local.stellar_cyber_doc_link
      next_steps         = local.stellar_cyber_next_steps
      iam_policy_api_key = "allow group ${local.groups_configuration.groups.STREAM-READ-GROUP.name} to use stream-pull in ${local.resource_location} where all {target.stream.id='${module.vision_streams[0].streams.SIEM-INTEGRATION-STREAM.id}'}"
    }
    "Generic Stream-based" = {
      doc_link           = local.generic_stream_doc_link
      next_steps         = "Next steps not defined for generic stream integration."
      iam_policy_api_key = "allow group ${local.groups_configuration.groups.STREAM-READ-GROUP.name} to use stream-pull in ${local.resource_location} where all {target.stream.id='${module.vision_streams[0].streams.SIEM-INTEGRATION-STREAM.id}'}"
    }
  }

}


