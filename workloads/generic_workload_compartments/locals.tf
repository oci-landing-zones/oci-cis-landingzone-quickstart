# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  ### Discovering the home region name and region key.
  home_region_key           = data.oci_identity_tenancy.this.home_region_key # Home region key obtained from the tenancy data source
  existing_lz_enclosing_compartment_name = data.oci_identity_compartment.existing_lz_enclosing_compartment.name
  existing_lz_appdev_compartment_name = data.oci_identity_compartment.existing_lz_appdev_compartment.name
  security_compartment_name = data.oci_identity_compartment.existing_lz_security_compartment.name
  network_compartment_name = data.oci_identity_compartment.existing_lz_network_compartment.name


  ### Discovering the home region name and region key.
  regions_map         = { for r in data.oci_identity_regions.these.regions : r.key => r.name } # All regions indexed by region key.
  regions_map_reverse = { for r in data.oci_identity_regions.these.regions : r.name => r.key } # All regions indexed by region name.
  region_key          = lower(local.regions_map_reverse[var.region])                           # Region key obtained from the region name
  

  # Outputs display
  display_outputs = true

  # Tags
  landing_zone_tags = {"cis-landing-zone" : fileexists("${path.module}/../release.txt") ? "${var.service_label}-quickstart/${file("${path.module}/../release.txt")}" : "${var.service_label}-quickstart"}
}