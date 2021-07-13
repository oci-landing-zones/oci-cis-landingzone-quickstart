# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration provisions compartments in the tenancy.

module "lz_top_compartment" {
  count     = var.use_enclosing_compartment == true && var.existing_enclosing_compartment_ocid == null ? 1 : 0
  source    = "../modules/iam/iam-compartment"
  providers = { oci = oci.home }
  compartments = {
    (local.default_enclosing_compartment_name) = {
      parent_id     = var.tenancy_ocid
      description   = "Landing Zone enclosing compartment, enclosing all Landing Zone compartments."
      enable_delete = local.enable_cmp_delete
    }
  }
}

module "lz_compartments" {
  source    = "../modules/iam/iam-compartment"
  providers = { oci = oci.home }
  compartments = {
    (local.security_compartment_name) = {
      parent_id     = local.parent_compartment_id
      description   = "Landing Zone compartment for all security related resources: vaults, topics, notifications, logging, scanning, and others."
      enable_delete = local.enable_cmp_delete
    },
    (local.network_compartment_name) = {
      parent_id     = local.parent_compartment_id
      description   = "Landing Zone compartment for all network related resources: VCNs, subnets, network gateways, security lists, NSGs, load balancers, VNICs, and others."
      enable_delete = local.enable_cmp_delete
    },
    (local.appdev_compartment_name) = {
      parent_id     = local.parent_compartment_id
      description   = "Landing Zone compartment for all resources related to application development: compute instances, storage, functions, OKE, API Gateway, streaming, and others."
      enable_delete = local.enable_cmp_delete
    },
    (local.database_compartment_name) = {
      parent_id     = local.parent_compartment_id
      description   = "Landing Zone compartment for all database related resources."
      enable_delete = local.enable_cmp_delete
    }
  }
}