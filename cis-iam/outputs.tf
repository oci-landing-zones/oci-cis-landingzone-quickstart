/*
output "policies" {
  description = "List of all policies in the tenancy."
  value = { 
    
    for x in data.oci_identity_policies.all.policies : x.name => 
      { name           = x.name,
        compartment_id = x.compartment_id,
      #  defined_tags   = x.defined_tags,
      #  description    = x.description,
      #  freeform_tags  = x.freeform_tags,
      #  id             = x.id,
        state          = x.state,
        statements     = x.statements,
      #  time_created   = x.time_created,
      #  version_date   = x.version_date
    }

  } 
}
*/