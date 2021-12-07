# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### Security List(s)
# default values
locals {
  default_security_list_opt = {
    display_name    = "unnamed"
    compartment_id  = null
    ingress_rules   = []
    egress_rules    = []
  }
}

# Security lists
resource "oci_core_security_list" "these" {
  for_each = var.security_lists
    compartment_id = each.value.compartment_id != null ? each.value.compartment_id : var.compartment_id
    display_name   = each.key
    vcn_id         = each.value.vcn_id
    defined_tags   = each.value.defined_tags
    freeform_tags  = each.value.freeform_tags

  #  egress, proto: TCP  - no src port, no dst port
  dynamic "egress_security_rules" {
    iterator            = rule
    for_each            = [for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto           : x.protocol
        dst             : x.dst
        dst_type        : x.dst_type
        stateless       : x.stateless
      } if x.protocol == "6" && x.src_port == null && x.dst_port == null ]
      
    content {
      protocol          = rule.value.proto
      destination       = rule.value.dst
      destination_type  = rule.value.dst_type
      stateless         = rule.value.stateless
    }
  }

  #  egress, proto: TCP  - src port, no dst port
  dynamic "egress_security_rules" {
    iterator            = rule
    for_each            = [for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto           : x.protocol
        dst             : x.dst
        dst_type        : x.dst_type
        stateless       : x.stateless
        src_port_min    : x.src_port.min
        src_port_max    : x.src_port.max
      } if x.protocol == "6" && x.src_port != null && x.dst_port == null ]
      
    content {
      protocol          = rule.value.proto
      destination       = rule.value.dst
      destination_type  = rule.value.dst_type
      stateless         = rule.value.stateless
      
      tcp_options {
        source_port_range {
          max           = rule.value.src_port_max
          min           = rule.value.src_port_min
        }
      }
    }
  }

  #  egress, proto: TCP  - no src port, dst port
  dynamic "egress_security_rules" {
    iterator            = rule
    for_each            = [for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto           : x.protocol
        dst             : x.dst
        dst_type        : x.dst_type
        stateless       : x.stateless
        dst_port_min    : x.dst_port.min
        dst_port_max    : x.dst_port.max
      } if x.protocol == "6" && x.src_port == null && x.dst_port != null ]
      
    content {
      protocol          = rule.value.proto
      destination       = rule.value.dst
      destination_type  = rule.value.dst_type
      stateless         = rule.value.stateless
      
      tcp_options {
        max             = rule.value.dst_port_max
        min             = rule.value.dst_port_min
      }
    }
  }

  #  egress, proto: TCP  - src port, dst port
  dynamic "egress_security_rules" {
    iterator            = rule
    for_each            = [for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto           : x.protocol
        dst             : x.dst
        dst_type        : x.dst_type
        stateless       : x.stateless
        src_port_min    : x.src_port.min
        src_port_max    : x.src_port.max
        dst_port_min    : x.dst_port.min
        dst_port_max    : x.dst_port.max
      } if x.protocol == "6" && x.src_port != null && x.dst_port != null ]
      
    content {
      protocol          = rule.value.proto
      destination       = rule.value.dst
      destination_type  = rule.value.dst_type
      stateless         = rule.value.stateless

      tcp_options {
        max             = rule.value.dst_port_max
        min             = rule.value.dst_port_min
        
        source_port_range {
          max           = rule.value.src_port_max
          min           = rule.value.src_port_min
        }
      }
    }
  }

  #  egress, proto: UDP  - no src port, no dst port
  dynamic "egress_security_rules" {
    iterator            = rule
    for_each            = [for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto           : x.protocol
        dst             : x.dst
        dst_type        : x.dst_type
        stateless       : x.stateless
      } if x.protocol == "17" && x.src_port == null && x.dst_port == null ]
      
    content {
      protocol          = rule.value.proto
      destination       = rule.value.dst
      destination_type  = rule.value.dst_type
      stateless         = rule.value.stateless
    }
  }

  #  egress, proto: UDP  - src port, no dst port
  dynamic "egress_security_rules" {
    iterator            = rule
    for_each            = [for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto           : x.protocol
        dst             : x.dst
        dst_type        : x.dst_type
        stateless       : x.stateless
        src_port_min    : x.src_port.min
        src_port_max    : x.src_port.max
      } if x.protocol == "17" && x.src_port != null && x.dst_port == null ]
      
    content {
      protocol          = rule.value.proto
      destination       = rule.value.dst
      destination_type  = rule.value.dst_type
      stateless         = rule.value.stateless
      
      udp_options {
        source_port_range {
          max           = rule.value.src_port_max
          min           = rule.value.src_port_min
        }
      }
    }
  }

  #  egress, proto: UDP  - no src port, dst port
  dynamic "egress_security_rules" {
    iterator            = rule
    for_each            = [for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto           : x.protocol
        dst             : x.dst
        dst_type        : x.dst_type
        stateless       : x.stateless
        dst_port_min    : x.dst_port.min
        dst_port_max    : x.dst_port.max
      } if x.protocol == "17" && x.src_port == null && x.dst_port != null ]
      
    content {
      protocol          = rule.value.proto
      destination       = rule.value.dst
      destination_type  = rule.value.dst_type
      stateless         = rule.value.stateless
      
      udp_options {
        max             = rule.value.dst_port_max
        min             = rule.value.dst_port_min
      }
    }
  }

  #  egress, proto: UDP  - src port, dst port
  dynamic "egress_security_rules" {
    iterator            = rule
    for_each            = [for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto           : x.protocol
        dst             : x.dst
        dst_type        : x.dst_type
        stateless       : x.stateless
        src_port_min    : x.src_port.min
        src_port_max    : x.src_port.max
        dst_port_min    : x.dst_port.min
        dst_port_max    : x.dst_port.max
      } if x.protocol == "17" && x.src_port != null && x.dst_port != null ]
      
    content {
      protocol          = rule.value.proto
      destination       = rule.value.dst
      destination_type  = rule.value.dst_type
      stateless         = rule.value.stateless

      udp_options {
        max             = rule.value.dst_port_max
        min             = rule.value.dst_port_min
        
        source_port_range {
          max           = rule.value.src_port_max
          min           = rule.value.src_port_min
        }
      }
    }
  }

  #  egress, proto: ICMP  - no type, no code
  dynamic "egress_security_rules" {
    iterator            = rule
    for_each            = [for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto           : x.protocol
        dst             : x.dst
        dst_type        : x.dst_type
        stateless       : x.stateless
      } if x.protocol == "1" && x.icmp_type == null && x.icmp_code == null ]
      
    content {
      protocol          = rule.value.proto
      destination       = rule.value.dst
      destination_type  = rule.value.dst_type
      stateless         = rule.value.stateless
    }
  }

  #  egress, proto: ICMP  - type, no code
  dynamic "egress_security_rules" {
    iterator            = rule
    for_each            = [for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto           : x.protocol
        dst             : x.dst
        dst_type        : x.dst_type
        stateless       : x.stateless
        type            : x.icmp_type
      } if x.protocol == "1" && x.icmp_type != null && x.icmp_code == null ]
      
    content {
      protocol          = rule.value.proto
      destination       = rule.value.dst
      destination_type  = rule.value.dst_type
      stateless         = rule.value.stateless
      
      icmp_options {
        type            = rule.value.type
      }
    }
  }
  
  #  egress, proto: ICMP  - type, code
  dynamic "egress_security_rules" {
    iterator            = rule
    for_each            = [for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto           : x.protocol
        dst             : x.dst
        dst_type        : x.dst_type
        stateless       : x.stateless
        type            : x.icmp_type
        code            : x.icmp_code
      } if x.protocol == "1" && x.icmp_type != null && x.icmp_code != null ]
      
    content {
      protocol          = rule.value.proto
      destination       = rule.value.dst
      destination_type  = rule.value.dst_type
      stateless         = rule.value.stateless

      icmp_options {
        type            = rule.value.type
        code            = rule.value.code
      }
    }
  }

    #  egress, proto: other (non-TCP, UDP or ICMP)
  dynamic "egress_security_rules" {
    iterator            = rule
    for_each            = [for x in each.value.egress_rules != null ? each.value.egress_rules : local.default_security_list_opt.egress_rules :
      {
        proto           : x.protocol
        dst             : x.dst
        dst_type        : x.dst_type
        stateless       : x.stateless
      } if x.protocol != "1" && x.protocol != "6" && x.protocol != "17" ]
      
    content {
      protocol          = rule.value.proto
      destination       = rule.value.dst
      destination_type  = rule.value.dst_type
      stateless         = rule.value.stateless
    }
  }

  # ingress, proto: TCP  - no src port, no dst port
  dynamic "ingress_security_rules" {
    iterator            = rule
    for_each            = [for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto           : x.protocol
        src             : x.src
        src_type        : x.src_type
        stateless       : x.stateless
      } if x.protocol == "6" && x.src_port == null && x.dst_port == null ]
      
    content {
      protocol          = rule.value.proto
      source            = rule.value.src
      source_type       = rule.value.src_type
      stateless         = rule.value.stateless
    }
  }

  # ingress, proto: TCP  - src port, no dst port
  dynamic "ingress_security_rules" {
    iterator            = rule
    for_each            = [for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto           : x.protocol
        src             : x.src
        src_type        : x.src_type
        stateless       : x.stateless
        src_port_min    : x.src_port.min
        src_port_max    : x.src_port.max
      } if x.protocol == "6" && x.src_port != null && x.dst_port == null]
      
    content {
      protocol          = rule.value.proto
      source            = rule.value.src
      source_type       = rule.value.src_type
      stateless         = rule.value.stateless
      
      tcp_options {
        source_port_range {
          max           = rule.value.src_port_max
          min           = rule.value.src_port_min
        }
      }
    }
  }

  # ingress, proto: TCP  - no src port, dst port
  dynamic "ingress_security_rules" {
    iterator            = rule
    for_each            = [for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto           : x.protocol
        src             : x.src
        src_type        : x.src_type
        stateless       : x.stateless
        dst_port_min    : x.dst_port.min
        dst_port_max    : x.dst_port.max
      } if x.protocol == "6" && x.src_port == null && x.dst_port != null && (x.src != var.anywhere_cidr || (x.src == var.anywhere_cidr && length(setintersection(range(x.dst_port.min,x.dst_port.max+1),var.ports_not_allowed_from_anywhere_cidr)) == 0))]
      
    content {
      protocol          = rule.value.proto
      source            = rule.value.src
      source_type       = rule.value.src_type
      stateless         = rule.value.stateless
      
      tcp_options {
        max             = rule.value.dst_port_max
        min             = rule.value.dst_port_min
      }
    }
  }

  # ingress, proto: TCP  - src port, dst port
  dynamic "ingress_security_rules" {
    iterator            = rule
    for_each            = [for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto           : x.protocol
        src             : x.src
        src_type        : x.src_type
        stateless       : x.stateless
        src_port_min    : x.src_port.min
        src_port_max    : x.src_port.max
        dst_port_min    : x.dst_port.min
        dst_port_max    : x.dst_port.max
      } if x.protocol == "6" && x.src_port != null && x.dst_port != null && (x.src != var.anywhere_cidr || (x.src == var.anywhere_cidr && length(setintersection(range(x.dst_port.min,x.dst_port.max+1),var.ports_not_allowed_from_anywhere_cidr)) == 0))]
      
    content {
      protocol          = rule.value.proto
      source            = rule.value.src
      source_type       = rule.value.src_type
      stateless         = rule.value.stateless

      tcp_options {
        max             = rule.value.dst_port_max
        min             = rule.value.dst_port_min
        
        source_port_range {
          max           = rule.value.src_port_max
          min           = rule.value.src_port_min
        }
      }
    }
  }

  # ingress, proto: UDP  - no src port, no dst port
  dynamic "ingress_security_rules" {
    iterator            = rule
    for_each            = [for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto           : x.protocol
        dst             : x.dst
        dst_type        : x.dst_type
        stateless       : x.stateless
      } if x.protocol == "17" && x.src_port == null && x.dst_port == null ]
      
    content {
      protocol          = rule.value.proto
      source            = rule.value.src
      source_type       = rule.value.src_type
      stateless         = rule.value.stateless
    }
  }

  # ingress, proto: UDP  - src port, no dst port
  dynamic "ingress_security_rules" {
    iterator            = rule
    for_each            = [for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto           : x.protocol
        src             : x.src
        src_type        : x.src_type
        stateless       : x.stateless
        src_port_min    : x.src_port.min
        src_port_max    : x.src_port.max
      } if x.protocol == "17" && x.src_port != null && x.dst_port == null ]
      
    content {
      protocol          = rule.value.proto
      source            = rule.value.src
      source_type       = rule.value.src_type
      stateless         = rule.value.stateless
      
      udp_options {
        source_port_range {
          max           = rule.value.src_port_max
          min           = rule.value.src_port_min
        }
      }
    }
  }

  # ingress, proto: UDP  - no src port, dst port
  dynamic "ingress_security_rules" {
    iterator            = rule
    for_each            = [for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto           : x.protocol
        src             : x.src
        src_type        : x.src_type
        stateless       : x.stateless
        dst_port_min    : x.dst_port.min
        dst_port_max    : x.dst_port.max
      } if x.protocol == "17" && x.src_port == null && x.dst_port != null ]
      
    content {
      protocol          = rule.value.proto
      source            = rule.value.src
      source_type       = rule.value.src_type
      stateless         = rule.value.stateless
      
      udp_options {
        max             = rule.value.dst_port_max
        min             = rule.value.dst_port_min
      }
    }
  }

  # ingress, proto: UDP  - src port, dst port
  dynamic "ingress_security_rules" {
    iterator            = rule
    for_each            = [for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto           : x.protocol
        src             : x.src
        src_type        : x.src_type
        stateless       : x.stateless
        src_port_min    : x.src_port.min
        src_port_max    : x.src_port.max
        dst_port_min    : x.dst_port.min
        dst_port_max    : x.dst_port.max
      } if x.protocol == "17" && x.src_port != null && x.dst_port != null ]
      
    content {
      protocol          = rule.value.proto
      source            = rule.value.src
      source_type       = rule.value.src_type
      stateless         = rule.value.stateless

      udp_options {
        max             = rule.value.dst_port_max
        min             = rule.value.dst_port_min
        
        source_port_range {
          max           = rule.value.src_port_max
          min           = rule.value.src_port_min
        }
      }
    }
  }

  # ingress, proto: ICMP  - no type, no code
  dynamic "ingress_security_rules" {
    iterator            = rule
    for_each            = [for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto           : x.protocol
        dst             : x.dst
        dst_type        : x.dst_type
        stateless       : x.stateless
      } if x.protocol == "1" && x.icmp_type == null && x.icmp_code == null ]
      
    content {
      protocol          = rule.value.proto
      source            = rule.value.src
      source_type       = rule.value.src_type
      stateless         = rule.value.stateless
    }
  }

  # ingress, proto: ICMP  - type, no code
  dynamic "ingress_security_rules" {
    iterator            = rule
    for_each            = [for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto           : x.protocol
        src             : x.src
        src_type        : x.src_type
        stateless       : x.stateless
        type            : x.icmp_type
      } if x.protocol == "1" && x.icmp_type != null && x.icmp_code == null ]
      
    content {
      protocol          = rule.value.proto
      source            = rule.value.src
      source_type       = rule.value.src_type
      stateless         = rule.value.stateless
      
      icmp_options {
        type            = rule.value.type
      }
    }
  }
  
  # ingress, proto: ICMP  - type, code
  dynamic "ingress_security_rules" {
    iterator            = rule
    for_each            = [for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto           : x.protocol
        src             : x.src
        src_type        : x.src_type
        stateless       : x.stateless
        type            : x.icmp_type
        code            : x.icmp_code
      } if x.protocol == "1" && x.icmp_type != null && x.icmp_code != null ]
      
    content {
      protocol          = rule.value.proto
      source            = rule.value.src
      source_type       = rule.value.src_type
      stateless         = rule.value.stateless

      icmp_options {
        type            = rule.value.type
        code            = rule.value.code
      }
    }
  }

    # ingress, proto: other (non-TCP, UDP or ICMP)
  dynamic "ingress_security_rules" {
    iterator            = rule
    for_each            = [for x in each.value.ingress_rules != null ? each.value.ingress_rules : local.default_security_list_opt.ingress_rules :
      {
        proto           : x.protocol
        src             : x.src
        src_type        : x.src_type
        stateless       : x.stateless
      } if x.protocol != "1" && x.protocol != "6" && x.protocol != "17" ]
      
    content {
      protocol          = rule.value.proto
      source            = rule.value.src
      source_type       = rule.value.src_type
      stateless         = rule.value.stateless
    }
  }
}