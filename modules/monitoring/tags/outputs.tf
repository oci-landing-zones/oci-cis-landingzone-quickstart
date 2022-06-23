# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output custom_tags {
    value = length(oci_identity_tag.these) > 0 ? {for tag in oci_identity_tag.these : tag.name => tag} : null
}

output custom_tag_namespace {
    value = length(oci_identity_tag_namespace.namespace) > 0 ? oci_identity_tag_namespace.namespace[0] : null
}