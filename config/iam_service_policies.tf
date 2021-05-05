module "service_policies" {
    source = "../modules/iam/iam-policy"
    providers = { oci = oci.home }
    policies = {
        ("${var.service_label}-OS-ManagementAcess-Policy") = {
            compartment_id = local.parent_compartment_id
            description    = "Policy to allow the OS Management service permission to read instance information in ${local.policy_level}."
            statements     = ["Allow service osms to read instances in ${local.policy_level}"]
        },
        ("${var.service_label}-Cloud-GuardAccess-Policy") = {
            compartment_id = local.parent_compartment_id
            description    = "Policy for Cloud Guard to review ${local.policy_level}"
            statements     = ["allow service cloudguard to read keys in ${local.policy_level}",
                            "allow service cloudguard to read compartments in ${local.policy_level}",
                            "allow service cloudguard to read tenancies in ${local.policy_level}",
                            "allow service cloudguard to read audit-events in ${local.policy_level}",
                            "allow service cloudguard to read compute-management-family in ${local.policy_level}",
                            "allow service cloudguard to read instance-family in ${local.policy_level}",
                            "allow service cloudguard to read virtual-network-family in ${local.policy_level}",
                            "allow service cloudguard to read volume-family in ${local.policy_level}",
                            "allow service cloudguard to read database-family in ${local.policy_level}",
                            "allow service cloudguard to read object-family in ${local.policy_level}",
                            "allow service cloudguard to read load-balancers in ${local.policy_level}",
                            "allow service cloudguard to read users in ${local.policy_level}",
                            "allow service cloudguard to read groups in ${local.policy_level}",
                            "allow service cloudguard to read policies in ${local.policy_level}",
                            "allow service cloudguard to read dynamic-groups in ${local.policy_level}",
                            "allow service cloudguard to read authentication-policies in ${local.policy_level}",
                            "allow service cloudguard to use network-security-groups in ${local.policy_level}"]
        }
    }
}