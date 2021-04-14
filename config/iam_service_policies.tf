module "cis_service_policies" {
    source = "../modules/iam/iam-policy"
    providers = { oci = oci.home }
    policies = {
        ("${var.service_label}-OS-ManagementAcess-Policy") = {
            compartment_id = var.tenancy_ocid
            description    = "Policy to allow the OS Management service permission to read instance information in the tenancy."
            statements     = ["allow service osms to read instances in tenancy"]
        },
        ("${var.service_label}-Cloud-GuardAccess-Policy") = {
            compartment_id = var.tenancy_ocid
            description    = "Policy for Cloud Guard to be able to review a tenancy"
            statements     = ["allow service cloudguard to read keys in tenancy",
                            "allow service cloudguard to read compartments in tenancy",
                            "allow service cloudguard to read tenancies in tenancy",
                            "allow service cloudguard to read audit-events in tenancy",
                            "allow service cloudguard to read compute-management-family in tenancy",
                            "allow service cloudguard to read instance-family in tenancy",
                            "allow service cloudguard to read virtual-network-family in tenancy",
                            "allow service cloudguard to read volume-family in tenancy",
                            "allow service cloudguard to read database-family in tenancy",
                            "allow service cloudguard to read object-family in tenancy",
                            "allow service cloudguard to read load-balancers in tenancy",
                            "allow service cloudguard to read users in tenancy",
                            "allow service cloudguard to read groups in tenancy",
                            "allow service cloudguard to read policies in tenancy",
                            "allow service cloudguard to read dynamic-groups in tenancy",
                            "allow service cloudguard to read authentication-policies in tenancy",
                            "allow service cloudguard to use network-security-groups in tenancy"]
        },
        ("${var.service_label}-Vulnerability-Scanning-Policy") = {
            compartment_id = var.tenancy_ocid
            description    = "Policy to allow the Vulnerability Scanning service permission on compute instances in the tenancy."
            statements     = ["allow service vulnerability-scanning-service to manage instances in tenancy",
                               "allow service vulnerability-scanning-service to read compartments in tenancy",
                               "allow service vulnerability-scanning-service to read vnics in tenancy",
                               "allow service vulnerability-scanning-service to read vnic-attachments in tenancy"]
        }
    }
}