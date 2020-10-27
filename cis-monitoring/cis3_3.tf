module "cis_topics" {
  source                        = "../modules/monitoring/topics"
  compartment_id                 = var.tenancy_ocid
  notification_topic_name        = "${var.service_label}-topic"
  notification_topic_description = "Topic for ${var.service_label} service."
  subscription_protocol          = "EMAIL"
  subscription_endpoint          = "andre.correa@oracle.com"
}  