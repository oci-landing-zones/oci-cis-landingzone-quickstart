# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  osn_cidrs = { for x in data.oci_core_services.all_services.services : x.cidr_block => x.id }

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
        security_lists  = v1.security_lists
      }
    ]
  ])
  security_lists = flatten([
    for k, v in local.subnets : [
      for k1, v1 in v.security_lists : {
        vcn_name       = v.vcn_name
        subnet_name    = v.display_name
        sec_list_name  = k1
        compartment_id = v.compartment_id != null ? v.compartment_id : var.compartment_id
        defined_tags   = v1.defined_tags
        freeform_tags  = v1.freeform_tags
        ingress_rules  = v1.ingress_rules
        egress_rules   = v1.egress_rules
      } if v1.is_create
    ]

  ])

  default_security_list_opt = {
    display_name   = "unnamed"
    compartment_id = null
    ingress_rules  = []
    egress_rules   = []
  }

}

data "oci_core_services" "all_services" {
}

### VCN
resource "oci_core_vcn" "these" {
  for_each       = var.vcns
  display_name   = each.key
  dns_label      = each.value.dns_label
  cidr_block     = each.value.cidr
  compartment_id = each.value.compartment_id
}

### Internet Gateway
resource "oci_core_internet_gateway" "these" {
  for_each       = { for k, v in var.vcns : k => v if v.is_create_igw == true }
  compartment_id = each.value.compartment_id
  vcn_id         = oci_core_vcn.these[each.key].id
  display_name   = "${each.key}-igw"
}

### NAT Gateway
resource "oci_core_nat_gateway" "these" {
  for_each       = { for k, v in var.vcns : k => v if v.is_create_igw == true }
  compartment_id = each.value.compartment_id
  display_name   = "${each.key}-natgw"
  vcn_id         = oci_core_vcn.these[each.key].id
  block_traffic  = each.value.block_nat_traffic
}

### Service Gateway
resource "oci_core_service_gateway" "these" {
  for_each       = var.vcns
  compartment_id = each.value.compartment_id
  display_name   = "${each.key}-sgw"
  vcn_id         = oci_core_vcn.these[each.key].id
  services {
    service_id = local.osn_cidrs[var.service_gateway_cidr]
  }
}

### DRG attachment to VCN
resource "oci_core_drg_attachment" "these" {
  for_each     = { for k, v in var.vcns : k => v if v.is_attach_drg == true }
  drg_id       = var.drg_id
  vcn_id       = oci_core_vcn.these[each.key].id
  display_name = "${each.key}-drg-attachment"
}

### Subnets
resource "oci_core_subnet" "these" {
  for_each                   = { for subnet in local.subnets : "${subnet.vcn_name}.${subnet.display_name}" => subnet }
  display_name               = each.value.display_name
  vcn_id                     = oci_core_vcn.these[each.value.vcn_name].id
  cidr_block                 = each.value.cidr
  compartment_id             = each.value.compartment_id
  prohibit_public_ip_on_vnic = each.value.private
  dns_label                  = each.value.dns_label
  dhcp_options_id            = each.value.dhcp_options_id
  defined_tags               = each.value.defined_tags
  security_list_ids          = null # [for sl in oci_core_security_list.these : sl.id if sl.subnet_name == each.value.display_name]

}

