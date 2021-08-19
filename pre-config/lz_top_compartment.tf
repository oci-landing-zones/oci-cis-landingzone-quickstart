# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration provisions a top compartment for holding all Landing Zone compartments.

module "lz_top_compartments" {
  source       = "../modules/iam/iam-compartment"
  compartments = local.enclosing_compartments
}

