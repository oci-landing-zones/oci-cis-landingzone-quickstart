# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "terraform_data" "validate_html_notification_email" {
  count = local.html_report_notification_enabled ? 1 : 0
  input = local.html_report_notification_email

  lifecycle {
    precondition {
      condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", local.html_report_notification_email))
      error_message = "notification_email must be provided as a valid email address when HTML report notifications are enabled."
    }
  }
}

resource "oci_ons_notification_topic" "html_reports" {
  count = local.html_report_notification_enabled ? 1 : 0

  compartment_id = local.function_compartment_ocid
  name           = local.html_report_notification_topic_name
  description    = "Notifications for generated OCI CIS HTML report objects."
}

resource "oci_ons_subscription" "html_reports_email" {
  count = local.html_report_notification_enabled ? 1 : 0

  compartment_id = local.function_compartment_ocid
  topic_id       = oci_ons_notification_topic.html_reports[0].id
  protocol       = "EMAIL"
  endpoint       = local.html_report_notification_email

  depends_on = [terraform_data.validate_html_notification_email]
}
