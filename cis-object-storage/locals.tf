# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
    bucket_name               = "${var.service_label}-bucket"
    vault_name                = "${var.service_label}-vault"
    vault_type                = "DEFAULT"
    key_display_name          = "${var.service_label}-customer-managed-key"
    key_key_shape_algorithm   = "AES"
    key_key_shape_length      = 32
    security_compartment_name = "${var.service_label}-Security"
    service_label             = var.service_label
}