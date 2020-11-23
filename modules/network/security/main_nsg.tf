# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### Network Security Group(s) - NSGs
# default values
locals {
  local_nsg_ids     = { for i in oci_core_network_security_group.these : i.display_name => i.id }
  remote_nsg_ids    = { for i in data.oci_core_network_security_groups.this.network_security_groups : i.display_name => i.id }
  nsg_ids           = merge(local.remote_nsg_ids, local.local_nsg_ids)
  nsg_ids_reversed  = { for k,v in local.nsg_ids : v => k }
}

data "oci_core_network_security_groups" "this" {
  compartment_id = var.default_compartment_id
  vcn_id = var.vcn_id
}

# Network Security Groups
resource "oci_core_network_security_group" "these" {
  for_each = var.nsgs 
    compartment_id = each.value.compartment_id != null ? each.value.compartment_id : var.default_compartment_id
    vcn_id         = var.vcn_id
    display_name   = each.key
    defined_tags   = each.value.defined_tags
    freeform_tags  = each.value.freeform_tags
}

### Network Security Group Rules
# default values
locals {
  default_nsgs_rules_opt = {
    display_name        = "unnamed"
    compartment_id      = null
    ingress_rules       = []
    egress_rules        = []
  }
  
  # INGRESS rules - defined as part of NSG
  n_ingress_rules_other = flatten( [ for k,v in var.nsgs != null ? var.nsgs : {} :
    [ for i in v.ingress_rules != null ? v.ingress_rules : [] :
      {
        nsg_id          = local.nsg_ids[k]
        protocol        = i.protocol
        description     = i.description
        stateless       = i.stateless
        src             = i.src
        src_type        = i.src_type
      } if i.src_port == null && i.dst_port == null && i.icmp_type == null && i.icmp_code == null
    ]
  ] )
  
  n_ingress_rules_tcp_src_no_dst = flatten( [ for k,v in var.nsgs != null ? var.nsgs : {} :
    [ for i in v.ingress_rules != null ? v.ingress_rules : [] :
      {
        nsg_id          = local.nsg_ids[k]
        protocol        = i.protocol
        description     = i.description
        stateless       = i.stateless
        src             = i.src
        src_type        = i.src_type
        src_port        = i.src_port
      } if i.protocol == "6" && i.src_port != null && i.dst_port == null
    ]
  ] )
  n_ingress_rules_tcp_no_src_dst = flatten( [ for k,v in var.nsgs != null ? var.nsgs : {} :
    [ for i in v.ingress_rules != null ? v.ingress_rules : [] :
      {
        nsg_id          = local.nsg_ids[k]
        protocol        = i.protocol
        description     = i.description
        stateless       = i.stateless
        src             = i.src
        src_type        = i.src_type
        dst_port        = i.dst_port
      } if i.protocol == "6" && i.src_port == null && i.dst_port != null && (i.src != var.anywhere_cidr || (i.src == var.anywhere_cidr && length(setintersection(range(i.dst_port.min,i.dst_port.max+1),var.ports_not_allowed_from_anywhere_cidr)) == 0)) 
    ]
  ] )
  n_ingress_rules_tcp_src_dst = flatten( [ for k,v in var.nsgs != null ? var.nsgs : {} :
    [ for i in v.ingress_rules != null ? v.ingress_rules : [] :
      {
        nsg_id          = local.nsg_ids[k]
        protocol        = i.protocol
        description     = i.description
        stateless       = i.stateless
        src             = i.src
        src_type        = i.src_type
        src_port        = i.src_port
        dst_port        = i.dst_port
      } if i.protocol == "6" && i.src_port != null && i.dst_port != null && (i.src != var.anywhere_cidr || (i.src == var.anywhere_cidr && length(setintersection(range(i.dst_port.min,i.dst_port.max+1),var.ports_not_allowed_from_anywhere_cidr)) == 0))
    ]
  ] )

  n_ingress_rules_udp_src_no_dst = flatten( [ for k,v in var.nsgs != null ? var.nsgs : {} :
    [ for i in v.ingress_rules != null ? v.ingress_rules : [] :
      {
        nsg_id          = local.nsg_ids[k]
        protocol        = i.protocol
        description     = i.description
        stateless       = i.stateless
        src             = i.src
        src_type        = i.src_type
        src_port        = i.src_port
      } if i.protocol == "17" && i.src_port != null && i.dst_port == null
    ]
  ] )
  n_ingress_rules_udp_no_src_dst = flatten( [ for k,v in var.nsgs != null ? var.nsgs : {} :
    [ for i in v.ingress_rules != null ? v.ingress_rules : [] :
      {
        nsg_id          = local.nsg_ids[k]
        protocol        = i.protocol
        description     = i.description
        stateless       = i.stateless
        src             = i.src
        src_type        = i.src_type
        dst_port        = i.dst_port
      } if i.protocol == "17" && i.src_port == null && i.dst_port != null
    ]
  ] )
  n_ingress_rules_udp_src_dst = flatten( [ for k,v in var.nsgs != null ? var.nsgs : {} :
    [ for i in v.ingress_rules != null ? v.ingress_rules : [] :
      {
        nsg_id          = local.nsg_ids[k]
        protocol        = i.protocol
        description     = i.description
        stateless       = i.stateless
        src             = i.src
        src_type        = i.src_type
        src_port        = i.src_port
        dst_port        = i.dst_port
      } if i.protocol == "17" && i.src_port != null && i.dst_port != null
    ]
  ] )
  
  n_ingress_rules_icmp_type_code = flatten( [ for k,v in var.nsgs != null ? var.nsgs : {} :
    [ for i in v.ingress_rules != null ? v.ingress_rules : [] :
      {
        nsg_id          = local.nsg_ids[k]
        protocol        = i.protocol
        description     = i.description
        stateless       = i.stateless
        src             = i.src
        src_type        = i.src_type
        icmp_code       = i.icmp_code
        icmp_type       = i.icmp_type
      } if i.protocol == "1" && i.icmp_code != null && i.icmp_type != null
    ]
  ] )
  n_ingress_rules_icmp_type_no_code = flatten( [ for k,v in var.nsgs != null ? var.nsgs : {} :
    [ for i in v.ingress_rules != null ? v.ingress_rules : [] :
      {
        nsg_id          = local.nsg_ids[k]
        protocol        = i.protocol
        description     = i.description
        stateless       = i.stateless
        src             = i.src
        src_type        = i.src_type
        icmp_type       = i.icmp_type
      } if i.protocol == "1" && i.icmp_code == null && i.icmp_type != null
    ]
  ] )

  # INGRESS rules - standalone rules
  s_ingress_rules_other = flatten( [ for i in var.standalone_nsg_rules.ingress_rules :
    {
      nsg_id            = i.nsg_id
      protocol          = i.protocol
      description       = i.description
      stateless         = i.stateless
      src               = i.src
      src_type          = i.src_type
    } if i.src_port == null && i.dst_port == null && i.icmp_type == null && i.icmp_code == null
  ] )
  
  s_ingress_rules_tcp_src_no_dst = flatten( [ for i in var.standalone_nsg_rules.ingress_rules :
    {
      nsg_id            = i.nsg_id
      protocol          = i.protocol
      description       = i.description
      stateless         = i.stateless
      src               = i.src
      src_type          = i.src_type
      src_port          = i.src_port
    } if i.protocol == "6" && i.src_port != null && i.dst_port == null
  ] )
  s_ingress_rules_tcp_no_src_dst = flatten( [ for i in var.standalone_nsg_rules.ingress_rules :
    {
      nsg_id            = i.nsg_id
      protocol          = i.protocol
      description       = i.description
      stateless         = i.stateless
      src               = i.src
      src_type          = i.src_type
      dst_port          = i.dst_port
    } if i.protocol == "6" && i.src_port == null && i.dst_port != null && (i.src != var.anywhere_cidr || (i.src == var.anywhere_cidr && length(setintersection(range(i.dst_port.min,i.dst_port.max+1),var.ports_not_allowed_from_anywhere_cidr)) == 0))
  ] )
  s_ingress_rules_tcp_src_dst = flatten( [ for i in var.standalone_nsg_rules.ingress_rules :
    {
      nsg_id            = i.nsg_id
      protocol          = i.protocol
      description       = i.description
      stateless         = i.stateless
      src               = i.src
      src_type          = i.src_type
      src_port          = i.src_port
      dst_port          = i.dst_port
    } if i.protocol == "6" && i.src_port != null && i.dst_port != null && (i.src != var.anywhere_cidr || (i.src == var.anywhere_cidr && length(setintersection(range(i.dst_port.min,i.dst_port.max+1),var.ports_not_allowed_from_anywhere_cidr)) == 0))
  ] )

  s_ingress_rules_udp_src_no_dst = flatten( [ for i in var.standalone_nsg_rules.ingress_rules :
    {
      nsg_id            = i.nsg_id
      protocol          = i.protocol
      description       = i.description
      stateless         = i.stateless
      src               = i.src
      src_type          = i.src_type
      src_port          = i.src_port
    } if i.protocol == "17" && i.src_port != null && i.dst_port == null
  ] )
  s_ingress_rules_udp_no_src_dst = flatten( [ for i in var.standalone_nsg_rules.ingress_rules :
    {
      nsg_id            = i.nsg_id
      protocol          = i.protocol
      description       = i.description
      stateless         = i.stateless
      src               = i.src
      src_type          = i.src_type
      dst_port          = i.dst_port
    } if i.protocol == "17" && i.src_port == null && i.dst_port != null
  ] )
  s_ingress_rules_udp_src_dst = flatten( [ for i in var.standalone_nsg_rules.ingress_rules :
    {
      nsg_id            = i.nsg_id
      protocol          = i.protocol
      description       = i.description
      stateless         = i.stateless
      src               = i.src
      src_type          = i.src_type
      src_port          = i.src_port
      dst_port          = i.dst_port
    } if i.protocol == "17" && i.src_port != null && i.dst_port != null
  ] )
  
  s_ingress_rules_icmp_type_code = flatten( [ for i in var.standalone_nsg_rules.ingress_rules :
    {
      nsg_id            = i.nsg_id
      protocol          = i.protocol
      description       = i.description
      stateless         = i.stateless
      src               = i.src
      src_type          = i.src_type
      icmp_code         = i.icmp_code
      icmp_type         = i.icmp_type
    } if i.protocol == "1" && i.icmp_code != null && i.icmp_type != null
  ] )
  s_ingress_rules_icmp_type_no_code = flatten( [ for i in var.standalone_nsg_rules.ingress_rules :
    {
      nsg_id            = i.nsg_id
      protocol          = i.protocol
      description       = i.description
      stateless         = i.stateless
      src               = i.src
      src_type          = i.src_type
      icmp_type         = i.icmp_type
    } if i.protocol == "1" && i.icmp_code == null && i.icmp_type != null
  ] )

  #######################

  # INGRESS rules - merged
  ingress_rules_other             = concat( local.n_ingress_rules_other, local.s_ingress_rules_other )
  
  ingress_rules_tcp_src_no_dst    = concat( local.n_ingress_rules_tcp_src_no_dst, local.s_ingress_rules_tcp_src_no_dst )
  ingress_rules_tcp_no_src_dst    = concat( local.n_ingress_rules_tcp_no_src_dst, local.s_ingress_rules_tcp_no_src_dst )
  ingress_rules_tcp_src_dst       = concat( local.n_ingress_rules_tcp_src_dst, local.s_ingress_rules_tcp_src_dst )

  ingress_rules_udp_src_no_dst    = concat( local.n_ingress_rules_udp_src_no_dst, local.s_ingress_rules_udp_src_no_dst )
  ingress_rules_udp_no_src_dst    = concat( local.n_ingress_rules_udp_no_src_dst, local.s_ingress_rules_udp_no_src_dst )
  ingress_rules_udp_src_dst       = concat( local.n_ingress_rules_udp_src_dst, local.s_ingress_rules_udp_src_dst )
  
  ingress_rules_icmp_type_code    = concat( local.n_ingress_rules_icmp_type_code, local.s_ingress_rules_icmp_type_code )
  ingress_rules_icmp_type_no_code = concat( local.n_ingress_rules_icmp_type_no_code, local.s_ingress_rules_icmp_type_no_code )

  #######################
  
  # EGRESS rules - included in NSG definition
  n_egress_rules_other  = flatten( [ for k,v in var.nsgs != null ? var.nsgs : {} :
    [ for i in v.egress_rules != null ? v.egress_rules : [] :
      {
        nsg_id          = local.nsg_ids[k]
        protocol        = i.protocol
        description     = i.description
        stateless       = i.stateless
        dst             = i.dst
        dst_type        = i.dst_type
      } if i.src_port == null && i.dst_port == null && i.icmp_type == null && i.icmp_code == null
    ]
  ] )
  
  n_egress_rules_tcp_src_no_dst = flatten( [ for k,v in var.nsgs != null ? var.nsgs : {} :
    [ for i in v.egress_rules != null ? v.egress_rules : [] :
      {
        nsg_id          = local.nsg_ids[k]
        protocol        = i.protocol
        description     = i.description
        stateless       = i.stateless
        dst             = i.dst
        dst_type        = i.dst_type
        src_port        = i.src_port
      } if i.protocol == "6" && i.src_port != null && i.dst_port == null
    ]
  ] )
  n_egress_rules_tcp_no_src_dst = flatten( [ for k,v in var.nsgs != null ? var.nsgs : {} :
    [ for i in v.egress_rules != null ? v.egress_rules : [] :
      {
        nsg_id          = local.nsg_ids[k]
        protocol        = i.protocol
        description     = i.description
        stateless       = i.stateless
        dst             = i.dst
        dst_type        = i.dst_type
        dst_port        = i.dst_port
      } if i.protocol == "6" && i.src_port == null && i.dst_port != null
    ]
  ] )
  n_egress_rules_tcp_src_dst = flatten( [ for k,v in var.nsgs != null ? var.nsgs : {} :
    [ for i in v.egress_rules != null ? v.egress_rules : [] :
      {
        nsg_id          = local.nsg_ids[k]
        protocol        = i.protocol
        description     = i.description
        stateless       = i.stateless
        dst             = i.dst
        dst_type        = i.dst_type
        src_port        = i.src_port
        dst_port        = i.dst_port
      } if i.protocol == "6" && i.src_port != null && i.dst_port != null
    ]
  ] )

  n_egress_rules_udp_src_no_dst = flatten( [ for k,v in var.nsgs != null ? var.nsgs : {} :
    [ for i in v.egress_rules != null ? v.egress_rules : [] :
      {
        nsg_id          = local.nsg_ids[k]
        protocol        = i.protocol
        description     = i.description
        stateless       = i.stateless
        dst             = i.dst
        dst_type        = i.dst_type
        src_port        = i.src_port
      } if i.protocol == "17" && i.src_port != null && i.dst_port == null
    ]
  ] )
  n_egress_rules_udp_no_src_dst = flatten( [ for k,v in var.nsgs != null ? var.nsgs : {} :
    [ for i in v.egress_rules != null ? v.egress_rules : [] :
      {
        nsg_id          = local.nsg_ids[k]
        protocol        = i.protocol
        description     = i.description
        stateless       = i.stateless
        dst             = i.dst
        dst_type        = i.dst_type
        dst_port        = i.dst_port
      } if i.protocol == "17" && i.src_port == null && i.dst_port != null
    ]
  ] )
  n_egress_rules_udp_src_dst = flatten( [ for k,v in var.nsgs != null ? var.nsgs : {} :
    [ for i in v.egress_rules != null ? v.egress_rules : [] :
      {
        nsg_id          = local.nsg_ids[k]
        protocol        = i.protocol
        description     = i.description
        stateless       = i.stateless
        dst             = i.dst
        dst_type        = i.dst_type
        src_port        = i.src_port
        dst_port        = i.dst_port
      } if i.protocol == "17" && i.src_port != null && i.dst_port != null
    ]
  ] )
  
  n_egress_rules_icmp_type_code = flatten( [ for k,v in var.nsgs != null ? var.nsgs : {} :
    [ for i in v.egress_rules != null ? v.egress_rules : [] :
      {
        nsg_id          = local.nsg_ids[k]
        protocol        = i.protocol
        description     = i.description
        stateless       = i.stateless
        dst             = i.dst
        dst_type        = i.dst_type
        icmp_code       = i.icmp_code
        icmp_type       = i.icmp_type
      } if i.protocol == "1" && i.icmp_code != null && i.icmp_type != null
    ]
  ] )
  n_egress_rules_icmp_type_no_code = flatten( [ for k,v in var.nsgs != null ? var.nsgs : {} :
    [ for i in v.egress_rules != null ? v.egress_rules : [] :
      {
        nsg_id          = local.nsg_ids[k]
        protocol        = i.protocol
        description     = i.description
        stateless       = i.stateless
        dst             = i.dst
        dst_type        = i.dst_type
        icmp_type       = i.icmp_type
      } if i.protocol == "1" && i.icmp_code == null && i.icmp_type != null
    ]
  ] )

  # EGRESS rules - standalone rules
  s_egress_rules_other  = flatten( [ for i in var.standalone_nsg_rules.egress_rules :
    {
      nsg_id            = i.nsg_id
      protocol          = i.protocol
      description       = i.description
      stateless         = i.stateless
      dst               = i.dst
      dst_type          = i.dst_type
    } if i.src_port == null && i.dst_port == null && i.icmp_type == null && i.icmp_code == null
  ] )
  
  s_egress_rules_tcp_src_no_dst = flatten( [ for i in var.standalone_nsg_rules.egress_rules :
    {
      nsg_id            = i.nsg_id
      protocol          = i.protocol
      description       = i.description
      stateless         = i.stateless
      dst               = i.dst
      dst_type          = i.dst_type
      src_port          = i.src_port
    } if i.protocol == "6" && i.src_port != null && i.dst_port == null
  ] )
  s_egress_rules_tcp_no_src_dst = flatten( [ for i in var.standalone_nsg_rules.egress_rules :
    {
      nsg_id            = i.nsg_id
      protocol          = i.protocol
      description       = i.description
      stateless         = i.stateless
      dst               = i.dst
      dst_type          = i.dst_type
      dst_port          = i.dst_port
    } if i.protocol == "6" && i.src_port == null && i.dst_port != null
  ] )
  s_egress_rules_tcp_src_dst = flatten( [ for i in var.standalone_nsg_rules.egress_rules :
    {
      nsg_id            = i.nsg_id
      protocol          = i.protocol
      description       = i.description
      stateless         = i.stateless
      dst               = i.dst
      dst_type          = i.dst_type
      src_port          = i.src_port
      dst_port          = i.dst_port
    } if i.protocol == "6" && i.src_port != null && i.dst_port != null
  ] )

  s_egress_rules_udp_src_no_dst = flatten( [ for i in var.standalone_nsg_rules.egress_rules :
    {
      nsg_id            = i.nsg_id
      protocol          = i.protocol
      description       = i.description
      stateless         = i.stateless
      dst               = i.dst
      dst_type          = i.dst_type
      src_port          = i.src_port
    } if i.protocol == "17" && i.src_port != null && i.dst_port == null
  ] )
  s_egress_rules_udp_no_src_dst = flatten( [ for i in var.standalone_nsg_rules.egress_rules :
    {
      nsg_id            = i.nsg_id
      protocol          = i.protocol
      description       = i.description
      stateless         = i.stateless
      dst               = i.dst
      dst_type          = i.dst_type
      dst_port          = i.dst_port
    } if i.protocol == "17" && i.src_port == null && i.dst_port != null
  ] )
  s_egress_rules_udp_src_dst = flatten( [ for i in var.standalone_nsg_rules.egress_rules :
    {
      nsg_id            = i.nsg_id
      protocol          = i.protocol
      description       = i.description
      stateless         = i.stateless
      dst               = i.dst
      dst_type          = i.dst_type
      src_port          = i.src_port
      dst_port          = i.dst_port
    } if i.protocol == "17" && i.src_port != null && i.dst_port != null
  ] )
  
  s_egress_rules_icmp_type_code = flatten( [ for i in var.standalone_nsg_rules.egress_rules :
    {
      nsg_id            = i.nsg_id
      protocol          = i.protocol
      description       = i.description
      stateless         = i.stateless
      dst               = i.dst
      dst_type          = i.dst_type
      icmp_code         = i.icmp_code
      icmp_type         = i.icmp_type
    } if i.protocol == "1" && i.icmp_code != null && i.icmp_type != null
  ] )
  s_egress_rules_icmp_type_no_code = flatten( [ for i in var.standalone_nsg_rules.egress_rules :
    {
      nsg_id            = i.nsg_id
      protocol          = i.protocol
      description       = i.description
      stateless         = i.stateless
      dst               = i.dst
      dst_type          = i.dst_type
      icmp_type         = i.icmp_type
    } if i.protocol == "1" && i.icmp_code == null && i.icmp_type != null
  ] )

  # EGRESS rules - merged
  egress_rules_other              = concat( local.n_egress_rules_other, local.s_egress_rules_other )
  
  egress_rules_tcp_src_no_dst     = concat( local.n_egress_rules_tcp_src_no_dst, local.s_egress_rules_tcp_src_no_dst )
  egress_rules_tcp_no_src_dst     = concat( local.n_egress_rules_tcp_no_src_dst, local.s_egress_rules_tcp_no_src_dst )
  egress_rules_tcp_src_dst        = concat( local.n_egress_rules_tcp_src_dst, local.s_egress_rules_tcp_src_dst )

  egress_rules_udp_src_no_dst     = concat( local.n_egress_rules_udp_src_no_dst, local.s_egress_rules_udp_src_no_dst )
  egress_rules_udp_no_src_dst     = concat( local.n_egress_rules_udp_no_src_dst, local.s_egress_rules_udp_no_src_dst )
  egress_rules_udp_src_dst        = concat( local.n_egress_rules_udp_src_dst, local.s_egress_rules_udp_src_dst )
  
  egress_rules_icmp_type_code     = concat( local.n_egress_rules_icmp_type_code, local.s_egress_rules_icmp_type_code )
  egress_rules_icmp_type_no_code  = concat( local.n_egress_rules_icmp_type_no_code, local.s_egress_rules_icmp_type_no_code )
}

