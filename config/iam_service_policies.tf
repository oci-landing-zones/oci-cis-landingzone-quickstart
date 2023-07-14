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
  source = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam/policies"
  providers = { oci = oci.home }
  tenancy_ocid = var.tenancy_ocid
  policies_configuration = var.extend_landing_zone_to_new_region == false && var.enable_template_policies == false ? local.services_policies_configuration : local.empty_services_policies_configuration
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

  realm = split(".",trimprefix(data.oci_identity_tenancy.this.id, "ocid1.tenancy."))[0]

  object_storage_service_principals = join(",", [for region in data.oci_identity_region_subscriptions.these.region_subscriptions : "objectstorage-${region.region_name}"])

  keys_access_statements =  ["Allow service blockstorage, oke, streaming, Fss${local.realm}Prod, ${local.object_storage_service_principals} to use keys in tenancy"]

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

  # Helper object meaning no policies. It satisfies Terraform's ternary operator.
  empty_services_policies_configuration = {
    enable_cis_benchmark_checks : false
    supplied_policies : null
  }

}  
