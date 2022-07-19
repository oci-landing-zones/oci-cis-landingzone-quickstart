# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



# module "lz_security_zones" {
#     # depends_on = [ null_resource.slow_down_buckets ]
#     # count = (var.create_service_connector_vcnFlowLogs  == true && lower(var.service_connector_vcnFlowLogs_target) == "objectstorage") ? 1 : 0
    
#     source       = "../modules/security/security-zones"
#     providers = { oci = oci.home }

#     tenancy_ocid = var.tenancy_ocid
#     service_label = var.service_label
#     compartment_id = local.enclosing_compartment_id
# }

module "lz_security_zones" {
    # depends_on = [ null_resource.slow_down_buckets ]
    # count = (var.create_service_connector_vcnFlowLogs  == true && lower(var.service_connector_vcnFlowLogs_target) == "objectstorage") ? 1 : 0
    
    source       = "../modules/security/security-zones"
    providers = { oci = oci.home }
    security_zones = {
        ("key") = {
            name                = "Name"
            tenancy_ocid        = var.tenancy_ocid
            compartment_id      = local.enclosing_compartment_id
            service_label       = var.service_label
            description         = null
            security_policies   = null
            cis_level           = "2"
            defined_tags        = local.security_zones_defined_tags
            freeform_tags       = local.security_zones_freeform_tags
        }
    }

}
locals {

  all_security_zones_defined_tags = {}
  all_security_zones_freeform_tags = {}


  ### DON'T TOUCH THESE ###
  default_security_zones_defined_tags = null
  default_security_zones_freeform_tags = local.landing_zone_tags

  security_zones_defined_tags = length(local.all_security_zones_defined_tags) > 0 ? local.all_security_zones_defined_tags : local.default_security_zones_defined_tags
  security_zones_freeform_tags = length(local.all_security_zones_freeform_tags) > 0 ? merge(local.all_security_zones_freeform_tags, local.default_security_zones_freeform_tags) : local.default_security_zones_freeform_tags
}