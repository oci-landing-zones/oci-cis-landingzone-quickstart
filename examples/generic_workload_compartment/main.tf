# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  compartments = merge(
    { for i in [1] : ("WORKLOAD-CMP") => {
      name : var.workload_compartment_name,
      description : "Application Workload compartment",
      #parent_id : "<ENTER THE OCID OF THE PARENT COMPARTMENT>", 
      parent_id : var.parent_compartment_id,
      defined_tags : null,
      freeform_tags : { "cislz" : var.landing_zone_prefix,
        "cislz-cmp-type" : "application",
        # "cislz-consumer-groups-network" : "shared-net-admin-group",
        # "cislz-consumer-groups-security" : "shared-sec-admin-group",
        "cislz-consumer-groups-application" : var.workload_compartment_user_group_name,
        # "cislz-consumer-groups-database" : "hr-dev-db-admin-group,hr-prd-db-admin-group" 
      },
      children : {}
      }
    },

    { for i in [1] : ("WORKLOAD-DB-CMP") => {
      name : var.database_compartment_name,
      description : "Database compartment for application workload",
      #parent_id : "<ENTER THE OCID OF THE PARENT COMPARTMENT>", 
      parent_id : var.parent_compartment_id,
      defined_tags : null,
      freeform_tags : { "cislz" : var.landing_zone_prefix,
        "cislz-cmp-type" : "database",
        "cislz-consumer-groups-application" : var.database_workload_compartment_user_group_name,
        # "cislz-consumer-groups-network" : "shared-net-admin-group",
        # "cislz-consumer-groups-security" : "shared-sec-admin-group",
      # "cislz-consumer-groups-application" : "hr-dev-app-admin-group,hr-prd-app-admin-group"
      },
      children : {}
      } if var.create_database_compartment
  })

  compartment_policies = concat([for k, v in module.cislz_compartments.level_1_compartments : {
    name = v.name,
    id   = v.id,
    freeform_tags = v.freeform_tags }],
    [for k, v in module.cislz_compartments.level_2_compartments : {
      name = v.name,
      id   = v.id,
    freeform_tags = v.freeform_tags }],
    [for k, v in module.cislz_compartments.level_3_compartments : {
      name = v.name,
      id   = v.id,
    freeform_tags = v.freeform_tags }],
    [for k, v in module.cislz_compartments.level_4_compartments : {
      name = v.name,
      id   = v.id,
    freeform_tags = v.freeform_tags }],
    [for k, v in module.cislz_compartments.level_5_compartments : {
      name = v.name,
      id   = v.id,
    freeform_tags = v.freeform_tags }],
    [for k, v in module.cislz_compartments.level_6_compartments : {
      name = v.name,
      id   = v.id,
    freeform_tags = v.freeform_tags }]
  )

}



module "cislz_compartments" {
  source                     = "github.com/andrecorreaneto/terraform-oci-cis-landing-zone-compartments"
  compartments               = local.compartments
  enable_compartments_delete = true
}

module "cislz_policies" {
  # depends_on = [
  #   module.cislz_compartments
  # ]
  tenancy_id = var.tenancy_id
  source     = "github.com/andrecorreaneto/terraform-oci-cis-landing-zone-policies"
  #cislz_tag_lookup_value = var.landing_zone_prefix
  target_compartments = local.compartment_policies
  #  enable_compartment_level_template_policies = true
  enable_debug = true
}