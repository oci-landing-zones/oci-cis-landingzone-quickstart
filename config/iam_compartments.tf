# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration provisions compartments in the tenancy.

module "cis_top_compartment" {
  count        = var.enclosing_compartment == true && var.existing_enclosing_compartment_ocid == null ? 1 : 0   
  source       = "../modules/iam/iam-compartment"
  providers    = { oci = oci.home }
  compartments = {
    (local.default_enclosing_compartment_name) = {
      parent_id = var.tenancy_ocid
      description = "Top compartment, enclosing all Landing Zone compartments."
    }
  }
}

module "cis_compartments" {
  source          = "../modules/iam/iam-compartment"
  providers       = { oci = oci.home }
  compartments = {
      (local.security_compartment_name) = {
        parent_id   = local.parent_compartment_id
        description = "Compartment for all security related resources: vaults, topics, notifications, logs."
      },
      (local.network_compartment_name) = {
        parent_id   = local.parent_compartment_id
        description = "Compartment for all network related resources: VCNs, subnets, network gateways, security lists, NSGs, load balancers, VNICs."
      },
      (local.appdev_compartment_name) = {
        parent_id   = local.parent_compartment_id
        description = "Compartment for all resources related to application development: functions, OKE, API Gateway, streaming."
      },
      (local.database_compartment_name) = {
        parent_id   = local.parent_compartment_id
        description = "Compartment for all database related resources."
      }
  }
}