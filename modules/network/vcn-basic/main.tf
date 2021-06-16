locals {
  osn_cidrs = {for x in data.oci_core_services.all_services.services : x.cidr_block => x.id}

  subnets = flatten([
    for k, v in var.vcns : [
      for k1, v1 in v.subnets : {
        vcn_name        = k 
        display_name    = k1
        cidr            = v1.cidr
        compartment_id  = v1.compartment_id != null ? v1.compartment_id : var.compartment_id
        private         = v1.private
        dns_label       = v1.dns_label
        dhcp_options_id = v1.dhcp_options_id
        defined_tags    = v1.defined_tags
      }
    ]
  ])
}

data "oci_core_services" "all_services" {
}

### VCN
resource "oci_core_vcn" "these" {
  for_each = var.vcns
    display_name   = each.key
    dns_label      = each.value.dns_label
    cidr_block     = each.value.cidr
    compartment_id = each.value.compartment_id
}

### Internet Gateway
resource "oci_core_internet_gateway" "these" {
  for_each = {for k, v in var.vcns: k => v if v.is_create_igw == true}
    compartment_id = each.value.compartment_id
    vcn_id         = oci_core_vcn.these[each.key].id
    display_name   = "${each.key}-igw"
}

### NAT Gateway
resource "oci_core_nat_gateway" "these" {
  for_each = {for k, v in var.vcns: k => v if v.is_create_igw == true}
    compartment_id = each.value.compartment_id
    display_name  = "${each.key}-natgw"
    vcn_id        = oci_core_vcn.these[each.key].id
    block_traffic = each.value.block_nat_traffic
}

### Service Gateway
resource "oci_core_service_gateway" "these" {
  for_each = var.vcns
    compartment_id = each.value.compartment_id
    display_name   = "${each.key}-sgw"
    vcn_id         = oci_core_vcn.these[each.key].id
    services {
      service_id = local.osn_cidrs[var.service_gateway_cidr]
    }
}

### DRG - Dynamic Routing Gateway
resource "oci_core_drg" "this" {
  count          = var.is_create_drg == true ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "${var.service_label}-drg"
}

### DRG attachment to VCN
resource "oci_core_drg_attachment" "these" {
  for_each = {for k, v in var.vcns: k => v if v.is_attach_drg == true}
    drg_id       = var.drg_id == null ? oci_core_drg.this[0].id : var.drg_id
    vcn_id       = oci_core_vcn.these[each.key].id
    display_name = "${each.key}-drg-attachment"
}

### Subnets
resource "oci_core_subnet" "these" {
  for_each = {for subnet in local.subnets : "${subnet.vcn_name}.${subnet.display_name}" => subnet}
    display_name                = each.value.display_name
    vcn_id                      = oci_core_vcn.these[each.value.vcn_name].id
    cidr_block                  = each.value.cidr
    compartment_id              = each.value.compartment_id
    prohibit_public_ip_on_vnic  = each.value.private
    dns_label                   = each.value.dns_label
    dhcp_options_id             = each.value.dhcp_options_id
    defined_tags                = each.value.defined_tags
}
