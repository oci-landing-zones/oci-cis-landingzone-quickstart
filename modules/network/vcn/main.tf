locals {
  anywhere = "0.0.0.0/0"
  osn_cidrs = {for x in data.oci_core_services.all_services.services : x.cidr_block => x.id}
}

data "oci_core_services" "all_services" {
}

### VCN
resource "oci_core_vcn" "this" {
  dns_label      = var.vcn_dns_label
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_id
  display_name   = var.vcn_display_name
}

### Internet Gateway
resource "oci_core_internet_gateway" "this" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.service_label}-Internet-Gateway"
}

### NAT Gateway
resource "oci_core_nat_gateway" "this" {
    compartment_id = var.compartment_id
    display_name  = "${var.service_label}-NAT-Gateway"
    vcn_id         = oci_core_vcn.this.id

    block_traffic = var.block_nat_traffic
}

### Service Gateway
resource "oci_core_service_gateway" "this" {
    compartment_id = var.compartment_id
    display_name   = "${var.service_label}-Service-Gateway"
    vcn_id         = oci_core_vcn.this.id
    services {
      service_id = local.osn_cidrs[var.service_gateway_cidr]
    }
}

### Internet Route Table
resource "oci_core_route_table" "internet" {
  compartment_id = var.compartment_id
  display_name   = "${var.service_label}-Internet-Route"
  vcn_id         = oci_core_vcn.this.id
  
  route_rules {
    destination       = local.anywhere
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.this.id
  }
}

### Private Subnet Route Table
resource "oci_core_route_table" "private_subnet" {
  compartment_id = var.compartment_id
  display_name   = "${var.service_label}-Private-Subnet-Route"
  vcn_id         = oci_core_vcn.this.id
  
  route_rules {
    destination       = var.service_gateway_cidr
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.this.id
  } 

  route_rules {
    destination       = local.anywhere
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.this.id
  }

}