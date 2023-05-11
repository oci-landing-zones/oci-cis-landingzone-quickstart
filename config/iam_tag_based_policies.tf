# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

#-- This file supports the creation of tag based policies, which are policies created based on tags that are applied to compartments.
#-- This functionality is supported by the policy module in https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam/tree/main/policies
#-- The default approach is using the supplied policies, defined in iam_policies.tf file.
#-- For using tag based policies, set variable enable_tag_based_policies to true.

locals {
  #-------------------------------------------------------------------------- 
  #-- Any of these custom variables can be overriden in a _override.tf file
  #--------------------------------------------------------------------------
  #-- Custom tags applied to tag based policies.
  custom_tag_based_policies_defined_tags = null
  custom_tag_based_policies_freeform_tags = null
}  

module "lz_tag_based_policies" {
  #depends_on = [module.lz_compartments, module.lz_groups, module.lz_dynamic_groups]
  source = "git@github.com:oracle-quickstart/terraform-oci-cis-landing-zone-iam.git//policies"
  providers = { oci = oci.home }
  tenancy_ocid = var.tenancy_ocid
  policies_configuration = var.extend_landing_zone_to_new_region == false && var.enable_tag_based_policies == true ? local.tag_based_policies_configuration : local.empty_tag_based_policies_configuration
}

locals {
  #----------------------------------------------------------------------- 
  #-- These variables are NOT meant to be overriden.
  #-----------------------------------------------------------------------
  default_tag_based_policies_defined_tags = null
  default_tag_based_policies_freeform_tags = local.landing_zone_tags

  tag_based_policies_defined_tags  = local.custom_tag_based_policies_defined_tags != null ? merge(local.custom_tag_based_policies_defined_tags, local.default_tag_based_policies_defined_tags) : local.default_tag_based_policies_defined_tags
  tag_based_policies_freeform_tags = local.custom_tag_based_policies_freeform_tags != null ? merge(local.custom_tag_based_policies_freeform_tags, local.default_tag_based_policies_freeform_tags) : local.default_tag_based_policies_freeform_tags
  
  #------------------------------------------------------------------------
  #----- Policies configuration definition. Input to module.
  #------------------------------------------------------------------------  
  tag_based_policies_configuration = {
    cislz_tag_lookup_value : var.service_label
    enable_cis_benchmark_checks : true
    enable_tenancy_level_template_policies : true
    enable_compartment_level_template_policies : true
    groups_with_tenancy_level_roles : [
      {"name":"${local.cred_admin_group_name}",    "roles":"cred"},
      {"name":"${local.cost_admin_group_name}",    "roles":"cost"},
      {"name":"${local.security_admin_group_name}","roles":"security"},
      {"name":"${local.appdev_admin_group_name}",  "roles":"application"},
      {"name":"${local.auditor_group_name}",       "roles":"auditor"},
      {"name":"${local.database_admin_group_name}","roles":"basic"},
      {"name":"${local.exainfra_admin_group_name}","roles":"basic"},
      {"name":"${local.storage_admin_group_name}", "roles":"basic"},
      {"name":"${local.announcement_reader_group_name}","roles":"announcement-reader"}
    ]
    supplied_compartments : [for k, v in module.lz_compartments.compartments : {"name": v.name, "ocid": v.id, "freeform_tags": v.freeform_tags}]
    supplied_policies : { 
      # Enclosing compartments are not always managed by this configuration, as utilizing an existing enclosing compartment is supported.
      # Hence we cannot rely on the policy module using compartments tags to create tag based policies, as the existing enclosing compartment may not be properly tagged.
      "${var.service_label}-ENCLOSING-COMPARTMENT-POLICY" : {
        name : "${var.service_label}-enclosing-cmp-policy"
        description : "CIS Landing Zone policy for resources at the enclosing compartment."
        compartment_ocid : local.enclosing_compartment_id
        statements : concat(local.iam_admin_grants_on_enclosing_cmp, local.security_admin_grants_on_enclosing_cmp, local.appdev_admin_grants_on_enclosing_cmp) # these variables are defined in iam_policies.tf. 
        defined_tags : local.policies_defined_tags
        freeform_tags : local.policies_freeform_tags
      }  
    }
    defined_tags : local.tag_based_policies_defined_tags
    freeform_tags : local.tag_based_policies_freeform_tags
  }

  # Helper object meaning no policies. It satisfies Terraform's ternary operator.
  empty_tag_based_policies_configuration = {
    cislz_tag_lookup_value : null
    enable_cis_benchmark_checks : false
    enable_tenancy_level_template_policies : false
    enable_compartment_level_template_policies : false
    groups_with_tenancy_level_roles : null
    supplied_compartments : null
    supplied_policies : null
    defined_tags : null
    freeform_tags : null
  }
}
