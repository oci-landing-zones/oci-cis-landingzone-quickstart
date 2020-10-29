### Creates a tag namespace and tags *in* the specified compartment and tag defaults *for* the specified compartment
module "cis_tags" {
  source             = "../modules/monitoring/tags"
  compartment_id     = var.tenancy_ocid
  tag_namespace_name = var.service_label
  tag_namespace_description = "Tag namespace"

  tags = {
      "CreatedBy" = {
        description = "Identifies who created the resource."
        is_cost_tracking = false
        is_retired = false
        default_value = "$${iam.principal.name}"
        is_default_required = false
      },
      "CreatedOn" = {
        description = "Identifies when the resource was created."
        is_cost_tracking = false
        is_retired = false
        default_value = "$${oci.datetime}"
        is_default_required = false
    }
  }
}  