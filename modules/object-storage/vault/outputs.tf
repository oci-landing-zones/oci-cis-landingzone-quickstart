
output "key_id" {
  description = "Custmer Managed Key ID"
  value       = oci_kms_key.this.id
}