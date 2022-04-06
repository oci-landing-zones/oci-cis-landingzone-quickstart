# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  all_alarms_defined_tags = {
    "vision.CostCenter" = "42",
    "vision.ProjectName" = "The Project"
  }
  all_buckets_defined_tags = local.all_alarm_defined_tags
  all_compartments_defined_tags = local.all_alarm_defined_tags
  all_cost_management_defined_tags = local.all_alarm_defined_tags
  all_dmz_defined_tags = local.all_alarm_defined_tags
  all_dynamic_groups_defined_tags = local.all_alarm_defined_tags
  all_exacs_vcns_defined_tags = local.all_alarm_defined_tags
  all_flow_logs_defined_tags = local.all_alarm_defined_tags
  all_groups_defined_tags = local.all_alarm_defined_tags
  all_keys_defined_tags = local.all_alarm_defined_tags
  all_notifications_defined_tags = local.all_alarm_defined_tags
  all_nsgs_defined_tags = local.all_alarm_defined_tags
  all_service_connector_defined_tags = local.all_alarm_defined_tags
  all_service_policy_defined_tags = local.all_alarm_defined_tags
  all_tags_defined_tags = local.all_alarm_defined_tags
  all_topics_defined_tags = local.all_alarm_defined_tags
  all_vcn_defined_tags = local.all_alarm_defined_tags
  all_vss_defined_tags = local.all_alarm_defined_tags
}
