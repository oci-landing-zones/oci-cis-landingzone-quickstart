locals {
  #anywhere = "0.0.0.0/0"
  osn_cidrs = { for x in data.oci_core_services.all_services.services : x.cidr_block => x.id }
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
  count          = var.is_create_igw == true ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.service_label}-Internet-Gateway"
  lifecycle {
    create_before_destroy = true
  }
}

### NAT Gateway
resource "oci_core_nat_gateway" "this" {
  count          = var.is_create_igw == true ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "${var.service_label}-NAT-Gateway"
  vcn_id         = oci_core_vcn.this.id

  block_traffic = var.block_nat_traffic

  lifecycle {
    create_before_destroy = true
  }
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

### DRG - Dynamic Routing Gateway
resource "oci_core_drg" "this" {
  count          = var.is_create_drg == true ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "${var.service_label}-DRG"

}

### DRG attachment to VCN
resource "oci_core_drg_attachment" "this" {
  count        = var.is_create_drg == true || var.is_hub_spoke ? 1 : 0
  drg_id       = var.is_create_drg == true ? oci_core_drg.this[0].id : var.drg_id
  display_name = "${var.service_label}-${var.vcn_display_name}-DRG-Attachment"
  vcn_id       = oci_core_vcn.this.id
  # network_details {
  #   id             = oci_core_vcn.this.id
  #   route_table_id = null
  #   type           = "VCN"
  # }
}

### Subnets
resource "oci_core_subnet" "these" {
  for_each                   = var.subnets
  vcn_id                     = oci_core_vcn.this.id
  cidr_block                 = each.value.cidr
  compartment_id             = each.value.compartment_id != null ? each.value.compartment_id : var.compartment_id
  defined_tags               = each.value.defined_tags
  freeform_tags              = each.value.freeform_tags
  display_name               = each.key
  prohibit_public_ip_on_vnic = each.value.private
  dns_label                  = each.value.dns_label
  dhcp_options_id            = each.value.dhcp_options_id
  route_table_id             = each.value.route_table_id
  security_list_ids          = each.value.security_list_ids
}

### Route tables
resource "oci_core_route_table" "these" {
  for_each       = var.subnets_route_tables
  display_name   = each.key
  vcn_id         = oci_core_vcn.this.id
  compartment_id = each.value.compartment_id != null ? each.value.compartment_id : var.compartment_id

  dynamic "route_rules" {
    iterator = rule
    for_each = [for r in each.value.route_rules : {
      dst : r.destination
      dst_type : r.destination_type
      ntwk_entity_id : r.network_entity_id
    } if r.is_create == true]

    content {
      destination       = rule.value.dst
      destination_type  = rule.value.dst_type
      network_entity_id = rule.value.ntwk_entity_id
    }
  }
}
