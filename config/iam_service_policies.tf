# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "lz_os_management_policies" {
    source = "../modules/iam/iam-policy"
    providers = { oci = oci.home }
    policies = {
        ("${var.service_label}-os-management-policy") = {
            compartment_id = var.tenancy_ocid
            description    = "OS Management service policy."
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
            description    = "Cloud Guard service policy."
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

module "lz_vss_policies" {
    source = "../modules/iam/iam-policy"
    providers = { oci = oci.home }
    policies = {
        ("${var.service_label}-vss-policy") = {
            compartment_id = var.tenancy_ocid
            description    = "Vulnerability Scanning service policy."
            statements     = ["Allow service vulnerability-scanning-service to manage instances in tenancy",
                              "Allow service vulnerability-scanning-service to read compartments in tenancy",
                              "Allow service vulnerability-scanning-service to read vnics in tenancy",
                              "Allow service vulnerability-scanning-service to read vnic-attachments in tenancy"]
        }
    }
}