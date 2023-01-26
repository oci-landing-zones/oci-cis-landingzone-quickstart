# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

## Network Security Group(s) - NSGs
locals {
  nsgs = { for nsg in oci_core_network_security_group.these : nsg.display_name => nsg }
  ingress_rules = flatten([
    for nsg, nsg_val in var.nsgs : [
      for irule, irule_val in nsg_val.ingress_rules : {
        nsg_name     = nsg
        nsg_id       = local.nsgs[nsg].id
        rule_name    = irule
        description  = irule_val.description
        stateless    = irule_val.stateless
        protocol     = irule_val.protocol
        src          = irule_val.src
        src_type     = irule_val.src_type
        src_port_min = irule_val.src_port_min
        src_port_max = irule_val.src_port_max
        dst_port_min = irule_val.dst_port_min
        dst_port_max = irule_val.dst_port_max
        icmp_type    = irule_val.icmp_type
        icmp_code    = irule_val.icmp_code
      } if irule_val.is_create == true
    ]
  ])
  egress_rules = flatten([
    for nsg, nsg_val in var.nsgs : [
      for erule, erule_val in nsg_val.egress_rules : {
        nsg_name     = nsg
        nsg_id       = local.nsgs[nsg].id
        rule_name    = erule
        description  = erule_val.description
        stateless    = erule_val.stateless
        protocol     = erule_val.protocol
        dst          = erule_val.dst
        dst_type     = erule_val.dst_type
        src_port_min = erule_val.src_port_min
        src_port_max = erule_val.src_port_max
        dst_port_min = erule_val.dst_port_min
        dst_port_max = erule_val.dst_port_max
        icmp_type    = erule_val.icmp_type
        icmp_code    = erule_val.icmp_code
      } if erule_val.is_create == true
    ]
  ])
}

resource "oci_core_network_security_group" "these" {
  for_each = var.nsgs
    compartment_id = var.compartment_id
    vcn_id         = each.value.vcn_id
    display_name   = each.key
    defined_tags   = each.value.defined_tags
    freeform_tags  = each.value.freeform_tags
}

data "oci_core_network_security_groups" "these" {
  for_each = var.nsgs
    compartment_id = var.compartment_id
    vcn_id         = each.value.vcn_id
}

locals {
  local_nsg_ids  = { for i in oci_core_network_security_group.these : i.display_name => i.id }
  remote_nsg_ids = { for k,v in var.nsgs : k => [for i in data.oci_core_network_security_groups.these[k].network_security_groups : i.id] if contains(keys(data.oci_core_network_security_groups.these),k)}
  nsg_ids        = merge(local.remote_nsg_ids, local.local_nsg_ids)
}


resource "oci_core_network_security_group_security_rule" "ingress" {
  for_each = {
    for rule in local.ingress_rules : "${rule.nsg_name}.${rule.rule_name}" => rule
  }
  network_security_group_id = each.value.nsg_id
  direction                 = "INGRESS"
  protocol                  = each.value.protocol

  description = each.value.description
  source      = each.value.src_type != "NSG_NAME" ? each.value.src : local.nsg_ids[each.value.src]
  source_type = each.value.src_type != "NSG_NAME" ? each.value.src_type : "NETWORK_SECURITY_GROUP"
  stateless   = each.value.stateless

  dynamic "tcp_options" {
    for_each = each.value.protocol == "6" ? [1] : []
    content {
      dynamic "destination_port_range" {
        for_each = each.value.dst_port_min != null && each.value.dst_port_max != null ? [1] : []
        content {
          max = each.value.dst_port_max
          min = each.value.dst_port_min
        }
      }
      dynamic "source_port_range" {
        for_each = each.value.src_port_min != null && each.value.src_port_max != null ? [1] : []
        content {
          max = each.value.src_port_max
          min = each.value.src_port_min
        }
      }
    }
  }

  dynamic "icmp_options" {
    for_each = each.value.protocol == "1" && each.value.icmp_type != null ? [1] : []
    content {
      type = each.value.icmp_type
      code = each.value.icmp_code
    }
  }

  dynamic "udp_options" {
    for_each = each.value.protocol == "17" ? [1] : []
    content {
      dynamic "destination_port_range" {
        for_each = each.value.dst_port_min != null && each.value.dst_port_max != null ? [1] : []
        content {
          max = each.value.dst_port_max
          min = each.value.dst_port_min
        }
      }
      dynamic "source_port_range" {
        for_each = each.value.src_port_min != null && each.value.src_port_max != null ? [1] : []
        content {
          max = each.value.src_port_max
          min = each.value.src_port_min
        }
      }
    }
  }
}

resource "oci_core_network_security_group_security_rule" "egress" {
  for_each = {
    for rule in local.egress_rules : "${rule.nsg_name}.${rule.rule_name}" => rule
  }
  network_security_group_id = each.value.nsg_id
  direction                 = "EGRESS"
  protocol                  = each.value.protocol

  description = each.value.description

  destination      = each.value.dst_type != "NSG_NAME" ? each.value.dst : local.nsg_ids[each.value.dst]
  destination_type = each.value.dst_type != "NSG_NAME" ? each.value.dst_type : "NETWORK_SECURITY_GROUP"
  stateless        = each.value.stateless
  dynamic "tcp_options" {
    for_each = each.value.protocol == "6" ? [1] : []
    content {
      dynamic "destination_port_range" {
        for_each = each.value.dst_port_min != null && each.value.dst_port_max != null ? [1] : []
        content {
          max = each.value.dst_port_max
          min = each.value.dst_port_min
        }
      }
      dynamic "source_port_range" {
        for_each = each.value.src_port_min != null && each.value.src_port_max != null ? [1] : []
        content {
          max = each.value.src_port_max
          min = each.value.src_port_min
        }
      }
    }
  }

  dynamic "icmp_options" {
    for_each = each.value.protocol == "1" && each.value.icmp_type != null ? [1] : []
    content {
      type = each.value.icmp_type
      code = each.value.icmp_code
    }
  }

  dynamic "udp_options" {
    for_each = each.value.protocol == "17" ? [1] : []
    content {
      dynamic "destination_port_range" {
        for_each = each.value.dst_port_min != null && each.value.dst_port_max != null ? [1] : []
        content {
          max = each.value.dst_port_max
          min = each.value.dst_port_min
        }
      }
      dynamic "source_port_range" {
        for_each = each.value.src_port_min != null && each.value.src_port_max != null ? [1] : []
        content {
          max = each.value.src_port_max
          min = each.value.src_port_min
        }
      }
    }
  }
}
