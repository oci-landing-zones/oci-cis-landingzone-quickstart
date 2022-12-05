# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration creates a custom tag namespace and tags in the
### specified tag_namespace_compartment_id 
### and tag defaults in the specified tag_defaults_compartment_id. 
### But only if there are no tag defaults for the oracle default namespace in
### the tag_defaults_compartment_id (checked by module).

locals {
  # These values can be used in an override file.
  all_tags                     = {}
  tag_namespace_name           = ""
  tag_namespace_compartment_id = local.enclosing_compartment_id
  tag_defaults_compartment_id  = local.enclosing_compartment_id
  is_create_namespace          = !var.extend_landing_zone_to_new_region

  all_tags_defined_tags = {}
  all_tags_freeform_tags = {}

  ##### DON'T TOUCH ANYTHING BELOW #####
  default_tags_defined_tags = null
  default_tags_freeform_tags = local.landing_zone_tags
  
  tags_defined_tags = length(local.all_tags_defined_tags) > 0 ? local.all_tags_defined_tags : local.default_tags_defined_tags
  tags_freeform_tags = length(local.all_tags_freeform_tags) > 0 ? merge(local.all_tags_freeform_tags, local.default_tags_freeform_tags) : local.default_tags_freeform_tags
  
  createdby_tag_name = "CreatedBy"
  createdon_tag_name = "CreatedOn"

  default_tag_namespace_name = "${var.service_label}-namesp"
  
  default_tags = { # the map keys are meant to be the tag names.
    (local.createdby_tag_name) = {
      tag_description         = "CIS Landing Zone tag that identifies who created the resource."
      tag_is_cost_tracking    = true
      tag_is_retired          = false
      make_tag_default        = true
      tag_default_value       = "$${iam.principal.name}"
      tag_default_is_required = false
      tag_defined_tags        = local.tags_defined_tags
      tag_freeform_tags       = local.tags_freeform_tags
    },
    (local.createdon_tag_name) = {
      tag_description         = "CIS Landing Zone tag that identifies when the resource was created."
      tag_is_cost_tracking    = false
      tag_is_retired          = false
      make_tag_default        = true
      tag_default_value       = "$${oci.datetime}"
      tag_default_is_required = false
      tag_defined_tags        = local.tags_defined_tags
      tag_freeform_tags       = local.tags_freeform_tags
    }
  }
}

module "lz_tags" {
  source                       = "../modules/monitoring/tags"
  providers                    = { oci = oci.home }
  tenancy_ocid                 = var.tenancy_ocid
  tag_namespace_compartment_id = local.tag_namespace_compartment_id
  tag_namespace_name           = length(local.tag_namespace_name) > 0 ? local.tag_namespace_name : local.default_tag_namespace_name
  tag_namespace_description    = "CIS Landing Zone ${var.service_label} tag namespace."
  tag_defaults_compartment_id  = local.tag_defaults_compartment_id
  is_create_namespace          = !var.extend_landing_zone_to_new_region
  tags                         = length(local.all_tags) > 0 ? local.all_tags : local.default_tags
}

module "lz_arch_center_tag" {
  count = !var.extend_landing_zone_to_new_region ? 1 : 0
  source        = "../modules/monitoring/tags-arch-center"
  providers     = { oci = oci.home }
  tenancy_ocid  = local.tag_namespace_compartment_id
  service_label = var.service_label
}