output "compartments" {
  value = {for c in data.oci_identity_compartments.these.compartments : c.name => c}
} 