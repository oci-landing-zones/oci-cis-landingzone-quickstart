# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_audit_configuration" "this" {
    compartment_id = var.tenancy_ocid
    retention_period_days = 365
}    