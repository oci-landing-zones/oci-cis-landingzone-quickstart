module "cis_security_topic" {
  source                        = "../modules/monitoring/topics"
  compartment_id                 = data.terraform_remote_state.iam.outputs.security_compartment_id
  notification_topic_name        = "${var.service_label}-SecurityTopic"
  notification_topic_description = "Topic for security related notifications."
  subscriptions = {
    s1 = {protocol = "EMAIL", endpoint = var.security_admin_email_endpoint},

    ### Examples of other subscription methods. ***ORACLE_FUNCTIONS not yet supported***
    /* 
    s2 = {protocol = "CUSTOM_HTTPS", endpoint = "https://www.oracle.com"},
    s3 = {protocol = "CUSTOM_HTTPS", endpoint = "https://www.google.com"}
    s4 = {protocol = "PAGER_DUTY", endpoint = "https://your.pagerduty.endpoint.url"}
    s5 = {protocol = "SLACK", endpoint = "https://your.slack.endpoint.url"}
    s6 = {protocol = "ORACLE_FUNCTIONS", function_compartment_name = "", application_name = "", function_name = ""} 
    */
  }
}

module "cis_network_topic" {
  source                        = "../modules/monitoring/topics"
  compartment_id                 = data.terraform_remote_state.iam.outputs.security_compartment_id
  notification_topic_name        = "${var.service_label}-NetworkTopic"
  notification_topic_description = "Topic for network related notifications."

  subscriptions = {
    s1 = {protocol = "EMAIL", endpoint = var.network_admin_email_endpoint},

    ### Examples of other subscription methods. ***ORACLE_FUNCTIONS not yet supported***
    /* 
    s2 = {protocol = "CUSTOM_HTTPS", endpoint = "https://www.oracle.com"},
    s3 = {protocol = "CUSTOM_HTTPS", endpoint = "https://www.google.com"}
    s4 = {protocol = "PAGER_DUTY", endpoint = "https://your.pagerduty.endpoint.url"}
    s5 = {protocol = "SLACK", endpoint = "https://your.slack.endpoint.url"}
    s6 = {protocol = "ORACLE_FUNCTIONS", function_compartment_name = "", application_name = "", function_name = ""} 
    */
  }
}