# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
#--------------------------------------------------------------------------
#-- Any of these custom variables can be overriden in a _override.tf file.
#--------------------------------------------------------------------------  
  custom_service_policy_defined_tags = null
  custom_service_policy_freeform_tags = null
}

module "lz_services_policy" {
  depends_on = [null_resource.wait_on_compartments]
  count = var.extend_landing_zone_to_new_region == false && var.enable_template_policies == false && local.use_existing_root_cmp_grants == false ? 1 : 0
  source = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam//policies?ref=v0.1.7"
  providers = { oci = oci.home }
  tenancy_ocid = var.tenancy_ocid
  policies_configuration = local.services_policies_configuration
}

module "lz_oke_clusters_policy" {
  depends_on = [null_resource.wait_on_compartments]
  count = var.extend_landing_zone_to_new_region == false && var.enable_template_policies == false ? 1 : 0
  source = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam//policies?ref=v0.1.7"
  providers = { oci = oci.home }
  tenancy_ocid = var.tenancy_ocid
  policies_configuration = local.oke_clusters_policy_configuration
}

locals {
#--------------------------------------------------------------------------
#-- These variables are NOT meant to be overriden.
#--------------------------------------------------------------------------  
  default_service_policy_defined_tags = null
  default_service_policy_freeform_tags = local.landing_zone_tags

  service_policy_defined_tags = local.custom_service_policy_defined_tags != null ? merge(local.custom_service_policy_defined_tags, local.default_service_policy_defined_tags) : local.default_service_policy_defined_tags
  service_policy_freeform_tags = local.custom_service_policy_freeform_tags != null ? merge(local.custom_service_policy_freeform_tags, local.default_service_policy_freeform_tags) : local.default_service_policy_freeform_tags

  cloud_guard_statements = ["Allow service cloudguard to read all-resources in tenancy",
                            "Allow service cloudguard to use network-security-groups in tenancy"]

  vss_statements = ["Allow service vulnerability-scanning-service to manage instances in tenancy",
                    "Allow service vulnerability-scanning-service to read compartments in tenancy",
                    "Allow service vulnerability-scanning-service to read repos in tenancy",
                    "Allow service vulnerability-scanning-service to read vnics in tenancy",
                    "Allow service vulnerability-scanning-service to read vnic-attachments in tenancy"]

  os_mgmt_statements = ["Allow service osms to read instances in tenancy"]

  # The name of the File Storage service user depends on your realm . 
  # For realms with realm key numbers of 10 or less, the pattern for the File Storage service user is FssOc<n>Prod, where n is the realm key number. 
  # Realms with a realm key number greater than 10 have a service user of fssocprod.
  # https://docs.oracle.com/en-us/iaas/Content/File/Tasks/encrypt-file-system.htm
  realm = split(".",trimprefix(data.oci_identity_tenancy.this.id, "ocid1.tenancy."))[0]
  fss_principal_name = substr(local.realm,2,10) <= 10 ? "Fss${local.realm}Prod" : "fssocprod"

  object_storage_service_principals = join(",", [for region in data.oci_identity_region_subscriptions.these.region_subscriptions : "objectstorage-${region.region_name}"])

  keys_access_statements =  ["Allow service blockstorage, oke, streaming, ${local.fss_principal_name}, ${local.object_storage_service_principals} to use keys in tenancy"]

  services_policy = { 
    ("${var.service_label}-services-policy") : {
      compartment_ocid = var.tenancy_ocid
      name             = "${var.service_label}-services-policy"
      description      = "CIS Landing Zone policy for OCI services."
      statements       = concat(local.cloud_guard_statements, local.vss_statements, local.os_mgmt_statements, local.keys_access_statements)
      defined_tags     = local.service_policy_defined_tags
      freeform_tags    = local.service_policy_freeform_tags
    }
  } 

  services_policies_configuration = {
    enable_cis_benchmark_checks : true
    supplied_policies : local.services_policy
  }

  # Grants allowing OKE clusters to use Native Pod Networking (NPN) and to use network resources in the Network compartment.
  # In CIS Landing Zone, OKE clusters are defined in the AppDev compartment, while the network resources are defined in the Network compartment.
  # Reference: https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengpodnetworking_topic-OCI_CNI_plugin.htm
  oke_clusters_statements = ["allow any-user to manage instances in compartment ${local.appdev_compartment_name} where all { request.principal.type = 'cluster', request.principal.compartment.id = '${local.appdev_compartment_id}' }",
                            "allow any-user to use private-ips in compartment ${local.network_compartment_name} where all { request.principal.type = 'cluster', request.principal.compartment.id = '${local.appdev_compartment_id}' }",
                            "allow any-user to use network-security-groups in compartment ${local.network_compartment_name} where all { request.principal.type = 'cluster', request.principal.compartment.id = '${local.appdev_compartment_id}' }",
                            "allow any-user to use subnets in compartment ${local.network_compartment_name} where all { request.principal.type = 'cluster', request.principal.compartment.id = '${local.appdev_compartment_id}' }"]

  oke_clusters_policy = { 
    ("${var.service_label}-oke-clusters-policy") : {
      compartment_ocid = local.enclosing_compartment_id
      name             = "${var.service_label}-oke-clusters-policy"
      description      = "Landing Zone policy for OKE clusters. It allows OKE clusters to use Native Pod Networking (NPN) and to use network resources in the Network compartment."
      statements       = local.oke_clusters_statements
      defined_tags     = local.service_policy_defined_tags
      freeform_tags    = local.service_policy_freeform_tags
    }
  } 

  oke_clusters_policy_configuration = {
    enable_cis_benchmark_checks : true
    supplied_policies : local.oke_clusters_policy
  }                         
}  
