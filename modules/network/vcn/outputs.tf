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

output "internet_route_table_id" {
  description = "ocid of default route table. "
  value       = oci_core_route_table.internet[0].id
}

output "internet_gateway_id" {
  description = "ocid of internet gateway. "
  value       = oci_core_internet_gateway.this[0].id
}