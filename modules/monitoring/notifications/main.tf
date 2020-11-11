# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_events_rule" "this" {
    actions {
        actions {
            action_type = var.rule_actions_actions_action_type
            is_enabled  = var.rule_actions_actions_is_enabled

            description = var.rule_actions_actions_description
            topic_id    = var.topic_id
        }
    }
    compartment_id = var.compartment_id
    condition      = var.rule_condition
    display_name   = var.rule_display_name
    is_enabled     = var.rule_is_enabled

    description = var.rule_description
}