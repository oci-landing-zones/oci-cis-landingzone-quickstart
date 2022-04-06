# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  all_cost_management_freeform_tags = {"CostCenter" : "BA23490"}
  all_compartments_freeform_tags = local.all_cost_management_freeform_tags
  all_dynamic_groups_freeform_tags = local.all_cost_management_freeform_tags
}
