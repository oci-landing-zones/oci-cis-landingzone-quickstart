# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

#---------------------------------------
# Input variable
#---------------------------------------

locals {

  events_configuration = {
    default_compartment_id = var.compartment_id_for_net_events != null ? var.compartment_id_for_net_events : var.tenancy_ocid

    event_rules = {
      NETWORK-EVENTS-KEY = {
        event_display_name              = "${var.service_label}-notify-on-network-changes-rule"
        event_description               = "CIS related events around network change."
        preconfigured_events_categories = ["network"] # this defines the set of event rules that are configured
        destination_topic_ids           = ["NETWORK-TOPIC-KEY"]

      }
    }

    topics = {
      NETWORK-TOPIC-KEY = {
        name        = "${var.service_label}-network-topic"
        description = "Topic for network related notifications."
        subscriptions = [
          { protocol = "EMAIL"
            values   = var.network_admin_email_endpoints
          }
        ]
      }

    }
  }

  home_region_events_configuration = {

    default_compartment_id = var.compartment_id_for_iam_events != null ? var.compartment_id_for_iam_events : var.tenancy_ocid

    event_rules = {
      IAM-EVENTS-KEY = {
        event_display_name              = "${var.service_label}-notify-on-iam-changes-rule"
        preconfigured_events_categories = ["iam"] # this defines the set of event rules that are configured
        destination_topic_ids           = ["IAM-TOPIC-KEY"]
      }
    }

    topics = {
      IAM-TOPIC-KEY = {
        name        = "${var.service_label}-iam-topic"
        description = "Topic for security related notifications."
        subscriptions = [
          { protocol = "EMAIL"
            values   = var.security_admin_email_endpoints
          }
        ]
      }
    }
  }
}

module "workload_events" {
  count                = var.enable_net_events ? 1 : 0
  source               = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-observability//events?ref=v0.1.5" //compartments?ref=v0.1.6
  events_configuration = local.events_configuration
}

module "workload_home_region_events" {
  count                = var.enable_iam_events ? 1 : 0
  source               = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-observability//events?ref=v0.1.5" //compartments?ref=v0.1.6
  providers            = { oci = oci.home }
  events_configuration = local.home_region_events_configuration
}
