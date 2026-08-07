# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

provider "oci" {
  region               = trimspace(var.region)
  tenancy_ocid         = trimspace(var.tenancy_ocid)
  user_ocid            = trimspace(var.user_ocid)
  fingerprint          = trimspace(var.fingerprint)
  private_key_path     = trimspace(var.private_key_path)
  private_key_password = var.private_key_password
  ignore_defined_tags  = ["Oracle-Tags.CreatedBy", "Oracle-Tags.CreatedOn"]
}

provider "oci" {
  alias                = "home"
  region               = local.regions_map[local.home_region_key]
  tenancy_ocid         = trimspace(var.tenancy_ocid)
  user_ocid            = trimspace(var.user_ocid)
  fingerprint          = trimspace(var.fingerprint)
  private_key_path     = trimspace(var.private_key_path)
  private_key_password = var.private_key_password
  ignore_defined_tags  = ["Oracle-Tags.CreatedBy", "Oracle-Tags.CreatedOn"]
}

terraform {
  required_version = ">= 1.4.0"
  required_providers {
    oci = {
      source                = "oracle/oci"
      configuration_aliases = [oci.home]
    }
  }
}
