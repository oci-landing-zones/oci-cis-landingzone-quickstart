### VCN
resource "oci_core_vcn" "this" {
  dns_label      = var.vcn_dns_label
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_ocid
  display_name   = var.vcn_display_name
}

### Internet Gateway
resource "oci_core_internet_gateway" "this" {
  count          = var.vcn_internet_connected ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.service_label}-Internet-Gateway"
}


### Internet Route Table
resource "oci_core_route_table" "internet" {
  count          = var.vcn_internet_connected ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "${var.service_label}-Internet-Route"
  vcn_id         = oci_core_vcn.this.id
  
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.this[0].id
  }
}