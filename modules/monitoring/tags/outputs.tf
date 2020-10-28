output "default_tags" {
  description = "Oracle default tags"
  value       = data.oci_identity_tag_defaults.tag_defaults
}