# resource definitions
# ingress - other - any protocol, no src port, no dst port, no icmp_type, no icmp_code
resource "oci_core_network_security_group_security_rule" "ingress_rules_other" {
  count                 = length(local.ingress_rules_other)
  depends_on            = [ oci_core_network_security_group.these ]

  network_security_group_id = local.ingress_rules_other[count.index].nsg_id
  direction             = "INGRESS"
  protocol              = local.ingress_rules_other[count.index].protocol
  description           = local.ingress_rules_other[count.index].description
  source                = local.ingress_rules_other[count.index].src_type == "NSG_NAME" ? local.nsg_ids[local.ingress_rules_other[count.index].src] : local.ingress_rules_other[count.index].src
  source_type           = local.ingress_rules_other[count.index].src_type == "NSG_NAME" ? "NETWORK_SECURITY_GROUP" : local.ingress_rules_other[count.index].src_type
  stateless             = local.ingress_rules_other[count.index].stateless
}

# ingress - tcp, src port, no dst port
resource "oci_core_network_security_group_security_rule" "ingress_rules_tcp_src_no_dst" {
  count                 = length(local.ingress_rules_tcp_src_no_dst)
  depends_on            = [ oci_core_network_security_group.these ]

  network_security_group_id = local.ingress_rules_tcp_src_no_dst[count.index].nsg_id
  direction             = "INGRESS"
  protocol              = local.ingress_rules_tcp_src_no_dst[count.index].protocol
  description           = local.ingress_rules_tcp_src_no_dst[count.index].description
  source                = local.ingress_rules_tcp_src_no_dst[count.index].src_type == "NSG_NAME" ? local.nsg_ids[local.ingress_rules_tcp_src_no_dst[count.index].src] : local.ingress_rules_tcp_src_no_dst[count.index].src
  source_type           = local.ingress_rules_tcp_src_no_dst[count.index].src_type == "NSG_NAME" ? "NETWORK_SECURITY_GROUP" : local.ingress_rules_tcp_src_no_dst[count.index].src_type
  stateless             = local.ingress_rules_tcp_src_no_dst[count.index].stateless

  tcp_options {
    source_port_range {
      min               = local.ingress_rules_tcp_src_no_dst[count.index].src_port.min
      max               = local.ingress_rules_tcp_src_no_dst[count.index].src_port.max
    }
  }
}

