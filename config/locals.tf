# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  ### Discovering the home region name and region key.
  regions_map         = { for r in data.oci_identity_regions.these.regions : r.key => r.name } # All regions indexed by region key.
  regions_map_reverse = { for r in data.oci_identity_regions.these.regions : r.name => r.key } # All regions indexed by region name.
  home_region_key     = data.oci_identity_tenancy.this.home_region_key                         # Home region key obtained from the tenancy data source
  region_key          = lower(local.regions_map_reverse[var.region])                           # Region key obtained from the region name
  
  ### Network
  anywhere                    = "0.0.0.0/0"
  valid_service_gateway_cidrs = ["all-${local.region_key}-services-in-oracle-services-network", "oci-${local.region_key}-objectstorage"]

  # Subnet names
  # Subnet Names used, can be used to change, add, or remove subnets first subnet will be Public if var.no_internet_access is false
  spoke_subnet_names = length(var.subnets_names) == 0 ? ["web", "app", "db"] : var.subnets_names
  # Subnets bit size used to adjust the size of the subnets created above, the number of items in this list must align to the subnets 
  spoke_subnet_size  = length(var.subnets_sizes) == 0 ? [4,4,4] : var.subnets_sizes
  # Subnet Names used can be changed first subnet will be Public if var.no_internet_access is false
  dmz_subnet_names = ["outdoor", "indoor", "mgmt", "ha", "diag"]
  # Mgmg subnet is public by default.
  is_mgmt_subnet_public = true

  dmz_vcn_name = var.dmz_vcn_cidr != null ? {
    name = "${var.service_label}-dmz-vcn"
    cidr = var.dmz_vcn_cidr
  } : {}

  # Bastion
  bastion_name = "${var.service_label}-bastion"
  bastion_max_session_ttl_in_seconds = 3 * 60 * 60 // 3 hrs.

  # Notifications
  iam_events_rule_name     = "${var.service_label}-notify-on-iam-changes-rule"
  network_events_rule_name = "${var.service_label}-notify-on-network-changes-rule"
  # Whether compartments should be deleted upon resource destruction.
  enable_cmp_delete = false

  # Delay in seconds for slowing down resource creation
  delay_in_secs = 70

  # Outputs display
  display_outputs = true

  # Tags
  landing_zone_tags = {"cis-landing-zone" : fileexists("${path.module}/../release.txt") ? "${var.service_label}-quickstart/${file("${path.module}/../release.txt")}" : "${var.service_label}-quickstart"}

  is_windows = substr(pathexpand("~"), 0, 1) == "/" ? false : true
}

resource "null_resource" "wait_on_compartments" {
  depends_on = [module.lz_compartments]
  provisioner "local-exec" {
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
    command     = local.is_windows ? "Start-Sleep ${local.delay_in_secs}" : "sleep ${local.delay_in_secs}"
  }
}

resource "null_resource" "wait_on_services_policy" {
  depends_on = [module.lz_services_policy]
  provisioner "local-exec" {
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
    command     = local.is_windows ? "Start-Sleep ${local.delay_in_secs}" : "sleep ${local.delay_in_secs}"
  }
}