resource "oci_core_security_list" "these" {
  for_each = {
    for sec_list in local.security_lists : "${sec_list.subnet_name}.${sec_list.sec_list_name}" => sec_list
  }
  vcn_id         = oci_core_vcn.these[each.value.vcn_name].id
  compartment_id = each.value.compartment_id
  display_name   = "${each.value.subnet_name}-${each.value.sec_list_name}"
  defined_tags   = each.value.defined_tags
  freeform_tags  = each.value.freeform_tags

  # dynamic "egress_security_rules" {
  #   for_each = each.value.egress_rules
  #   content {
  #     destination = egress_security_rules.value.dst
  #     protocol    = egress_security_rules.value.protocol
  #     stateless   = egress_security_rules.value.stateless
  #     icmp_options {
  #       type = egress_security_rules.value.icmp_type
  #       code = egress_security_rules.value.icmp_code
  #     }
  #     tcp_options {
  #         max = null
  #         min = null
  #       source_port_range {
  #         max = null
  #         min = null
  #       }
  #     }
  #   }
  # }

  # egress, protocol: ICMP
  dynamic "egress_security_rules" {
    iterator = rule
    for_each = [for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto : x.protocol
        dst : x.dst
        dst_type : x.dst_type
        stateless : x.stateless
        icmp_type : x.icmp_type
        icmp_code : x.icmp_code

    } if x.protocol == "1"]

    content {
      protocol         = rule.value.proto
      destination      = rule.value.dst
      destination_type = rule.value.dst_type
      stateless        = rule.value.stateless
      icmp_options {
        type = rule.value.icmp_type
        code = rule.value.icmp_code
      }
    }
  }

  #  egress, proto: TCP  - no src port, no dst port
  dynamic "egress_security_rules" {
    iterator = rule
    for_each = [for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto : x.protocol
        dst : x.dst
        dst_type : x.dst_type
        stateless : x.stateless
    } if x.protocol == "6" && x.src_port_min == null && x.src_port_max == null && x.dst_port_min == null && x.dst_port_max == null ]

    content {
      protocol         = rule.value.proto
      destination      = rule.value.dst
      destination_type = rule.value.dst_type
      stateless        = rule.value.stateless
    }
  }

  #  egress, proto: TCP  - src port, no dst port
  dynamic "egress_security_rules" {
    iterator = rule
    for_each = [for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto : x.protocol
        dst : x.dst
        dst_type : x.dst_type
        stateless : x.stateless
        src_port_min : x.src_port_min
        src_port_max : x.src_port_max
    } if x.protocol == "6" && x.src_port_min != null && x.src_port_max != null && x.dst_port_min == null && x.dst_port_max == null]

    content {
      protocol         = rule.value.proto
      destination      = rule.value.dst
      destination_type = rule.value.dst_type
      stateless        = rule.value.stateless

      tcp_options {
        source_port_range {
          max = rule.value.src_port_max
          min = rule.value.src_port_min
        }
      }
    }
  }

  #  egress, proto: TCP  - no src port, dst port
  dynamic "egress_security_rules" {
    iterator = rule
    for_each = [for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto : x.protocol
        dst : x.dst
        dst_type : x.dst_type
        stateless : x.stateless
        dst_port_min : x.dst_port.min
        dst_port_max : x.dst_port.max
    } if x.protocol == "6" && x.src_port_min == null && x.src_port_max == null && x.dst_port_min != null && x.dst_port_max != null]

    content {
      protocol         = rule.value.proto
      destination      = rule.value.dst
      destination_type = rule.value.dst_type
      stateless        = rule.value.stateless

      tcp_options {
        max = rule.value.dst_port_max
        min = rule.value.dst_port_min
      }
    }
  }

  #  egress, proto: TCP  - src port, dst port
  dynamic "egress_security_rules" {
    iterator = rule
    for_each = [for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto : x.protocol
        dst : x.dst
        dst_type : x.dst_type
        stateless : x.stateless
        src_port_min : x.src_port_min
        src_port_max : x.src_port_max
        dst_port_min : x.dst_port_min
        dst_port_max : x.dst_port_max
    } if x.protocol == "6" && x.src_port_min != null && x.src_port_max != null && x.dst_port_min != null && x.dst_port_max != null ]

    content {
      protocol         = rule.value.proto
      destination      = rule.value.dst
      destination_type = rule.value.dst_type
      stateless        = rule.value.stateless

      tcp_options {
        max = rule.value.dst_port_max
        min = rule.value.dst_port_min

        source_port_range {
          max = rule.value.src_port_max
          min = rule.value.src_port_min
        }
      }
    }
  }

  #  egress, proto: UDP  - src port, dst port
  dynamic "egress_security_rules" {
    iterator = rule
    for_each = [for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        protocol : x.protocol
        dst : x.dst
        dst_type : x.dst_type
        stateless : x.stateless
        src_port_min : x.src_port_min
        src_port_max : x.src_port_max
        dst_port_min : x.dst_port_min
        dst_port_max : x.dst_port_max
    } if x.protocol == "17"]

    content {
      protocol         = rule.value.protocol
      destination      = rule.value.dst
      destination_type = rule.value.dst_type
      stateless        = rule.value.stateless

      udp_options {
        max = rule.value.dst_port_max
        min = rule.value.dst_port_min

        source_port_range {
          max = rule.value.src_port_max
          min = rule.value.src_port_min
        }
      }
    }
  }




  dynamic "ingress_security_rules" {
    for_each = each.value.ingress_rules
    content {
      source    = ingress_security_rules.value.src
      protocol  = ingress_security_rules.value.protocol
      stateless = ingress_security_rules.value.stateless
      icmp_options {
        type = ingress_security_rules.value.icmp_type
        code = ingress_security_rules.value.icmp_code
      }
    }
  }
}