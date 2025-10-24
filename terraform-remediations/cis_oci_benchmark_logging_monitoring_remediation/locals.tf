# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  ### Discovering the home region name and region key.
  home_region_key = data.oci_identity_tenancy.this.home_region_key # Home region key obtained from the tenancy data source

  ### Discovering the home region name and region key.
  regions_map         = { for r in data.oci_identity_regions.these.regions : r.key => r.name } # All regions indexed by region key.
  regions_map_reverse = { for r in data.oci_identity_regions.these.regions : r.name => r.key } # All regions indexed by region name.
  region_key          = lower(local.regions_map_reverse[var.region])                           # Region key obtained from the region name


}
