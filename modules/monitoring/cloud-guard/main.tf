# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# CloudGuard enabling and disabling is a tenant-level operation 
resource "oci_cloud_guard_cloud_guard_configuration" "this" {
  #Required
  compartment_id   = var.compartment_id
  reporting_region = var.reporting_region
  status           = var.status

  #Optional
  self_manage_resources = var.self_manage_resources
}

resource  "oci_identity_policy" "this" {
    name           = "${var.service_label}-CloudGuardAccess-Policy"
    compartment_id = var.compartment_id
    description    = "Policy for Cloud Guard to be able to review a tenancy"
    statements     = [
        "allow service cloudguard to read keys in tenancy",
        "allow service cloudguard to read compartments in tenancy",
        "allow service cloudguard to read tenancies in tenancy",
        "allow service cloudguard to read audit-events in tenancy",
        "allow service cloudguard to read compute-management-family in tenancy",
        "allow service cloudguard to read instance-family in tenancy",
        "allow service cloudguard to read virtual-network-family in tenancy",
        "allow service cloudguard to read volume-family in tenancy",
        "allow service cloudguard to read database-family in tenancy",
        "allow service cloudguard to read object-family in tenancy",
        "allow service cloudguard to read load-balancers in tenancy",
        "allow service cloudguard to read users in tenancy",
        "allow service cloudguard to read groups in tenancy",
        "allow service cloudguard to read policies in tenancy",
        "allow service cloudguard to read dynamic-groups in tenancy",
        "allow service cloudguard to read authentication-policies in tenancy",
        "allow service cloudguard to use network-security-groups in tenancy"
    ]
}