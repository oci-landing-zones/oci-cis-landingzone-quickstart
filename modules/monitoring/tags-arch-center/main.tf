# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

resource "oci_identity_tag_namespace" "arch_center" {
  compartment_id = var.tenancy_ocid
  description    = "CIS Landing Zone tag namespace for OCI Architecture Center."
  name           = "ArchitectureCenter\\cis-oci-landing-zone-quickstart-${var.service_label}"
}

resource "oci_identity_tag" "arch_center" {
  description      = "CIS Landing Zone tag for OCI Architecture Center."
  name             = "release"
  tag_namespace_id = oci_identity_tag_namespace.arch_center.id
}