
module "lz_budget" {
  count                   = var.create_budget == true ? 1 : 0
  source                  = "../modules/governance/budget"
  budget_amount           = var.budget_amount
  budget_description      = local.budget_description
  budget_display_name     = local.budget_display_name
  compartment_id          = local.parent_compartment_id 
  service_label           = var.service_label
  budget_alert_recipients = join(", ", [for s in var.governance_admin_email_endpoints : s])
  budget_alert_threshold  = var.budget_alert_threshold
}


