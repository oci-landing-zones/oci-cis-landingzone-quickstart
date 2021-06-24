# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration modifies the default security lists for all the VCNs.
### The security rules are driven by NSGs (Network Security Groups). See net_nsgs.tf
### Add security rules as needed.

resource "oci_core_default_security_list" "default_security_list" {
  for_each                   = length(var.dmz_vcn_cidr) == 0 ? module.lz_vcn_spokes.vcns : merge(module.lz_vcn_spokes.vcns, module.lz_vcn_dmz.vcns)
  manage_default_resource_id = each.value.default_security_list_id
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
    source    = each.value.cidr_block
    icmp_options {
      type = 3
      code = null
    }
  }
}