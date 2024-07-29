locals {

  alarms_configuration = {
    default_compartment_id = var.compartment_id_for_alarms != null ? var.compartment_id_for_alarms : var.tenancy_ocid

    alarms = {
      NETWORK-ALARM-VPN-STATUS-KEY = {
        compartment_id           = var.compartment_id_for_alarms
        display_name             = "${var.service_label}-vpn-status-alarm"
        preconfigured_alarm_type = "vpn-status-alarm"
        destination_topic_ids    = ["ALARMS-TOPIC-KEY"]
      }
      NETWORK-ALARM-FAST-CONNECT-STATUS-KEY = {
        compartment_id           = var.compartment_id_for_alarms
        display_name             = "${var.service_label}-fast-connect-status-alarm"
        preconfigured_alarm_type = "fast-connect-status-alarm"
        destination_topic_ids    = ["ALARMS-TOPIC-KEY"]
      }
    }
    topics = {
      ALARMS-TOPIC-KEY = {
        compartment_id = var.compartment_id_for_alarms
        name           = "${var.service_label}-network-alarms-topic"
        subscriptions = [
          { protocol = "EMAIL"
            values   = var.alarms_admin_email_endpoints
          }
        ]
      }
    }
  }
}

module "alarms_configuration" {
  count                = var.create_alarms_as_enabled ? 1 : 0
  source               = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-observability//alarms?ref=v0.1.5" //compartments?ref=v0.1.6
  alarms_configuration = local.alarms_configuration
}
