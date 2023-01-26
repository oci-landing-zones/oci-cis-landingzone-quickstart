# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This module creates a tag namespace, tags and tag defaults 
### only if tag defaults for tags in the oracle default tag namespace (typically 'Oracle-Tags') do not exist in the informed compartment.

terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

locals {
    actual_tags = {for k, v in var.tags : k => v 
                            if !contains(data.oci_identity_tag_defaults.default.tag_defaults[*].tag_definition_name,k)} 

    actual_tag_defaults = {for k, v in var.tags : k => v 
                            if v.make_tag_default == true && !contains(data.oci_identity_tag_defaults.default.tag_defaults[*].tag_definition_name,k)}                          
}

data "oci_identity_tag_namespaces" "this" {
    compartment_id = var.tag_namespace_compartment_id
    filter {
        name  = "name"
        values = [var.tag_namespace_name]
    }    
}

## Looking for the oracle default tag namespace
data "oci_identity_tag_namespaces" "oracle_default" {
    compartment_id = var.tenancy_ocid
    filter {
        name  = "name"
        values = [var.oracle_default_namespace_name]
    }    
}

data "oci_identity_tag_defaults" "default" {
    ## Looking for tag defaults for tags in the oracle default tag namespace
    compartment_id = var.tenancy_ocid
    filter {
        name = "tag_namespace_id"
        values = [length(data.oci_identity_tag_namespaces.oracle_default.tag_namespaces) > 0 ? data.oci_identity_tag_namespaces.oracle_default.tag_namespaces[0].id : "null"]
    }
}

resource "oci_identity_tag_namespace" "namespace" {
    count = var.is_create_namespace == true && length(local.actual_tags) > 0 ? 1 : 0
    compartment_id = var.tag_namespace_compartment_id
    name           = var.tag_namespace_name
    description    = var.tag_namespace_description
    defined_tags   = var.tag_namespace_defined_tags
    freeform_tags  = var.tag_namespace_freeform_tags
    is_retired     = var.is_namespace_retired
}

resource "oci_identity_tag" "these" {
    for_each = var.is_create_namespace == true && length(local.actual_tags) > 0 ? local.actual_tags : {}
        tag_namespace_id = oci_identity_tag_namespace.namespace[0].id 
        name             = each.key
        description      = each.value.tag_description
	    defined_tags     = each.value.tag_defined_tags
        is_cost_tracking = each.value.tag_is_cost_tracking
        is_retired       = each.value.tag_is_retired
}

resource "oci_identity_tag_default" "these" {
    for_each = var.is_create_namespace == true && length(local.actual_tag_defaults) > 0 ? toset(keys(local.actual_tag_defaults)) : []
        compartment_id    = var.tag_defaults_compartment_id
        tag_definition_id = oci_identity_tag.these[each.value].id                         # the tag id that has been just created
        value             = local.actual_tag_defaults[each.value].tag_default_value       # the tag default value
        is_required       = local.actual_tag_defaults[each.value].tag_default_is_required # whether the tag default value is required
}
