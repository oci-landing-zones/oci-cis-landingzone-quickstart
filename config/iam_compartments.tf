# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration provisions compartments in the tenancy.

module "lz_top_compartment" {
  count     = var.use_enclosing_compartment == true && var.existing_enclosing_compartment_ocid == null ? 1 : 0
  source    = "../modules/iam/iam-compartment"
  providers = { oci = oci.home }
  compartments = {
    (local.default_enclosing_compartment_name) = {
      parent_id   = var.tenancy_ocid
      description = "CIS Landing Zone enclosing compartment, enclosing all Landing Zone compartments."
    }
  }
}

module "lz_compartments" {
  source    = "../modules/iam/iam-compartment"
  providers = { oci = oci.home }
  compartments = {
    (local.security_compartment_name) = {
      parent_id   = local.parent_compartment_id
      description = "CIS Landing Zone compartment for all security related resources: vaults, topics, notifications, logging, scanning, and others."
    },
    (local.network_compartment_name) = {
      parent_id   = local.parent_compartment_id
      description = "CIS Landing Zone compartment for all network related resources: VCNs, subnets, network gateways, security lists, NSGs, load balancers, VNICs, and others."
    },
    (local.appdev_compartment_name) = {
      parent_id   = local.parent_compartment_id
      description = "CIS Landing Zone compartment for all resources related to application development: compute instances, storage, functions, OKE, API Gateway, streaming, and others."
    },
    (local.database_compartment_name) = {
      parent_id   = local.parent_compartment_id
      description = "CIS Landing Zone compartment for all database related resources."
    }
  }
}