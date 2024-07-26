# # Copyright (c) 2023 Oracle and/or its affiliates.
# # Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  policies_configuration = {
    supplied_policies : {
      "POLICY" : {
        name : "${var.service_label}-CG-Service-Policy"
        description : "Cloud Guard Policy Statements."
        compartment_id : var.tenancy_ocid
        statements : [
          "allow service cloudguard to manage cloudevents-rules in tenancy",
          "allow service cloudguard to read all-resources in tenancy", # Consider using Manage for All Remediations #
          "allow service cloudguard to use network-security-groups in tenancy"
        ]
      }
    }
  }

  cloud_guard_configuration = {
    depends_on = [module.policies_configuration]
    #tenancy_ocid = var.tenancy_ocid
    enable           = var.configure_cloud_guard
    reporting_region = var.cloud_guard_reporting_region != null ? var.cloud_guard_reporting_region : local.regions_map[local.home_region_key]

    targets = {
      CLOUD-GUARD-TARGET-2 = {
        name               = "${var.service_label}-cloud-guard-root-target"
        resource_id        = var.tenancy_ocid
        use_cloned_recipes = var.configure_cloud_guard
      }
    }
  }
}

module "policies_configuration" {
  providers              = { oci = oci.home }
  count                  = var.configure_cloud_guard ? 1 : 0
  tenancy_ocid           = var.tenancy_ocid
  source                 = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam//policies?ref=v0.2.1" //compartments?ref=v0.1.6
  policies_configuration = local.policies_configuration
}

module "cloud_guard_configuration" {
  count                     = var.configure_cloud_guard ? 1 : 0
  providers                 = { oci = oci.home }
  source                    = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-security//cloud-guard?ref=v0.1.4" //compartments?ref=v0.1.6
  cloud_guard_configuration = local.cloud_guard_configuration
  tenancy_ocid              = var.tenancy_ocid
}
