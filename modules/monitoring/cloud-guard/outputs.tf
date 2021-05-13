# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output cloud_guard_config {
    description = "Cloud Guard configuration information."
    value = oci_cloud_guard_cloud_guard_configuration.this
}

output cloud_guard_target {
    description = "Cloud Guard target information."
    value = oci_cloud_guard_target.this
}