# ingress - tcp, no src port, dst port
resource "oci_core_network_security_group_security_rule" "ingress_rules_tcp_no_src_dst" {
  count                 = length(local.ingress_rules_tcp_no_src_dst)
  depends_on            = [ oci_core_network_security_group.these ]

  network_security_group_id = local.ingress_rules_tcp_no_src_dst[count.index].nsg_id
  direction             = "INGRESS"
  protocol              = local.ingress_rules_tcp_no_src_dst[count.index].protocol
  description           = local.ingress_rules_tcp_no_src_dst[count.index].description
  source                = local.ingress_rules_tcp_no_src_dst[count.index].src_type == "NSG_NAME" ? local.nsg_ids[local.ingress_rules_tcp_no_src_dst[count.index].src] : local.ingress_rules_tcp_no_src_dst[count.index].src
  source_type           = local.ingress_rules_tcp_no_src_dst[count.index].src_type == "NSG_NAME" ? "NETWORK_SECURITY_GROUP" : local.ingress_rules_tcp_no_src_dst[count.index].src_type
  stateless             = local.ingress_rules_tcp_no_src_dst[count.index].stateless

  tcp_options {
    destination_port_range {
      min               = local.ingress_rules_tcp_no_src_dst[count.index].dst_port.min
      max               = local.ingress_rules_tcp_no_src_dst[count.index].dst_port.max
    }
  }
}

