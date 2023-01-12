# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_objectstorage_namespace" "this" {
  provider = oci
  compartment_id = var.tenancy_id
}

data "oci_log_analytics_namespaces" "these" {
  compartment_id = var.tenancy_id
}

#-- This effectively enables Logging Analytics for the tenancy (or onboards the tenancy with Logging Analytics service).
resource "oci_log_analytics_namespace" "this" {
  count        = data.oci_log_analytics_namespaces.these.namespace_collection[0].items[0].is_onboarded ? 0 : 1
  namespace    = data.oci_objectstorage_namespace.this.namespace
  is_onboarded = true
  compartment_id = var.tenancy_id
}

resource "oci_log_analytics_log_analytics_log_group" "this" {
  compartment_id = var.log_group_compartment_id
  display_name   = var.log_group_name
  namespace      = data.oci_log_analytics_namespaces.these.namespace_collection[0].items[0].is_onboarded ? data.oci_log_analytics_namespaces.these.namespace_collection[0].items[0].namespace : oci_log_analytics_namespace.this[0].namespace
  description    = "CIS Landing Zone log group for Logging Analytics."
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
}