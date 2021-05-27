# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "lz_os_management_policies" {
    source = "../modules/iam/iam-policy"
    providers = { oci = oci.home }
    policies = {
        ("${var.service_label}-os-management-policy") = {
            compartment_id = var.tenancy_ocid
            description    = "Policy to allow the OS Management service permission to read instance information in the tenancy."
            statements     = ["Allow service osms to read instances in tenancy"]
        }
    }
}

module "lz_cloud_guard_policies" {
    source = "../modules/iam/iam-policy"
    providers = { oci = oci.home }
    policies = {
        ("${var.service_label}-cloud-guard-policy") = {
            compartment_id = var.tenancy_ocid
            description    = "Policy for Cloud Guard to be able to review a tenancy"
            statements     = ["Allow service cloudguard to read keys in tenancy",
                            "Allow service cloudguard to read compartments in tenancy",
                            "Allow service cloudguard to read tenancies in tenancy",
                            "Allow service cloudguard to read audit-events in tenancy",
                            "Allow service cloudguard to read compute-management-family in tenancy",
                            "Allow service cloudguard to read instance-family in tenancy",
                            "Allow service cloudguard to read virtual-network-family in tenancy",
                            "Allow service cloudguard to read volume-family in tenancy",
                            "Allow service cloudguard to read database-family in tenancy",
                            "Allow service cloudguard to read object-family in tenancy",
                            "Allow service cloudguard to read load-balancers in tenancy",
                            "Allow service cloudguard to read users in tenancy",
                            "Allow service cloudguard to read groups in tenancy",
                            "Allow service cloudguard to read policies in tenancy",
                            "Allow service cloudguard to read dynamic-groups in tenancy",
                            "Allow service cloudguard to read authentication-policies in tenancy",
                            "Allow service cloudguard to use network-security-groups in tenancy"]
        }
    }
}