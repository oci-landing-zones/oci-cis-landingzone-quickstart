// Copyright (c) 2017, 2020, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Mozilla Public License v2.0


variable "cloud_guard_configuration_status" {
  default = "ENABLED"
}

//Setting this variable to true lets the user seed the oracle managed entities with minimal changes to the original entities.
//False will delegate this responsibility to CloudGuard for seeding the oracle managed entities.
variable "cloud_guard_configuration_self_manage_resources" {
  default = false
}

//CloudGuard enabling and disabling is a tenant-level operation 
resource "oci_cloud_guard_cloud_guard_configuration" "test_cloud_guard_configuration" {
  #Required
  compartment_id   = var.tenancy_ocid
  reporting_region = var.region
  status           = var.cloud_guard_configuration_status

  #Optional
  self_manage_resources = var.cloud_guard_configuration_self_manage_resources
}

resource  "oci_identity_policy" "Cloud_Guard_Access_Policy" {
    name = "${var.service_label}-CloudGuardAccess-Policy"
    compartment_id = var.tenancy_ocid
    description = "Policy for Cloud Guard to be able to review a tenancy"
  statements = [
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