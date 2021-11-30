# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


locals {
  
      ### Cost Management
      budget_display_name = "${var.service_label}-main-budget"
      budget_description  = var.use_enclosing_compartment == true ? "Tracks spending from the enclosing compartment level and down" : "Tracks spending across the tenancy"

      budget_config  = var.create_budget == true ? {
        (local.budget_display_name) = {
              tenancy_id                = var.tenancy_ocid
              budget_description        = local.budget_description
              budget_display_name       = local.budget_display_name
              compartment_id            = local.parent_compartment_id
              service_label             = var.service_label
              budget_alert_threshold    = var.budget_alert_threshold
              budget_amount             = var.budget_amount
              defined_tags              = {} 
              freeform_tags             = {}
              budget_alert_recipients   = join(", ", [for s in var.budget_alert_email_endpoints : s])
              } 
          } : {}
     
      }

module "lz_cost_budget" {
      source      = "../modules/cost/budget"
      budget      = local.budget_config
}


