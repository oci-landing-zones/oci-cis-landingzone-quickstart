module "lz_os_management_policies" {
    count = local.use_existing_tenancy_policies == false ? 1 : 0
    source = "../modules/iam/iam-policy"
    providers = { oci = oci.home }
    policies = {
        (local.os_mgmt_policy_name) = {
            compartment_id = local.parent_compartment_id
            description    = "Policy to allow the OS Management service permission to read instance information in ${local.policy_level}."
            statements     = ["Allow service osms to read instances in ${local.policy_level}"]
        }
    }
}

module "lz_cloud_guard_policies" {
    count = local.use_existing_tenancy_policies == false ? 1 : 0
    source = "../modules/iam/iam-policy"
    providers = { oci = oci.home }
    policies = {
        (local.cloud_guard_policy_name) = {
            compartment_id = var.tenancy_ocid
            description    = "Policy for Cloud Guard to review a tenancy."
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