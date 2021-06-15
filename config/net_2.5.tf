# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform changes the VCN's default security list, so that only ICMP traffic is allowed.

resource "oci_core_default_security_list" "default_security_list" {
  manage_default_resource_id = module.cis_vcn.vcn.default_security_list_id
  ingress_security_rules {
    protocol  = "1"
    stateless = false
    source    = var.public_src_lbr_cidr
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