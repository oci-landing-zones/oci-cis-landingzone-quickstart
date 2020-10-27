locals {
    tags_default_values = {for k, v in var.tags : k => {"default_value" = v.default_value, "is_required": v.is_required}}
}

data "oci_identity_tags" "tags" {
    tag_namespace_id = oci_identity_tag_namespace.namespace.id
}
/*
data "oci_identity_tag_namespaces" "oracle_default_namespace" {
    compartment_id = var.compartment_id
    filter { 
        name = "name"
        values = ["OracleTags"]
    }   
}
*/
resource "oci_identity_tag_namespace" "namespace" {
    compartment_id = var.compartment_id
    name           = var.tag_namespace_name
    description    = var.tag_namespace_description
    
    #Optional
    is_retired     = var.is_namespace_retired
}

resource "oci_identity_tag" "this" {
    for_each = var.tags
        tag_namespace_id = oci_identity_tag_namespace.namespace.id 
        name = each.key
        description = each.value.description
        is_cost_tracking = each.value.is_cost_tracking
        is_retired = each.value.is_retired
}

resource "oci_identity_tag_default" "this" {
    for_each = var.tags  
        compartment_id    = var.compartment_id
        tag_definition_id = oci_identity_tag.this[each.key].id # the tag id that has been just created
        value             = local.tags_default_values[each.key].default_value # the tag default_value in the input variable
        is_required       = local.tags_default_values[each.key].is_required # the tag is_required value in the input variable
}
