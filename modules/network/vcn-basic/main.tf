# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

locals {
  osn_cidrs = { for x in data.oci_core_services.all_services.services : x.cidr_block => x.id }

  subnets = flatten([
    for k, v in var.vcns : [
      for k1, v1 in v.subnets : {
        vcn_name        = k
        subnet_key      = k1
        display_name    = v1.name
        cidr            = v1.cidr
        compartment_id  = v1.compartment_id != null ? v1.compartment_id : var.compartment_id
        private         = v1.private
        dns_label       = v1.dns_label
        dhcp_options_id = v1.dhcp_options_id
        defined_tags    = v1.defined_tags
        freeform_tags   = v1.freeform_tags
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
    defined_tags   = each.value.defined_tags
    freeform_tags  = each.value.freeform_tags
}

### Internet Gateway
resource "oci_core_internet_gateway" "these" {
  for_each       = { for k, v in var.vcns : k => v if v.is_create_igw == true }
    compartment_id = each.value.compartment_id
    vcn_id         = oci_core_vcn.these[each.key].id
    display_name   = "${each.key}-igw"
    defined_tags   = each.value.defined_tags
    freeform_tags  = each.value.freeform_tags
}

### NAT Gateway
resource "oci_core_nat_gateway" "these" {
  for_each       = { for k, v in var.vcns : k => v if v.is_create_igw == true }
    compartment_id = each.value.compartment_id
    display_name   = "${each.key}-natgw"
    vcn_id         = oci_core_vcn.these[each.key].id
    block_traffic  = each.value.block_nat_traffic
    defined_tags   = each.value.defined_tags
    freeform_tags  = each.value.freeform_tags
}

### Service Gateway
resource "oci_core_service_gateway" "these" {
  for_each       = var.vcns
    compartment_id = each.value.compartment_id
    display_name   = "${each.key}-sgw"
    defined_tags   = each.value.defined_tags
    freeform_tags  = each.value.freeform_tags
    vcn_id         = oci_core_vcn.these[each.key].id
    services {
      service_id = local.osn_cidrs[var.service_gateway_cidr]
    }
}

### DRG attachment to VCN
resource "oci_core_drg_attachment" "these" {
  for_each     = { for k, v in var.vcns : k => v if v.is_attach_drg == true }
    drg_id        = var.drg_id
    vcn_id        = oci_core_vcn.these[each.key].id
    display_name  = "${each.key}-drg-attachment"
    defined_tags  = each.value.defined_tags
    freeform_tags = each.value.freeform_tags
}

### Subnets
resource "oci_core_subnet" "these" {
  for_each                   = { for subnet in local.subnets : "${subnet.vcn_name}.${subnet.subnet_key}" => subnet }
    display_name               = each.value.display_name
    vcn_id                     = oci_core_vcn.these[each.value.vcn_name].id
    cidr_block                 = each.value.cidr
    compartment_id             = each.value.compartment_id
    prohibit_public_ip_on_vnic = each.value.private
    dns_label                  = each.value.dns_label
    dhcp_options_id            = each.value.dhcp_options_id
    defined_tags               = each.value.defined_tags
    freeform_tags              = each.value.freeform_tags
    security_list_ids          = concat([oci_core_default_security_list.these[each.value.vcn_name].id], #oci_core_security_list.these["${sl.subnet_name}.${sl.sec_list_name}"].id]
                                        [for sl in local.security_lists : oci_core_security_list.these["${sl.subnet_name}.${sl.sec_list_name}"].id if sl.subnet_name == each.value.display_name])
}

resource "oci_core_default_security_list" "these" {
  for_each = oci_core_vcn.these
    manage_default_resource_id = each.value.default_security_list_id
    ingress_security_rules {
      protocol  = "1"
      stateless = false
      source    = "0.0.0.0/0"
      icmp_options {
        type = 3
        code = 4
      }
    }
    ingress_security_rules {
      protocol  = "1"
      stateless = false
      source    = each.value.cidr_block
      icmp_options {
        type = 3
        code = null
      }
    }
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

  # egress, protocol: ICMP with ICMP type
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
        description : x.description

    } if x.is_create && x.protocol == "1" && x.icmp_type != null]

    content {
      protocol         = rule.value.proto
      destination      = rule.value.dst
      destination_type = rule.value.dst_type
      stateless        = rule.value.stateless
      description      = rule.value.description
      icmp_options {
        type = rule.value.icmp_type
        code = rule.value.icmp_code
      }
    }
  }

  # egress, protocol: ICMP without ICMP type
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
        description : x.description

    } if x.is_create && x.protocol == "1" && x.icmp_type == null && x.icmp_code == null]

    content {
      protocol         = rule.value.proto
      destination      = rule.value.dst
      destination_type = rule.value.dst_type
      stateless        = rule.value.stateless
      description      = rule.value.description
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
        description : x.description
    } if x.is_create && x.protocol == "6" && x.src_port_min == null && x.src_port_max == null && x.dst_port_min == null && x.dst_port_max == null]

    content {
      protocol         = rule.value.proto
      destination      = rule.value.dst
      destination_type = rule.value.dst_type
      stateless        = rule.value.stateless
      description      = rule.value.description
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
        description : x.description
    } if x.is_create && x.protocol == "6" && x.src_port_min != null && x.src_port_max != null && x.dst_port_min == null && x.dst_port_max == null]

    content {
      protocol         = rule.value.proto
      destination      = rule.value.dst
      destination_type = rule.value.dst_type
      stateless        = rule.value.stateless
      description      = rule.value.description

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
        dst_port_min : x.dst_port_min
        dst_port_max : x.dst_port_max
        description : x.description
    } if x.is_create && x.protocol == "6" && x.src_port_min == null && x.src_port_max == null && x.dst_port_min != null && x.dst_port_max != null]

    content {
      protocol         = rule.value.proto
      destination      = rule.value.dst
      destination_type = rule.value.dst_type
      stateless        = rule.value.stateless
      description      = rule.value.description

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
        description : x.description
    } if x.is_create && x.protocol == "6" && x.src_port_min != null && x.src_port_max != null && x.dst_port_min != null && x.dst_port_max != null]

    content {
      protocol         = rule.value.proto
      destination      = rule.value.dst
      destination_type = rule.value.dst_type
      stateless        = rule.value.stateless
      description      = rule.value.description

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
  #  egress, proto: UDP  - no src port, no dst port
  dynamic "egress_security_rules" {
    iterator = rule
    for_each = [for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto : x.protocol
        dst : x.dst
        dst_type : x.dst_type
        stateless : x.stateless
        description : x.description
    } if x.is_create && x.protocol == "17" && x.src_port_min == null && x.src_port_max == null && x.dst_port_min == null && x.dst_port_max == null]

    content {
      protocol         = rule.value.proto
      destination      = rule.value.dst
      destination_type = rule.value.dst_type
      stateless        = rule.value.stateless
      description      = rule.value.description
    }
  }

  #  egress, proto: UDP  - src port, no dst port
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
        description : x.description
    } if x.is_create && x.protocol == "17" && x.src_port_min != null && x.src_port_max != null && x.dst_port_min == null && x.dst_port_max == null]

    content {
      protocol         = rule.value.proto
      destination      = rule.value.dst
      destination_type = rule.value.dst_type
      stateless        = rule.value.stateless
      description      = rule.value.description

      udp_options {
        source_port_range {
          max = rule.value.src_port_max
          min = rule.value.src_port_min
        }
      }
    }
  }

  #  egress, proto: UDP  - no src port, dst port
  dynamic "egress_security_rules" {
    iterator = rule
    for_each = [for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto : x.protocol
        dst : x.dst
        dst_type : x.dst_type
        stateless : x.stateless
        dst_port_min : x.dst_port_min
        dst_port_max : x.dst_port_max
        description : x.description
    } if x.is_create && x.protocol == "17" && x.src_port_min == null && x.src_port_max == null && x.dst_port_min != null && x.dst_port_max != null]

    content {
      protocol         = rule.value.proto
      destination      = rule.value.dst
      destination_type = rule.value.dst_type
      stateless        = rule.value.stateless
      description      = rule.value.description

      udp_options {
        max = rule.value.dst_port_max
        min = rule.value.dst_port_min
      }
    }
  }

  #  egress, proto: UDP  - src port, dst port
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
        description : x.description
    } if x.is_create && x.protocol == "17" && x.src_port_min != null && x.src_port_max != null && x.dst_port_min != null && x.dst_port_max != null]

    content {
      protocol         = rule.value.proto
      destination      = rule.value.dst
      destination_type = rule.value.dst_type
      stateless        = rule.value.stateless
      description      = rule.value.description

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

  # ingress, protocol: ICMP with ICMP type
  dynamic "ingress_security_rules" {
    iterator = rule
    for_each = [for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto : x.protocol
        src : x.src
        src_type : x.src_type
        stateless : x.stateless
        icmp_type : x.icmp_type
        icmp_code : x.icmp_code
        description : x.description

    } if x.is_create && x.protocol == "1" && x.icmp_type != null]

    content {
      protocol    = rule.value.proto
      source      = rule.value.src
      source_type = rule.value.src_type
      stateless   = rule.value.stateless
      description = rule.value.description
      icmp_options {
        type = rule.value.icmp_type
        code = rule.value.icmp_code
      }
    }
  }

  # ingress, protocol: ICMP without ICMP type
  dynamic "ingress_security_rules" {
    iterator = rule
    for_each = [for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto : x.protocol
        src : x.src
        src_type : x.src_type
        stateless : x.stateless
        icmp_type : x.icmp_type
        icmp_code : x.icmp_code
        description : x.description

    } if x.is_create && x.protocol == "1" && x.icmp_type == null && x.icmp_code == null]

    content {
      protocol    = rule.value.proto
      source      = rule.value.src
      source_type = rule.value.src_type
      stateless   = rule.value.stateless
      description = rule.value.description
    }
  }


  #  ingress, proto: TCP  - no src port, no dst port
  dynamic "ingress_security_rules" {
    iterator = rule
    for_each = [for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto : x.protocol
        src : x.src
        src_type : x.src_type
        stateless : x.stateless
        description : x.description
    } if x.is_create && x.protocol == "6" && x.src_port_min == null && x.src_port_max == null && x.dst_port_min == null && x.dst_port_max == null]

    content {
      protocol    = rule.value.proto
      source      = rule.value.src
      source_type = rule.value.src_type
      stateless   = rule.value.stateless
      description = rule.value.description
    }
  }

  #  ingress, proto: TCP  - src port, no dst port
  dynamic "ingress_security_rules" {
    iterator = rule
    for_each = [for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto : x.protocol
        src : x.src
        src_type : x.src_type
        stateless : x.stateless
        src_port_min : x.src_port_min
        src_port_max : x.src_port_max
        description : x.description
    } if x.is_create && x.protocol == "6" && x.src_port_min != null && x.src_port_max != null && x.dst_port_min == null && x.dst_port_max == null]

    content {
      protocol    = rule.value.proto
      source      = rule.value.src
      source_type = rule.value.src_type
      stateless   = rule.value.stateless
      description = rule.value.description

      tcp_options {
        source_port_range {
          max = rule.value.src_port_max
          min = rule.value.src_port_min
        }
      }
    }
  }

  #  ingress, proto: TCP  - no src port, dst port
  dynamic "ingress_security_rules" {
    iterator = rule
    for_each = [for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto : x.protocol
        src : x.src
        src_type : x.src_type
        stateless : x.stateless
        dst_port_min : x.dst_port_min
        dst_port_max : x.dst_port_max
        description : x.description
    } if x.is_create && x.protocol == "6" && x.src_port_min == null && x.src_port_max == null && x.dst_port_min != null && x.dst_port_max != null]

    content {
      protocol    = rule.value.proto
      source      = rule.value.src
      source_type = rule.value.src_type
      stateless   = rule.value.stateless
      description = rule.value.description

      tcp_options {
        max = rule.value.dst_port_max
        min = rule.value.dst_port_min
      }
    }
  }

  #  ingress, proto: TCP  - src port, dst port
  dynamic "ingress_security_rules" {
    iterator = rule
    for_each = [for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto : x.protocol
        src : x.src
        src_type : x.src_type
        stateless : x.stateless
        src_port_min : x.src_port_min
        src_port_max : x.src_port_max
        dst_port_min : x.dst_port_min
        dst_port_max : x.dst_port_max
        description : x.description
    } if x.is_create && x.protocol == "6" && x.src_port_min != null && x.src_port_max != null && x.dst_port_min != null && x.dst_port_max != null]

    content {
      protocol    = rule.value.proto
      source      = rule.value.src
      source_type = rule.value.src_type
      stateless   = rule.value.stateless
      description = rule.value.description

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
  #  ingress, proto: UDP  - no src port, no dst port
  dynamic "ingress_security_rules" {
    iterator = rule
    for_each = [for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto : x.protocol
        src : x.src
        src_type : x.src_type
        stateless : x.stateless
        description : x.description
    } if x.is_create && x.protocol == "17" && x.src_port_min == null && x.src_port_max == null && x.dst_port_min == null && x.dst_port_max == null]

    content {
      protocol    = rule.value.proto
      source      = rule.value.src
      source_type = rule.value.src_type
      stateless   = rule.value.stateless
      description = rule.value.description
    }
  }

  #  ingress, proto: UDP  - src port, no dst port
  dynamic "ingress_security_rules" {
    iterator = rule
    for_each = [for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto : x.protocol
        src : x.src
        src_type : x.src_type
        stateless : x.stateless
        src_port_min : x.src_port_min
        src_port_max : x.src_port_max
        description : x.description
    } if x.is_create && x.protocol == "17" && x.src_port_min != null && x.src_port_max != null && x.dst_port_min == null && x.dst_port_max == null]

    content {
      protocol    = rule.value.proto
      source      = rule.value.src
      source_type = rule.value.src_type
      stateless   = rule.value.stateless
      description = rule.value.description

      udp_options {
        source_port_range {
          max = rule.value.src_port_max
          min = rule.value.src_port_min
        }
      }
    }
  }

  #  ingress, proto: UDP  - no src port, dst port
  dynamic "ingress_security_rules" {
    iterator = rule
    for_each = [for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto : x.protocol
        src : x.src
        src_type : x.src_type
        stateless : x.stateless
        dst_port_min : x.dst_port_min
        dst_port_max : x.dst_port_max
        description : x.description
    } if x.is_create && x.protocol == "17" && x.src_port_min == null && x.src_port_max == null && x.dst_port_min != null && x.dst_port_max != null]

    content {
      protocol    = rule.value.proto
      source      = rule.value.src
      source_type = rule.value.src_type
      stateless   = rule.value.stateless
      description = rule.value.description

      udp_options {
        max = rule.value.dst_port_max
        min = rule.value.dst_port_min
      }
    }
  }

  #  ingress, proto: UDP  - src port, dst port
  dynamic "ingress_security_rules" {
    iterator = rule
    for_each = [for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto : x.protocol
        src : x.src
        src_type : x.src_type
        stateless : x.stateless
        src_port_min : x.src_port_min
        src_port_max : x.src_port_max
        dst_port_min : x.dst_port_min
        dst_port_max : x.dst_port_max
        description : x.description
    } if x.is_create && x.protocol == "17" && x.src_port_min != null && x.src_port_max != null && x.dst_port_min != null && x.dst_port_max != null]

    content {
      protocol    = rule.value.proto
      source      = rule.value.src
      source_type = rule.value.src_type
      stateless   = rule.value.stateless
      description = rule.value.description

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

}