### This module creates a tag namespace, tags and tag defaults 
### only if tag defaults for tags in the Oracle-Tags namespace do not exist in the informed compartment.

locals {
    lowercase_tags_list           = [for tag in keys(var.tags) : lower(tag)]
    oracle_default_namespace_name = "Oracle-Tag"

    # This local captures the tags in Oracle-Tags default namespace that are tag defaults 
    # and have the same names as the tags we want to create and make tag defaults.
    # If we find such occurrences, it means we don't need to create tags and tag defaults.
    oracle_tag_defaults_map = {for tag in data.oci_identity_tags.these.tags : tag.name => tag 
                               if data.oci_identity_tags.these.tags !=null &&
                                  contains(data.oci_identity_tag_defaults.these.tag_defaults[*].tag_definition_id,tag.id) && 
                                  contains(local.lowercase_tags_list,lower(tag.name))}
}

data "oci_identity_tag_namespaces" "this" {
    compartment_id = var.tag_namespace_compartment_id
    filter {
        name  = "name"
        values = [local.oracle_default_namespace_name]
    }    
}

data "oci_identity_tags" "these" {
    tag_namespace_id = length(data.oci_identity_tag_namespaces.this.tag_namespaces) > 0 ? data.oci_identity_tag_namespaces.this.tag_namespaces[0].id : "null"
}

data "oci_identity_tag_defaults" "these" {
    compartment_id    = var.tag_defaults_compartment_id
}

resource "oci_identity_tag_namespace" "namespace" {
    count = local.oracle_tag_defaults_map == null ? 1 : 0
    compartment_id = var.tag_namespace_compartment_id
    name           = var.tag_namespace_name
    description    = var.tag_namespace_description
    is_retired     = var.is_namespace_retired
}

resource "oci_identity_tag" "these" {
    for_each = local.oracle_tag_defaults_map == null ? var.tags : {}
        tag_namespace_id = oci_identity_tag_namespace.namespace[0].id 
        name             = each.key
        description      = each.value.tag_description
        is_cost_tracking = each.value.tag_is_cost_tracking
        is_retired       = each.value.tag_is_retired
}

resource "oci_identity_tag_default" "these" {
    for_each = local.oracle_tag_defaults_map == null ? toset(keys(var.tags)) : []
        compartment_id    = var.tag_defaults_compartment_id
        tag_definition_id = oci_identity_tag.these[each.value].id     # the tag id that has been just created
        value             = var.tags[each.value].tag_default_value    # the tag default value
        is_required       = var.tags[each.value].tag_default_is_required # whether the tag default value is required
}
