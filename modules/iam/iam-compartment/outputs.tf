output "compartments" {
  value = {for c in data.oci_identity_compartments.these.compartments : c.name => {name=c.name,id=c.id}}
} 