# ingress - tcp, no src port, dst port
resource "oci_core_network_security_group_security_rule" "ingress_rules_tcp_src_dst" {
  count                 = length(local.ingress_rules_tcp_src_dst)
  depends_on            = [ oci_core_network_security_group.these ]

  network_security_group_id = local.ingress_rules_tcp_src_dst[count.index].nsg_id
  direction             = "INGRESS"
  protocol              = local.ingress_rules_tcp_src_dst[count.index].protocol
  description           = local.ingress_rules_tcp_src_dst[count.index].description
  source                = local.ingress_rules_tcp_src_dst[count.index].src_type == "NSG_NAME" ? local.nsg_ids[local.ingress_rules_tcp_src_dst[count.index].src] : local.ingress_rules_tcp_src_dst[count.index].src
  source_type           = local.ingress_rules_tcp_src_dst[count.index].src_type == "NSG_NAME" ? "NETWORK_SECURITY_GROUP" : local.ingress_rules_tcp_src_dst[count.index].src_type
  stateless             = local.ingress_rules_tcp_src_dst[count.index].stateless

  tcp_options {
    source_port_range {
      min               = local.ingress_rules_tcp_src_dst[count.index].src_port.min
      max               = local.ingress_rules_tcp_src_dst[count.index].src_port.max
    }
    destination_port_range {
      min               = local.ingress_rules_tcp_src_dst[count.index].dst_port.min
      max               = local.ingress_rules_tcp_src_dst[count.index].dst_port.max
    }
  }
}

