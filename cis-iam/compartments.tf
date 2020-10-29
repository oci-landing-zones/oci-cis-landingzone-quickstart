module "compartments" {
  source       = "../modules/iam/iam-compartment"
  tenancy_ocid = var.tenancy_ocid        
  compartments = {
      (local.security_compartment_name) = {
        description = "Compartment for all security related resources: vaults."
      },
      (local.network_compartment_name) = {
        description = "Compartment for all network related resources: VCNs, subnets, network gateways, security lists, NSGs, load balancers, VNICs."
      },
      (local.compute_storage_compartment_name) = {
        description = "Compartment for all resources related to compute and storage: compute, block volumes, file storage, object storage."
      },
      (local.appdev_compartment_name) = {
        description = "Compartment for all resources related to application development: functions, OKE, API Gateway, streaming, notifications."
      },
      (local.database_compartment_name) = {
        description = "Compartment for all database related resources."
      }
  }
}