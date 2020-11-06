output oracle_tag_defaults {
    value = local.oracle_tag_defaults_map
}

output custom_tag_defaults {
    value = oci_identity_tag_default.these
}