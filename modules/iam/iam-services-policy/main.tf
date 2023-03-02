# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}


locals {
  cloud_guard_statements = [
    "Allow service cloudguard to read all-resources in tenancy",
    "Allow service cloudguard to use network-security-groups in tenancy"]

  vss_statements = [
    "Allow service vulnerability-scanning-service to manage instances in tenancy",
    "Allow service vulnerability-scanning-service to read compartments in tenancy",
    "Allow service vulnerability-scanning-service to read repos in tenancy",
    "Allow service vulnerability-scanning-service to read vnics in tenancy",
    "Allow service vulnerability-scanning-service to read vnic-attachments in tenancy"
  ]

  os_mgmt_statements = [
    "Allow service osms to read instances in tenancy"
  ]

  tenancy_policies = { for i in [1] : ("${var.service_label}-services-policy") => {
    compartment_id = var.tenancy_id
    name           = var.tenancy_policy_name
    description    = "Landing Zone policy for OCI services."
    statements     = concat(local.cloud_guard_statements, local.vss_statements, local.os_mgmt_statements)
    defined_tags   = var.defined_tags
    freeform_tags  = var.freeform_tags
  } if var.enable_tenancy_level_policies }  

  service_policies = merge(var.policies, local.tenancy_policies)
}

resource "oci_identity_policy" "these" {
  for_each = local.service_policies
    name           = each.value.name
    description    = each.value.description
    compartment_id = each.value.compartment_id
    statements     = each.value.statements
    defined_tags   = each.value.defined_tags
    freeform_tags  = each.value.freeform_tags
}