# ingress - udp, src port, no dst port
resource "oci_core_network_security_group_security_rule" "ingress_rules_udp_src_no_dst" {
  count                 = length(local.ingress_rules_udp_src_no_dst)
  depends_on            = [ oci_core_network_security_group.these ]

  network_security_group_id = local.ingress_rules_udp_src_no_dst[count.index].nsg_id
  direction             = "INGRESS"
  protocol              = local.ingress_rules_udp_src_no_dst[count.index].protocol
  description           = local.ingress_rules_udp_src_no_dst[count.index].description
  source                = local.ingress_rules_udp_src_no_dst[count.index].src_type == "NSG_NAME" ? local.nsg_ids[local.ingress_rules_udp_src_no_dst[count.index].src] : local.ingress_rules_udp_src_no_dst[count.index].src
  source_type           = local.ingress_rules_udp_src_no_dst[count.index].src_type == "NSG_NAME" ? "NETWORK_SECURITY_GROUP" : local.ingress_rules_udp_src_no_dst[count.index].src_type
  stateless             = local.ingress_rules_udp_src_no_dst[count.index].stateless

  udp_options {
    source_port_range {
      min               = local.ingress_rules_udp_src_no_dst[count.index].src_port.min
      max               = local.ingress_rules_udp_src_no_dst[count.index].src_port.max
    }
  }
}

