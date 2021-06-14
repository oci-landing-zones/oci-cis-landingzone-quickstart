/* # Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform changes the VCN's default security list, so that only ICMP traffic is allowed.

resource "oci_core_default_security_list" "default_security_list" {
  manage_default_resource_id = module.cis_vcn.vcn.default_security_list_id
  ingress_security_rules {
    protocol  = "1"
    stateless = false
    source    = local.anywhere
    icmp_options {
      type = 3
      code = 4
    }
  }
  ingress_security_rules {
    protocol  = "1"
    stateless = false
    source    = var.vcn_cidr
    icmp_options {
      type = 3
      code = null
    }
  }
}

resource "oci_core_default_security_list" "dmz_default_security_list" {
  count                      = var.hub_spoke_architecture == true ? 1 : 0
  manage_default_resource_id = module.cis_dmz_vcn[0].vcn.default_security_list_id
  ingress_security_rules {
    protocol  = "1"
    stateless = false
    source    = local.anywhere
    icmp_options {
      type = 3
      code = 4
    }
  }
  ingress_security_rules {
    protocol  = "1"
    stateless = false
    source    = var.dmz_vcn_cidr
    icmp_options {
      type = 3
      code = null
    }
  }
}


resource "oci_core_default_security_list" "spoke2_default_security_list" {
  count                      = var.hub_spoke_architecture == true ? 1 : 0
  manage_default_resource_id = module.cis_spoke2_vcn[0].vcn.default_security_list_id
  ingress_security_rules {
    protocol  = "1"
    stateless = false
    source    = local.anywhere
    icmp_options {
      type = 3
      code = 4
    }
  }
  ingress_security_rules {
    protocol  = "1"
    stateless = false
    source    = var.spoke2_vcn_cidr
    icmp_options {
      type = 3
      code = null
    }
  }
} */