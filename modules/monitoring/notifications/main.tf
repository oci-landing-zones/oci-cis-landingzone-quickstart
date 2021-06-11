# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

/* resource "oci_events_rule" "this" {
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
} */

resource "oci_events_rule" "these" {
  for_each = var.rules
    actions {
        actions {
            action_type = each.value.actions_action_type
            is_enabled  = each.value.actions_is_enabled

            description = each.value.actions_description
            topic_id    = each.value.topic_id
        }
    }
    compartment_id = each.value.compartment_id
    condition      = each.value.condition
    display_name   = each.key
    is_enabled     = each.value.is_enabled
    description    = each.value.description
    defined_tags   = each.value.defined_tags
}