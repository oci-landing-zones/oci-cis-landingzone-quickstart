# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  compartments = merge(
    { for i in [1] : ("WORKLOAD-CMP") => {
      name : var.workload_compartment_name,
      description : "Application Workload compartment",
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
 new_compartments = {
      (local.appdev_compartment_key) : {
      name : local.provided_appdev_compartment_name
      ocid : local.appdev_compartment_id
      cislz_metadata : {
        "cislz-cmp-type":"application",
        # "cislz-consumer-groups-security":"${local.security_admin_group_name}",
        # "cislz-consumer-groups-application":"${local.appdev_admin_group_name}",
        "cislz-consumer-groups-database":"${var.database_workload_compartment_user_group_name}",
        # "cislz-consumer-groups-network":"${local.network_admin_group_name}",
        # "cislz-consumer-groups-storage":"${local.storage_admin_group_name}",
        # "cislz-consumer-groups-exainfra":"${local.exainfra_admin_group_name}",
        # "cislz-consumer-groups-dyn-compute-agent":"${local.appdev_computeagent_dynamic_group_name}"
      }
    }
   
    (local.database_compartment_key) : {
      name : local.provided_database_compartment_name
      ocid : local.database_compartment_id
      cislz_metadata : {
        "cislz-cmp-type":"database",
        # "cislz-consumer-groups-security":"${local.security_admin_group_name}",
        "cislz-consumer-groups-application":"${var.database_workload_compartment_user_group_name}",
      #   "cislz-consumer-groups-database":"${local.database_admin_group_name}",
      #   "cislz-consumer-groups-network":"${local.network_admin_group_name}",
      #   "cislz-consumer-groups-storage":"${local.storage_admin_group_name}",
      #   "cislz-consumer-groups-exainfra":"${local.exainfra_admin_group_name}",
      #   "cislz-consumer-groups-dyn-database-kms":"${local.database_kms_dynamic_group_name}"
      # }
    }
    }
 }

  
  compartment_policies = [for k, v in module.cislz_compartments.compartments : {
    name = v.name,
    id   = v.id,
    freeform_tags = v.freeform_tags }]

}



module "cislz_compartments" {
  source                     = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam-compartments.git"
  compartments               = local.compartments
  enable_compartments_delete = true
}

module "cislz_policies" {
  tenancy_id = var.tenancy_ocid
  source     = "github.com/andrecorreaneto/terraform-oci-cis-landing-zone-policies"
  target_compartments = local.compartment_policies
  enable_debug = true
}