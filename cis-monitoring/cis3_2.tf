### Creates a custom tag namespace and tags in the specified tag_namespace_compartment_id 
### and tag defaults in the specified tag_defaults_compartment_id. 
### But only if there are no tag defaults for the default Oracle-Tags namespace in the tag_defaults_compartment_id (checked by module).
### To change this behavior, set the force property to true and the custom resources will be created regardless of the Oracle-Tags namespace.

module "cis_tags" {
  source                       = "../modules/monitoring/tags"
  tag_namespace_compartment_id = var.tenancy_ocid
  tag_namespace_name           = var.service_label
  tag_namespace_description    = "${var.service_label} tag namespace"
  tag_defaults_compartment_id  = var.tenancy_ocid
  force                        = false

  tags = { # the map keys are meant to be the tag names.
      "CreatedBy" = {
        tag_description         = "Identifies who created the resource."
        tag_is_cost_tracking    = true
        tag_is_retired          = false
        tag_default_value       = "$${iam.principal.name}"
        tag_default_is_required = false
      },
      "CreatedOn" = {
        tag_description         = "Identifies when the resource was created."
        tag_is_cost_tracking    = false
        tag_is_retired          = false
        tag_default_value       = "$${oci.datetime}"
        tag_default_is_required = false
    }
  }
}  