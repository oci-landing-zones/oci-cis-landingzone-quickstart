locals {
     
    cg_events_configuration = {

    default_compartment_id = var.compartment_id_for_cg_events !=null ? var.compartment_id_for_cg_events : var.tenancy_ocid

    event_rules = {
      CLOUDGUARD-EVENTS-KEY = {
        event_display_name              = "${var.service_label}-notify-on-cloudguard-events-rule"
        preconfigured_events_categories = ["cloudguard"]
        destination_topic_ids           = ["CLOUDGUARD-TOPIC-KEY"]
        attributes_filter               = [{attr="riskLevel", value=["CRITICAL","HIGH"]}]
      }
    }

    topics = {
      CLOUDGUARD-TOPIC-KEY = {
        name        = "${var.service_label}-cloudguard-topic"
        description = "Topic for Cloud Guard related notifications."
        subscriptions = [
          { protocol = "EMAIL"
            values   = var.cloudguard_email_endpoints
          }
        ]
      }
    }
  }
} 

module "workload_cg_events" {
  count = var.configure_cloud_guard ? 1 : 0 
  source = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-observability//events?ref=v0.1.5" //compartments?ref=v0.1.6
  providers = { oci = oci.home }
  events_configuration = local.cg_events_configuration
}