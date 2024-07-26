# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  budgets_configuration = {
    budgets : {
      MINIMAL-CONFIG-BUDGET : {
        name : "${var.service_label}-main-budget"
        description : "Root level budget tracks spending across the tenancy"
        amount : var.budget_amount
        alert_rule : {
          threshold_value : var.budget_alert_threshold
          threshold_metric : "FORECAST"
          recipients : join(", ", [for s in var.budget_alert_email_endpoints : s])
          message : "Monthly forecasted spending is above ${var.budget_alert_threshold}% of configured budget."
        }
      }
    }
  }
}

module "budgets" {
  count                 = var.create_budget ? 1 : 0
  source                = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-governance//budgets?ref=v0.1.2" //compartments?ref=v0.1.6
  tenancy_ocid          = var.tenancy_ocid
  budgets_configuration = local.budgets_configuration
}
