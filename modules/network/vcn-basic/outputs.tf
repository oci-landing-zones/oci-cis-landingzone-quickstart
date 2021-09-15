# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "vcns" {
  description = "The VCNs, indexed by display_name."
  value       = { for v in oci_core_vcn.these : v.display_name => { id = v.id, cidr_block = v.cidr_block, dns_label = v.dns_label, default_security_list_id = v.default_security_list_id } }
}
output "subnets" {
  description = "The subnets, indexed by display_name."
  value       = { for s in oci_core_subnet.these : s.display_name => s }
}
output "internet_gateways" {
  description = "The Internet gateways, indexed by display_name."
  value       = { for g in oci_core_internet_gateway.these : g.vcn_id => g }
}
output "nat_gateways" {
  description = "The NAT gateways, indexed by display_name."
  value       = { for g in oci_core_nat_gateway.these : g.vcn_id => g }
}
output "service_gateways" {
  description = "The Service gateways, indexed by display_name."
  value       = { for g in oci_core_service_gateway.these : g.vcn_id => g }
}
output "all_services" {
  description = "All services"
  value       = data.oci_core_services.all_services
}

output "security_lists" {
  description = "All Network Security Lists"
  value       = { for sl in oci_core_security_list.these : sl.display_name => sl }
}