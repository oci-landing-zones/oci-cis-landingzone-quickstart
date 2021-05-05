### Landing Zone provisioning policy
module "lz_provisioning_group_policy" {
  source     = "../modules/iam/iam-policy"
  depends_on = [module.lz_top_compartment, module.lz_provisioning_group]
  policies = {
    (local.provisioning_policy_name) = {
      compartment_id = var.tenancy_ocid
      description    = "Policy allowing ${local.provisioning_group_name} group to provision the CIS Landing Zone in a tenancy."
      statements = ["Allow group ${local.provisioning_group_name} to read objectstorage-namespaces in tenancy", # ability to query for object store namespace for creating buckets
                    "Allow group ${local.provisioning_group_name} to use tag-namespaces in tenancy",            # ability to check the tag-namespaces at the tenancy level and to apply tag defaults
                    "Allow group ${local.provisioning_group_name} to read tag-defaults in tenancy",             # ability to check for tag-defaults at the tenancy level
                    "Allow group ${local.provisioning_group_name} to manage cloudevents-rules in tenancy",      # for events: create IAM event rules at the tenancy level 
                    "Allow group ${local.provisioning_group_name} to inspect compartments in tenancy",          # for events: access to resources in compartments to select rules actions
                    "Allow group ${local.provisioning_group_name} to manage cloud-guard-family in tenancy",     # ability to enable Cloud Guard, which can be done only at the tenancy level
                    "Allow group ${local.provisioning_group_name} to manage compartments in compartment ${local.top_compartment_name}",
                    "Allow group ${local.provisioning_group_name} to manage policies in compartment ${local.top_compartment_name}",
                    "Allow group ${local.provisioning_group_name} to manage virtual-network-family in compartment ${local.top_compartment_name}",
                    "Allow group ${local.provisioning_group_name} to manage logging-family in compartment ${local.top_compartment_name}",
                    "Allow group ${local.provisioning_group_name} to manage tag-namespaces in compartment ${local.top_compartment_name}",
                    "Allow group ${local.provisioning_group_name} to manage tag-defaults in compartment ${local.top_compartment_name}",
                    "Allow group ${local.provisioning_group_name} to manage object-family in compartment ${local.top_compartment_name}",
                    "Allow group ${local.provisioning_group_name} to manage vaults in compartment ${local.top_compartment_name}",
                    "Allow group ${local.provisioning_group_name} to manage keys in compartment ${local.top_compartment_name}",
                    "Allow group ${local.provisioning_group_name} to use key-delegate in compartment ${local.top_compartment_name}",
                    "Allow group ${local.provisioning_group_name} to manage ons-family in compartment ${local.top_compartment_name}",
                    "Allow group ${local.provisioning_group_name} to manage vss-family in compartment ${local.top_compartment_name}"]
    }
  }
}

### Landing Zone security admin policy
module "lz_security_admin_policy" {
  count             = var.create_lz_groups == true ? 1 : 0
  source                = "../modules/iam/iam-policy"
  depends_on            = [module.lz_security_admin_policy] ### Explicitly declaring dependencies on the group and compartments modules.
  policies              = {
    (local.security_admin_policy_name) = {
      compartment_id    = var.tenancy_ocid
      description       = "Policy allowing ${local.security_admin_group_name} group to manage security related services required by the Landing Zone."
      statements        = ["Allow group ${local.security_admin_group_name} to manage cloudevents-rules in tenancy",
                          #"Allow group ${local.security_admin_group_name} to manage tag-namespaces in tenancy",
                          #"Allow group ${local.security_admin_group_name} to manage tag-defaults in tenancy",
                          "Allow group ${local.security_admin_group_name} to manage cloud-guard-family in tenancy",
                          "Allow group ${local.security_admin_group_name} to read audit-events in tenancy",
                          "Allow group ${local.security_admin_group_name} to read tenancies in tenancy",
                          "Allow group ${local.security_admin_group_name} to read objectstorage-namespaces in tenancy",
                          "Allow group ${local.security_admin_group_name} to read app-catalog-listing in tenancy",
                          "Allow group ${local.security_admin_group_name} to read instance-images in tenancy",
                          "Allow group ${local.security_admin_group_name} to inspect buckets in tenancy"]
    }
  }
}