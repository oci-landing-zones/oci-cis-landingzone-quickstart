# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "lz_services_policy" {
    depends_on = [module.lz_dynamic_groups]
    source = "../modules/iam/iam-policy"
    providers = { oci = oci.home }
    policies  = local.use_existing_tenancy_policies == false ? {
        (local.services_policy_name) = {
            compartment_id = var.tenancy_ocid
            description    = "Landing Zone policy for OCI services: Cloud Guard, Vulnerability Scanning and OS Management."
            statements     = concat(local.cloud_guard_statements, local.vss_statements, local.os_mgmt_statements)
        }
    } : {}
}