# ingress - udp, no src port, dst port
resource "oci_core_network_security_group_security_rule" "ingress_rules_udp_no_src_dst" {
  count                 = length(local.ingress_rules_udp_no_src_dst)
  depends_on            = [ oci_core_network_security_group.these ]

  network_security_group_id = local.ingress_rules_udp_no_src_dst[count.index].nsg_id
  direction             = "INGRESS"
  protocol              = local.ingress_rules_udp_no_src_dst[count.index].protocol
  description           = local.ingress_rules_udp_no_src_dst[count.index].description
  source                = local.ingress_rules_udp_no_src_dst[count.index].src_type == "NSG_NAME" ? local.nsg_ids[local.ingress_rules_udp_no_src_dst[count.index].src] : local.ingress_rules_udp_no_src_dst[count.index].src
  source_type           = local.ingress_rules_udp_no_src_dst[count.index].src_type == "NSG_NAME" ? "NETWORK_SECURITY_GROUP" : local.ingress_rules_udp_no_src_dst[count.index].src_type
  stateless             = local.ingress_rules_udp_no_src_dst[count.index].stateless

  udp_options {
    destination_port_range {
      min               = local.ingress_rules_udp_no_src_dst[count.index].dst_port.min
      max               = local.ingress_rules_udp_no_src_dst[count.index].dst_port.max
    }
  }
}

# ingress - udp, no src port, dst port
resource "oci_core_network_security_group_security_rule" "ingress_rules_udp_src_dst" {
  count                 = length(local.ingress_rules_udp_src_dst)
  depends_on            = [ oci_core_network_security_group.these ]

  network_security_group_id = local.ingress_rules_udp_src_dst[count.index].nsg_id
  direction             = "INGRESS"
  protocol              = local.ingress_rules_udp_src_dst[count.index].protocol
  description           = local.ingress_rules_udp_src_dst[count.index].description
  source                = local.ingress_rules_udp_src_dst[count.index].src_type == "NSG_NAME" ? local.nsg_ids[local.ingress_rules_udp_src_dst[count.index].src] : local.ingress_rules_udp_src_dst[count.index].src
  source_type           = local.ingress_rules_udp_src_dst[count.index].src_type == "NSG_NAME" ? "NETWORK_SECURITY_GROUP" : local.ingress_rules_udp_src_dst[count.index].src_type
  stateless             = local.ingress_rules_udp_src_dst[count.index].stateless

  udp_options {
    source_port_range {
      min               = local.ingress_rules_udp_src_dst[count.index].src_port.min
      max               = local.ingress_rules_udp_src_dst[count.index].src_port.max
    }
    destination_port_range {
      min               = local.ingress_rules_udp_src_dst[count.index].dst_port.min
      max               = local.ingress_rules_udp_src_dst[count.index].dst_port.max
    }
  }
}

# ingress - icmp, type, no code
resource "oci_core_network_security_group_security_rule" "ingress_rules_icmp_type_no_code" {
  count                 = length(local.ingress_rules_icmp_type_no_code)
  depends_on            = [ oci_core_network_security_group.these ]

  network_security_group_id = local.ingress_rules_icmp_type_no_code[count.index].nsg_id
  direction             = "INGRESS"
  protocol              = local.ingress_rules_icmp_type_no_code[count.index].protocol
  description           = local.ingress_rules_icmp_type_no_code[count.index].description
  source                = local.ingress_rules_icmp_type_no_code[count.index].src_type == "NSG_NAME" ? local.nsg_ids[local.ingress_rules_icmp_type_no_code[count.index].src] : local.ingress_rules_icmp_type_no_code[count.index].src
  source_type           = local.ingress_rules_icmp_type_no_code[count.index].src_type == "NSG_NAME" ? "NETWORK_SECURITY_GROUP" : local.ingress_rules_icmp_type_no_code[count.index].src_type
  stateless             = local.ingress_rules_icmp_type_no_code[count.index].stateless

  icmp_options {
    type                = local.ingress_rules_icmp_type_no_code.icmp_type
  }
}

# ingress - icmp, type, code
resource "oci_core_network_security_group_security_rule" "ingress_rules_icmp_type_code" {
  count                 = length(local.ingress_rules_icmp_type_code)
  depends_on            = [ oci_core_network_security_group.these ]

  network_security_group_id = local.ingress_rules_icmp_type_code[count.index].nsg_id
  direction             = "INGRESS"
  protocol              = local.ingress_rules_icmp_type_code[count.index].protocol
  description           = local.ingress_rules_icmp_type_code[count.index].description
  source                = local.ingress_rules_icmp_type_code[count.index].src_type == "NSG_NAME" ? local.nsg_ids[local.ingress_rules_icmp_type_code[count.index].src] : local.ingress_rules_icmp_type_code[count.index].src
  source_type           = local.ingress_rules_icmp_type_code[count.index].src_type == "NSG_NAME" ? "NETWORK_SECURITY_GROUP" : local.ingress_rules_icmp_type_code[count.index].src_type
  stateless             = local.ingress_rules_icmp_type_code[count.index].stateless

  icmp_options {
    type                = local.ingress_rules_icmp_type_code.icmp_type
    code                = local.ingress_rules_icmp_type_code.icmp_code
  }
}




