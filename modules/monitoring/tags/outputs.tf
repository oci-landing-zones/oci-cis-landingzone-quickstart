# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
    custom_tags = {for tag in oci_identity_tag.these : tag.name => tag}
}

output custom_tags {
    value = local.custom_tags
}

output custom_tag_namespace_name {
    value = oci_identity_tag_namespace.namespace[0].name
}