# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration provisions compartments in the tenancy.

module "cis_compartments" {
  source       = "../modules/iam/iam-compartment"
  providers    = { oci = oci.home }
  tenancy_ocid = var.tenancy_ocid        
  compartments = {
      (local.security_compartment_name) = {
        description = "Compartment for all security related resources."
      },
      (local.network_compartment_name) = {
        description = "Compartment for all network related resources: VCNs, subnets, network gateways, security lists, NSGs, load balancers, VNICs, etc."
      },
      (local.appdev_compartment_name) = {
        description = "Compartment for all resources related to application development: compute, storage, functions, OKE, API Gateway, streaming, etc."
      },
      (local.database_compartment_name) = {
        description = "Compartment for all database related resources."
      }
  }
}