# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration provisions a top compartment for holding all Landing Zone compartments.

module "lz_top_compartment" {
  source = "../modules/iam/iam-compartment"
  compartments = {
    (local.top_compartment_name) = {
      parent_id   = var.tenancy_ocid
      description = "Landing Zone top compartment, for enclosing all Landing Zone compartments."
    }
  }
}

