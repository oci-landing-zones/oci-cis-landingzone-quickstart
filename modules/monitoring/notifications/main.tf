resource "oci_events_rule" "this" {
    #Required
    actions {
        #Required
        actions {
            #Required
            action_type = var.rule_actions_actions_action_type
            is_enabled  = var.rule_actions_actions_is_enabled

            #Optional
            description = var.rule_actions_actions_description
            topic_id    = var.topic_id
        }
    }
    compartment_id = var.compartment_id
    condition      = var.rule_condition
    display_name   = var.rule_display_name
    is_enabled     = var.rule_is_enabled

    #Optional
    description = var.rule_description
}