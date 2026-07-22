# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_core_vcn" "this" {
  count          = var.deploy_infra_for_subnet ? 1 : 0
  cidr_blocks    = [var.new_vcn_cidr]
  display_name   = var.new_vcn_name
  compartment_id = local.function_vcn_compartment_ocid
}

resource "oci_core_subnet" "this" {
  count                      = var.deploy_infra_for_subnet ? 1 : 0
  vcn_id                     = oci_core_vcn.this[0].id
  cidr_block                 = var.new_subnet_cidr
  display_name               = var.new_subnet_name
  compartment_id             = local.function_vcn_compartment_ocid
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.this[0].id
  security_list_ids          = [oci_core_security_list.this[0].id]
}

resource "oci_core_security_list" "this" {
  count          = var.deploy_infra_for_subnet ? 1 : 0
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${var.new_vcn_name}-security-list"
  compartment_id = local.function_vcn_compartment_ocid
  egress_security_rules {
    protocol         = "all"
    destination      = "all-${local.region_key}-services-in-oracle-services-network"
    destination_type = "SERVICE_CIDR_BLOCK"
  }
  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }
}

resource "oci_core_nat_gateway" "this" {
  count          = var.deploy_infra_for_subnet ? 1 : 0
  compartment_id = local.function_vcn_compartment_ocid
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${var.new_vcn_name}-nat-gateway"
}

resource "oci_core_service_gateway" "this" {
  count          = var.deploy_infra_for_subnet ? 1 : 0
  compartment_id = local.function_vcn_compartment_ocid
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${var.new_vcn_name}-service-gateway"
  services {
    service_id = local.osn_cidrs["all-${local.region_key}-services-in-oracle-services-network"]
  }
}

resource "oci_core_route_table" "this" {
  count          = var.deploy_infra_for_subnet ? 1 : 0
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${var.new_vcn_name}-private-subnet-route-table"
  compartment_id = local.function_vcn_compartment_ocid

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.this[0].id
  }
  route_rules {
    destination       = "all-${local.region_key}-services-in-oracle-services-network"
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.this[0].id
  }
}
