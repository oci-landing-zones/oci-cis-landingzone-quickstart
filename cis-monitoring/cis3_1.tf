resource "oci_audit_configuration" "this" {
    compartment_id = var.tenancy_ocid
    retention_period_days = 365
}    