# egress - other - any protocol, no src port, no dst port, no icmp_type, no icmp_code
resource "oci_core_network_security_group_security_rule" "egress_rules_other" {
  count                 = length(local.egress_rules_other)
  depends_on            = [ oci_core_network_security_group.these ]

  network_security_group_id = local.egress_rules_other[count.index].nsg_id
  direction             = "EGRESS"
  protocol              = local.egress_rules_other[count.index].protocol
  description           = local.egress_rules_other[count.index].description
  destination           = local.egress_rules_other[count.index].dst_type == "NSG_NAME" ? local.nsg_ids[local.egress_rules_other[count.index].dst] : local.egress_rules_other[count.index].dst
  destination_type      = local.egress_rules_other[count.index].dst_type == "NSG_NAME" ? "NETWORK_SECURITY_GROUP" : local.egress_rules_other[count.index].dst_type
  stateless             = local.egress_rules_other[count.index].stateless
}

# egress - tcp, src port, no dst port
resource "oci_core_network_security_group_security_rule" "egress_rules_tcp_src_no_dst" {
  count                 = length(local.egress_rules_tcp_src_no_dst)
  depends_on            = [ oci_core_network_security_group.these ]

  network_security_group_id = local.egress_rules_tcp_src_no_dst[count.index].nsg_id
  direction             = "EGRESS"
  protocol              = local.egress_rules_tcp_src_no_dst[count.index].protocol
  description           = local.egress_rules_tcp_src_no_dst[count.index].description
  destination           = local.egress_rules_tcp_src_no_dst[count.index].dst_type == "NSG_NAME" ? local.nsg_ids[local.egress_rules_tcp_src_no_dst[count.index].dst] : local.egress_rules_tcp_src_no_dst[count.index].dst
  destination_type      = local.egress_rules_tcp_src_no_dst[count.index].dst_type == "NSG_NAME" ? "NETWORK_SECURITY_GROUP" : local.egress_rules_tcp_src_no_dst[count.index].dst_type
  stateless             = local.egress_rules_tcp_src_no_dst[count.index].stateless

  tcp_options {
    source_port_range {
      min               = local.egress_rules_tcp_src_no_dst[count.index].src_port.min
      max               = local.egress_rules_tcp_src_no_dst[count.index].src_port.max
    }
  }
}

# egress - tcp, no src port, dst port
resource "oci_core_network_security_group_security_rule" "egress_rules_tcp_no_src_dst" {
  count                 = length(local.egress_rules_tcp_no_src_dst)
  depends_on            = [ oci_core_network_security_group.these ]

  network_security_group_id = local.egress_rules_tcp_no_src_dst[count.index].nsg_id
  direction             = "EGRESS"
  protocol              = local.egress_rules_tcp_no_src_dst[count.index].protocol
  description           = local.egress_rules_tcp_no_src_dst[count.index].description
  destination           = local.egress_rules_tcp_no_src_dst[count.index].dst_type == "NSG_NAME" ? local.nsg_ids[local.egress_rules_tcp_no_src_dst[count.index].dst] : local.egress_rules_tcp_no_src_dst[count.index].dst
  destination_type      = local.egress_rules_tcp_no_src_dst[count.index].dst_type == "NSG_NAME" ? "NETWORK_SECURITY_GROUP" : local.egress_rules_tcp_no_src_dst[count.index].dst_type
  stateless             = local.egress_rules_tcp_no_src_dst[count.index].stateless

  tcp_options {
    destination_port_range {
      min               = local.egress_rules_tcp_no_src_dst[count.index].dst_port.min
      max               = local.egress_rules_tcp_no_src_dst[count.index].dst_port.max
    }
  }
}

# egress - tcp, no src port, dst port
resource "oci_core_network_security_group_security_rule" "egress_rules_tcp_src_dst" {
  count                 = length(local.egress_rules_tcp_src_dst)
  depends_on            = [ oci_core_network_security_group.these ]

  network_security_group_id = local.egress_rules_tcp_src_dst[count.index].nsg_id
  direction             = "EGRESS"
  protocol              = local.egress_rules_tcp_src_dst[count.index].protocol
  description           = local.egress_rules_tcp_src_dst[count.index].description
  destination           = local.egress_rules_tcp_src_dst[count.index].dst_type == "NSG_NAME" ? local.nsg_ids[local.egress_rules_tcp_src_dst[count.index].dst] : local.egress_rules_tcp_src_dst[count.index].dst
  destination_type      = local.egress_rules_tcp_src_dst[count.index].dst_type == "NSG_NAME" ? "NETWORK_SECURITY_GROUP" : local.egress_rules_tcp_src_dst[count.index].dst_type
  stateless             = local.egress_rules_tcp_src_dst[count.index].stateless

  tcp_options {
    source_port_range {
      min               = local.egress_rules_tcp_src_dst[count.index].dst_port.min
      max               = local.egress_rules_tcp_src_dst[count.index].dst_port.max
    }
    destination_port_range {
      min               = local.egress_rules_tcp_src_dst[count.index].dst_port.min
      max               = local.egress_rules_tcp_src_dst[count.index].dst_port.max
    }
  }
}

# egress - udp, src port, no dst port
resource "oci_core_network_security_group_security_rule" "egress_rules_udp_src_no_dst" {
  count                 = length(local.egress_rules_udp_src_no_dst)
  depends_on            = [ oci_core_network_security_group.these ]

  network_security_group_id = local.egress_rules_udp_src_no_dst[count.index].nsg_id
  direction             = "EGRESS"
  protocol              = local.egress_rules_udp_src_no_dst[count.index].protocol
  description           = local.egress_rules_udp_src_no_dst[count.index].description
  destination           = local.egress_rules_udp_src_no_dst[count.index].dst_type == "NSG_NAME" ? local.nsg_ids[local.egress_rules_udp_src_no_dst[count.index].dst] : local.egress_rules_udp_src_no_dst[count.index].dst
  destination_type      = local.egress_rules_udp_src_no_dst[count.index].dst_type == "NSG_NAME" ? "NETWORK_SECURITY_GROUP" : local.egress_rules_udp_src_no_dst[count.index].dst_type
  stateless             = local.egress_rules_udp_src_no_dst[count.index].stateless

  udp_options {
    source_port_range {
      min               = local.egress_rules_udp_src_no_dst[count.index].dst_port.min
      max               = local.egress_rules_udp_src_no_dst[count.index].dst_port.max
    }
  }
}

