output "vcn" {
  description = "VCN information."
  value       = oci_core_vcn.this
}

output "internet_gateway" {
  description = "Internet Gateway information."
  value       = oci_core_internet_gateway.this
}

output "nat_gateway" {
  description = "NAT Gateway information."
  value       = oci_core_nat_gateway.this
}

output "service_gateway" {
  description = "Service Gateway information."
  value       = oci_core_service_gateway.this
}

output "drg" {
  description = "DRG information."
  value       = length(oci_core_drg.this) > 0 ? oci_core_drg.this[0] : null
}

output "subnets" {
  description = "The managed subnets, indexed by display_name."
  value = (oci_core_subnet.these != null && length(oci_core_subnet.these) > 0) ? {
    for s in oci_core_subnet.these : 
      s.display_name => {display_name = s.display_name, id = s.id}
    } : null
}

output "route_tables" {
  description = "The managed route tables, indexed by display_name."
  value = (oci_core_route_table.these != null && length(oci_core_route_table.these) > 0) ? {
    for rt in oci_core_route_table.these : 
      rt.display_name => rt
    } : null
}

output "all_services" {
  description = "All services"
  value       = data.oci_core_services.all_services
}