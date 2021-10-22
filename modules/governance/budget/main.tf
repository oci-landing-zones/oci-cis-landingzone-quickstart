# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource oci_budget_budget this {
  amount                                = var.budget_amount
  budget_processing_period_start_offset = "1"
  compartment_id                        = var.tenancy_id
  description  = var.budget_description
  display_name = var.budget_display_name
  reset_period = "MONTHLY"
  target_type  = "COMPARTMENT"
  targets = [
    var.compartment_id,
  ]
}

resource oci_budget_alert_rule this {
  budget_id = oci_budget_budget.this.id
  display_name = "${var.service_label}-alertonforecastbreach"
  #message = <<Optional value not found in discovery>>
  recipients     = var.budget_alert_recipients
  threshold      = var.budget_alert_threshold
  threshold_type = "PERCENTAGE"
  type           = "FORECAST"
}