# egress - udp, no src port, dst port
resource "oci_core_network_security_group_security_rule" "egress_rules_udp_no_src_dst" {
  count                 = length(local.egress_rules_udp_no_src_dst)
  depends_on            = [ oci_core_network_security_group.these ]

  network_security_group_id = local.egress_rules_udp_no_src_dst[count.index].nsg_id
  direction             = "EGRESS"
  protocol              = local.egress_rules_udp_no_src_dst[count.index].protocol
  description           = local.egress_rules_udp_no_src_dst[count.index].description
  destination           = local.egress_rules_udp_no_src_dst[count.index].dst_type == "NSG_NAME" ? local.nsg_ids[local.egress_rules_udp_no_src_dst[count.index].dst] : local.egress_rules_udp_no_src_dst[count.index].dst
  destination_type      = local.egress_rules_udp_no_src_dst[count.index].dst_type == "NSG_NAME" ? "NETWORK_SECURITY_GROUP" : local.egress_rules_udp_no_src_dst[count.index].dst_type
  stateless             = local.egress_rules_udp_no_src_dst[count.index].stateless

  udp_options {
    destination_port_range {
      min               = local.egress_rules_udp_no_src_dst[count.index].dst_port.min
      max               = local.egress_rules_udp_no_src_dst[count.index].dst_port.max
    }
  }
}

# egress - udp, no src port, dst port
resource "oci_core_network_security_group_security_rule" "egress_rules_udp_src_dst" {
  count                 = length(local.egress_rules_udp_src_dst)
  depends_on            = [ oci_core_network_security_group.these ]

  network_security_group_id = local.egress_rules_udp_src_dst[count.index].nsg_id
  direction             = "EGRESS"
  protocol              = local.egress_rules_udp_src_dst[count.index].protocol
  description           = local.egress_rules_udp_src_dst[count.index].description
  destination           = local.egress_rules_udp_src_dst[count.index].dst_type == "NSG_NAME" ? local.nsg_ids[local.egress_rules_udp_src_dst[count.index].dst] : local.egress_rules_udp_src_dst[count.index].dst
  destination_type      = local.egress_rules_udp_src_dst[count.index].dst_type == "NSG_NAME" ? "NETWORK_SECURITY_GROUP" : local.egress_rules_udp_src_dst[count.index].dst_type
  stateless             = local.egress_rules_udp_src_dst[count.index].stateless

  udp_options {
    source_port_range {
      min               = local.egress_rules_udp_src_dst[count.index].dst_port.min
      max               = local.egress_rules_udp_src_dst[count.index].dst_port.max
    }
    destination_port_range {
      min               = local.egress_rules_udp_src_dst[count.index].dst_port.min
      max               = local.egress_rules_udp_src_dst[count.index].dst_port.max
    }
  }
}

# egress - icmp, type, no code
resource "oci_core_network_security_group_security_rule" "egress_rules_icmp_type_no_code" {
  count                 = length(local.egress_rules_icmp_type_no_code)
  depends_on            = [ oci_core_network_security_group.these ]

  network_security_group_id = local.egress_rules_icmp_type_no_code[count.index].nsg_id
  direction             = "EGRESS"
  protocol              = local.egress_rules_icmp_type_no_code[count.index].protocol
  description           = local.egress_rules_icmp_type_no_code[count.index].description
  destination           = local.egress_rules_icmp_type_no_code[count.index].dst_type == "NSG_NAME" ? local.nsg_ids[local.egress_rules_icmp_type_no_code[count.index].dst] : local.egress_rules_icmp_type_no_code[count.index].dst
  destination_type      = local.egress_rules_icmp_type_no_code[count.index].dst_type == "NSG_NAME" ? "NETWORK_SECURITY_GROUP" : local.egress_rules_icmp_type_no_code[count.index].dst_type
  stateless             = local.egress_rules_icmp_type_no_code[count.index].stateless

  icmp_options {
    type                = local.egress_rules_icmp_type_no_code.icmp_type
  }
}

# egress - icmp, type, code
resource "oci_core_network_security_group_security_rule" "egress_rules_icmp_type_code" {
  count                 = length(local.egress_rules_icmp_type_code)
  depends_on            = [ oci_core_network_security_group.these ]

  network_security_group_id = local.egress_rules_icmp_type_code[count.index].nsg_id
  direction             = "EGRESS"
  protocol              = local.egress_rules_icmp_type_code[count.index].protocol
  description           = local.egress_rules_icmp_type_code[count.index].description
  destination           = local.egress_rules_icmp_type_code[count.index].dst_type == "NSG_NAME" ? local.nsg_ids[local.egress_rules_icmp_type_code[count.index].dst] : local.egress_rules_icmp_type_code[count.index].dst
  destination_type      = local.egress_rules_icmp_type_code[count.index].dst_type == "NSG_NAME" ? "NETWORK_SECURITY_GROUP" : local.egress_rules_icmp_type_code[count.index].dst_type
  stateless             = local.egress_rules_icmp_type_code[count.index].stateless

  icmp_options {
    type                = local.egress_rules_icmp_type_code.icmp_type
    code                = local.egress_rules_icmp_type_code.icmp_code
  }
}