# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration creates a custom tag namespace and tags in the specified tag_namespace_compartment_id 
### and tag defaults in the specified tag_defaults_compartment_id. 
### But only if there are no tag defaults for the oracle default namespace in the tag_defaults_compartment_id (checked by module).

module "cis_tags" {
  source                       = "../modules/monitoring/tags"
  providers                    = { oci = oci.home }
  tag_namespace_compartment_id = var.tenancy_ocid
  tag_namespace_name           = var.service_label
  tag_namespace_description    = "${var.service_label} tag namespace"
  tag_defaults_compartment_id  = var.tenancy_ocid

  tags = { # the map keys are meant to be the tag names.
    (local.createdby_tag_name) = {
      tag_description         = "Identifies who created the resource."
      tag_is_cost_tracking    = true
      tag_is_retired          = false
      make_tag_default        = true
      tag_default_value       = "$${iam.principal.name}"
      tag_default_is_required = false
    },
    (local.createdon_tag_name) = {
      tag_description         = "Identifies when the resource was created."
      tag_is_cost_tracking    = false
      tag_is_retired          = false
      make_tag_default        = true
      tag_default_value       = "$${oci.datetime}"
      tag_default_is_required = false
    }
  }
} 