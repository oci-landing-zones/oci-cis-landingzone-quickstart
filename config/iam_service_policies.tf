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
  source                        = "../modules/iam/iam-services-policy"
  providers                     = { oci = oci.home }
  depends_on                    = [null_resource.wait_on_compartments]
  tenancy_id                    = var.tenancy_ocid
  service_label                 = var.service_label
  enable_tenancy_level_policies = var.extend_landing_zone_to_new_region == false ? (local.use_existing_root_cmp_grants == true ? false : true) : false
  tenancy_policy_name           = "${var.service_label}-services-policy"
  defined_tags                  = local.service_policy_defined_tags
  freeform_tags                 = local.service_policy_freeform_tags
  policies                      = var.extend_landing_zone_to_new_region == false ? local.service_policies : {}
}

locals {
#--------------------------------------------------------------------------
#-- These variables are NOT meant to be overriden.
#--------------------------------------------------------------------------  
  default_service_policy_defined_tags = null
  default_service_policy_freeform_tags = local.landing_zone_tags

  service_policy_defined_tags = local.custom_service_policy_defined_tags != null ? merge(local.custom_service_policy_defined_tags, local.default_service_policy_defined_tags) : local.default_service_policy_defined_tags
  service_policy_freeform_tags = local.custom_service_policy_freeform_tags != null ? merge(local.custom_service_policy_freeform_tags, local.default_service_policy_freeform_tags) : local.default_service_policy_freeform_tags

  realm = split(".",trimprefix(data.oci_identity_tenancy.this.id, "ocid1.tenancy."))[0]

  service_policies = {
    ("VAULT-GLOBAL-POLICY") = {
      name           = "${var.service_label}-vault-policy"
      compartment_id = local.enclosing_compartment_id
      description    = "Landing Zone policy for OCI services: Blockstorage, OKE and streams to use keys in the ${local.security_compartment.name} compartment."
      statements     = ["Allow service blockstorage, oke, streaming, Fss${local.realm}Prod to use keys in compartment ${local.security_compartment.name}"]
      defined_tags   = local.service_policy_defined_tags
      freeform_tags  = local.service_policy_freeform_tags
    },
    ("VAULT-REGIONAL-POLICY") = {
      name           = "${var.service_label}-vault-${var.region}-policy"
      compartment_id = local.enclosing_compartment_id
      description    = "Landing Zone policy for OCI services: Object Storage in ${var.region} to use keys in the ${local.security_compartment.name} compartment."
      statements     = ["Allow service objectstorage-${var.region} to use keys in compartment ${local.security_compartment.name}"]
      defined_tags   = local.service_policy_defined_tags
      freeform_tags  = local.service_policy_freeform_tags
    }
  }
}  
