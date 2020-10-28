locals {
    custom_tags_values = {for k, v in var.tags : k => {"default_value" = v.default_value, "is_required": v.is_required}}
}

data "oci_identity_tag_defaults" "tag_defaults" {
    compartment_id = var.compartment_id
    filter {
        name = "id"
        values = [for tag in data.oci_identity_tags.default_tags.tags : tag.id] 
    }
}

data "oci_identity_tag_namespaces" "default_namespace" {
    compartment_id = var.compartment_id
    filter { 
        name = "name"
        values = ["Oracle-Tags"]
    }   
}

data "oci_identity_tags" "default_tags" {
    tag_namespace_id = data.oci_identity_tag_namespaces.default_namespace.id
}

resource "oci_identity_tag_namespace" "namespace" {
    # Only create a tag namespace if there's no default 'Oracle-Tags' namespace
    count          = data.oci_identity_tag_namespaces.default_namespace.id == null ? 1 : 0
    compartment_id = var.compartment_id
    name           = var.tag_namespace_name
    description    = var.tag_namespace_description
    
    #Optional
    is_retired     = var.is_namespace_retired
}

resource "oci_identity_tag" "this" {
    for_each = data.oci_identity_tags.default_tags.id == null ? var.tags : {}
        tag_namespace_id = oci_identity_tag_namespace.namespace[0].id 
        name             = each.key
        description      = each.value.description
        is_cost_tracking = each.value.is_cost_tracking
        is_retired       = each.value.is_retired
}

/*
resource "oci_identity_tag" "this" {
    for_each = [for x in var.tags : {
        tag_namespace_id = oci_identity_tag_namespace.namespace[0].id 
        name             = x.key
        description      = x.description
        is_cost_tracking = x.is_cost_tracking
        is_retired       = x.is_retired
    } if !contains(local.default_tags_names,x.key)]     
}
*/
resource "oci_identity_tag_default" "this" {
    for_each = var.tags
        compartment_id    = var.compartment_id
        tag_definition_id = oci_identity_tag.this[each.key].id # the tag id that has been just created
        value             = local.custom_tags_values[each.key].default_value # the tag default_value in the input variable
        is_required       = local.custom_tags_values[each.key].is_required # the tag is_required value in the input variable
}
