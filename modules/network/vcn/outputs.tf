output "vcn_id" {
  description = "ocid of created VCN. "
  value       = oci_core_vcn.this.id
}

output "default_security_list_id" {
  description = "ocid of default security list. "
  value       = oci_core_vcn.this.default_security_list_id
}

output "default_dhcp_options_id" {
  description = "ocid of default DHCP options. "
  value       = oci_core_vcn.this.default_dhcp_options_id
}

output "internet_gateway_id" {
  description = "ocid of Internet gateway."
  value       = oci_core_internet_gateway.this.id
}

output "nat_gateway_id" {
  description = "ocid of NAT gateway."
  value       = oci_core_nat_gateway.this.id
}

output "service_gateway_id" {
  description = "ocid of Service gateway."
  value       = oci_core_service_gateway.this.id
}

output "drg_id" {
  description = "DRG's ocid."
  value       = length(oci_core_drg.this) > 0 ? oci_core_drg.this[0].id : null
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