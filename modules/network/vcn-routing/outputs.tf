
output "subnets_route_tables" {
  description = "The managed subnets_route tables, indexed by display_name."
  value = {
    for rt in oci_core_route_table.these : 
      rt.display_name => rt
    }
} 