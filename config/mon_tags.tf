# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration creates a custom tag namespace and tags in the specified tag_namespace_compartment_id 
### and tag defaults in the specified tag_defaults_compartment_id. 
### But only if there are no tag defaults for the oracle default namespace in the tag_defaults_compartment_id (checked by module).

module "lz_tags" {
  source                       = "../modules/monitoring/tags"
  providers                    = { oci = oci.home }
  tenancy_ocid                 = var.tenancy_ocid
  tag_namespace_compartment_id = local.parent_compartment_id
  tag_namespace_name           = local.tag_namespace_name
  tag_namespace_description    = "Landing Zone ${var.service_label} tag namespace"
  tag_defaults_compartment_id  = local.parent_compartment_id

  tags = { # the map keys are meant to be the tag names.
    (local.createdby_tag_name) = {
      tag_description         = "Landing Zone tag that identifies who created the resource."
      tag_is_cost_tracking    = true
      tag_is_retired          = false
      make_tag_default        = true
      tag_default_value       = "$${iam.principal.name}"
      tag_default_is_required = false
    },
    (local.createdon_tag_name) = {
      tag_description         = "Landing Zone tag that identifies when the resource was created."
      tag_is_cost_tracking    = false
      tag_is_retired          = false
      make_tag_default        = true
      tag_default_value       = "$${oci.datetime}"
      tag_default_is_required = false
    }
  }
} 