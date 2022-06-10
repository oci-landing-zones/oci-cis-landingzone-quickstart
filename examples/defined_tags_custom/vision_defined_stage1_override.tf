# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  tag_namespace_name    = "vision"
  all_tags = {
    ("CostCenter") = {
      tag_description         = "Tag for Cost Center."
      tag_is_cost_tracking    = true
      tag_is_retired          = false
      make_tag_default        = false
      tag_default_value       = ""
      tag_default_is_required = false
      tag_defined_tags        = null
      tag_freeform_tags       = null
    },
    ("DebitorName") = {
      tag_description         = "Tag for debitor name."
      tag_is_cost_tracking    = false
      tag_is_retired          = false
      make_tag_default        = false
      tag_default_value       = ""
      tag_default_is_required = false
      tag_defined_tags        = null
      tag_freeform_tags       = null
    },
    ("ProjectName") = {
      tag_description         = "Tag for project name."
      tag_is_cost_tracking    = false
      tag_is_retired          = false
      make_tag_default        = false
      tag_default_value       = ""
      tag_default_is_required = false
      tag_defined_tags        = null
      tag_freeform_tags       = null
    }
  }
}
