# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

### Route tables
resource "oci_core_route_table" "these" {
  for_each       = var.subnets_route_tables
    display_name   = each.key
    vcn_id         = each.value.vcn_id
    compartment_id = var.compartment_id
    defined_tags   = each.value.defined_tags
    freeform_tags  = each.value.freeform_tags
    dynamic "route_rules" {
      iterator = rule
      for_each = [for r in each.value.route_rules : {
        dst : r.destination
        dst_type : r.destination_type
        ntwk_entity_id : r.network_entity_id
        description : r.description
      } if r.is_create == true]
      content {
        destination       = rule.value.dst
        destination_type  = rule.value.dst_type
        network_entity_id = rule.value.ntwk_entity_id
        description       = rule.value.description
      }
    }
}
### Route Table Attachments
resource "oci_core_route_table_attachment" "these" {
  for_each = var.subnets_route_tables
    subnet_id = each.value.subnet_id
    route_table_id = oci_core_route_table.these[each.key].id
}
