# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

resource oci_budget_budget these {
  for_each = var.budget
    amount                                = each.value.budget_amount
    budget_processing_period_start_offset = "1"
    compartment_id                        = each.value.tenancy_id
    description                           = each.value.budget_description
    defined_tags                          = each.value.defined_tags
    freeform_tags                         = each.value.freeform_tags
    display_name                          = each.key
    reset_period                          = "MONTHLY"
    target_type                           = "COMPARTMENT"
    targets = [
      each.value.compartment_id,
    ]
}



resource oci_budget_alert_rule these {
  for_each = var.budget
    budget_id       = oci_budget_budget.these[each.key].id
    display_name    = "${each.value.service_label}-alert-on-forecasted-spent"
    defined_tags    = each.value.defined_tags
    freeform_tags   = each.value.freeform_tags
    #message = ""
    recipients      = each.value.budget_alert_recipients
    threshold       = each.value.budget_alert_threshold
    threshold_type  = "PERCENTAGE"
    type            = "FORECAST"
}
