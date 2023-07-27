# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

#-- This file supports the creation of tag based policies, which are policies created based on tags that are applied to compartments.
#-- This functionality is supported by the policy module in https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam/tree/main/policies
#-- The default approach is using the supplied policies, defined in iam_policies.tf file.
#-- For using tag based policies, set variable enable_template_policies to true.

locals {
  #------------------------------------------------------------------------------------------------------
  #-- Any of these local variables can be overriden in a _override.tf file
  #------------------------------------------------------------------------------------------------------
  
  custom_cmps_defined_tags  = null
  custom_cmps_freeform_tags = null

  custom_enclosing_compartment_name = null
  custom_security_compartment_name  = null
  custom_network_compartment_name   = null
  custom_appdev_compartment_name    = null
  custom_database_compartment_name  = null
  custom_exainfra_compartment_name  = null
}

module "workload_compartments" {
  source = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam/compartments"
  providers = { oci = oci.home }
  tenancy_ocid = var.tenancy_ocid
  compartments_configuration = local.compartments_configuration
}


locals {
  #----------------------------------------------------------------------- 
  #-- These variables are NOT meant to be overriden.
  #-----------------------------------------------------------------------
  default_template_compartment_defined_tags = null
  default_template_compartment_freeform_tags = local.landing_zone_tags

#   template_policies_defined_tags  = local.custom_template_policies_defined_tags != null ? merge(local.custom_template_policies_defined_tags, local.default_template_compartment_defined_tags) : local.default_template_compartment_defined_tags
#   template_policies_freeform_tags = local.custom_template_policies_freeform_tags != null ? merge(local.custom_template_policies_freeform_tags, local.default_template_compartment_freeform_tags) : local.default_template_compartment_freeform_tags
  
   workload_compartment_key = "Workload-Compartment"
   database_compartment_key = "Workload-DB-Compartment"
   
   enclosing_lz_compartment_id = var.existing_lz_enclosing_compartment_ocid
   enclosing_lz_compartment_name = data.oci_identity_compartment.existing_lz_enclosing_compartment.name 
   
   
   provided_database_compartment_name = local.custom_database_compartment_name != null ? local.custom_database_compartment_name : "${var.service_label}-${var.database_compartment_name}"
   provided_appdev_compartment_name = local.custom_appdev_compartment_name != null ? local.custom_appdev_compartment_name : "${var.service_label}-${var.workload_compartment_name}"

  
    workload_compartments = merge(
    { for i in [1] : local.workload_compartment_key => {
      name : local.provided_appdev_compartment_name,
      description : "Application Workload compartment",
      parent_ocid : local.enclosing_lz_compartment_id,
      defined_tags : local.default_template_compartment_defined_tags,
      freeform_tags : local.default_template_compartment_freeform_tags,
      children : {}
      }
    },

    { for i in [1] : local.database_compartment_key => {
      name : local.provided_database_compartment_name,
      description : "Database compartment for application workload",
      parent_ocid : local.enclosing_lz_compartment_id,
      defined_tags : local.default_template_compartment_defined_tags,
      freeform_tags : local.default_template_compartment_freeform_tags,
      children : {}
      } if var.create_database_compartment
  })
  compartments_configuration = {
    # default_parent_ocid = local.enclosing_lz_compartment_id,
        # default_parent_ocid = null,

    compartments = local.workload_compartments
  }

}