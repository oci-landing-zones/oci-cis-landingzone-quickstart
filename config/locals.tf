# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {


  ### Discovering the home region name and region key.
  regions_map         = { for r in data.oci_identity_regions.these.regions : r.key => r.name } # All regions indexed by region key.
  regions_map_reverse = { for r in data.oci_identity_regions.these.regions : r.name => r.key } # All regions indexed by region name.
  home_region_key     = data.oci_identity_tenancy.this.home_region_key                         # Home region key obtained from the tenancy data source
  region_key          = lower(local.regions_map_reverse[var.region])                           # Region key obtained from the region name

  ### IAM
  # Default compartment names
  enclosing_compartment    = {key:"${var.service_label}-top-cmp", name: var.use_enclosing_compartment == true ? (var.existing_enclosing_compartment_ocid != null ? data.oci_identity_compartment.existing_enclosing_compartment.name : "${var.service_label}-top-cmp") : "tenancy"}
  enclosing_compartment_id = var.use_enclosing_compartment == true ? (var.existing_enclosing_compartment_ocid != null ? var.existing_enclosing_compartment_ocid : module.lz_top_compartment[0].compartments[local.enclosing_compartment.key].id) : var.tenancy_ocid

  security_compartment    = {key:"${var.service_label}-security-cmp", name: "${var.service_label}-security-cmp"}
  security_compartment_id = var.extend_landing_zone_to_new_region == false ? module.lz_compartments.compartments[local.security_compartment.key].id : data.oci_identity_compartments.security.compartments[0].id
  network_compartment     = {key:"${var.service_label}-network-cmp", name: "${var.service_label}-network-cmp"}
  network_compartment_id  = var.extend_landing_zone_to_new_region == false ? module.lz_compartments.compartments[local.network_compartment.key].id : data.oci_identity_compartments.network.compartments[0].id
  appdev_compartment      = {key:"${var.service_label}-appdev-cmp", name: "${var.service_label}-appdev-cmp"}
  appdev_compartment_id   = var.extend_landing_zone_to_new_region == false ? module.lz_compartments.compartments[local.appdev_compartment.key].id : data.oci_identity_compartments.appdev.compartments[0].id
  database_compartment    = {key:"${var.service_label}-database-cmp", name: "${var.service_label}-database-cmp"}
  database_compartment_id   = var.extend_landing_zone_to_new_region == false ? module.lz_compartments.compartments[local.database_compartment.key].id : data.oci_identity_compartments.database.compartments[0].id
  exainfra_compartment    = {key:"${var.service_label}-exainfra-cmp", name: "${var.service_label}-exainfra-cmp"}
  exainfra_compartment_id   = var.extend_landing_zone_to_new_region == false && var.deploy_exainfra_cmp == true ? module.lz_compartments.compartments[local.exainfra_compartment.key].id : length(data.oci_identity_compartments.exainfra.compartments) > 0 ? data.oci_identity_compartments.exainfra.compartments[0].id : "exainfra_cmp_undefined"
  
  # Group names
  # The logic for group names is the following: 
  # if an existing group isn't provided, create a name for the group.
  # If an existing group **ocid** is provided (and this is used in Resource Manager groups drop down UI control), retrieve the group name using oci_identity_group data source.
  # If an existing group **name** is provided, use oci_identity_groups (notice the 's') data source to make sure the group exists. 
  security_admin_group_name      = length(trimspace(var.existing_security_admin_group_name)) == 0      ? "${var.service_label}-security-admin-group"      : (length(regexall("^ocid1.group.oc.*$", var.existing_security_admin_group_name)) > 0      ? data.oci_identity_group.existing_security_admin_group.name      : data.oci_identity_groups.existing_security_admin_group.groups[0].name)
  network_admin_group_name       = length(trimspace(var.existing_network_admin_group_name)) == 0       ? "${var.service_label}-network-admin-group"       : (length(regexall("^ocid1.group.oc.*$", var.existing_network_admin_group_name)) > 0       ? data.oci_identity_group.existing_network_admin_group.name       : data.oci_identity_groups.existing_network_admin_group.groups[0].name)
  database_admin_group_name      = length(trimspace(var.existing_database_admin_group_name)) == 0      ? "${var.service_label}-database-admin-group"      : (length(regexall("^ocid1.group.oc.*$", var.existing_database_admin_group_name)) > 0      ? data.oci_identity_group.existing_database_admin_group.name      : data.oci_identity_groups.existing_database_admin_group.groups[0].name)
  appdev_admin_group_name        = length(trimspace(var.existing_appdev_admin_group_name)) == 0        ? "${var.service_label}-appdev-admin-group"        : (length(regexall("^ocid1.group.oc.*$", var.existing_appdev_admin_group_name)) > 0        ? data.oci_identity_group.existing_appdev_admin_group.name        : data.oci_identity_groups.existing_appdev_admin_group.groups[0].name)
  iam_admin_group_name           = length(trimspace(var.existing_iam_admin_group_name)) == 0           ? "${var.service_label}-iam-admin-group"           : (length(regexall("^ocid1.group.oc.*$", var.existing_iam_admin_group_name)) > 0           ? data.oci_identity_group.existing_iam_admin_group.name           : data.oci_identity_groups.existing_iam_admin_group.groups[0].name)
  cred_admin_group_name          = length(trimspace(var.existing_cred_admin_group_name)) == 0          ? "${var.service_label}-cred-admin-group"          : (length(regexall("^ocid1.group.oc.*$", var.existing_cred_admin_group_name)) > 0          ? data.oci_identity_group.existing_cred_admin_group.name          : data.oci_identity_groups.existing_cred_admin_group.groups[0].name)
  auditor_group_name             = length(trimspace(var.existing_auditor_group_name)) == 0             ? "${var.service_label}-auditor-group"             : (length(regexall("^ocid1.group.oc.*$", var.existing_auditor_group_name)) > 0             ? data.oci_identity_group.existing_auditor_group.name             : data.oci_identity_groups.existing_auditor_group.groups[0].name)
  announcement_reader_group_name = length(trimspace(var.existing_announcement_reader_group_name)) == 0 ? "${var.service_label}-announcement-reader-group" : (length(regexall("^ocid1.group.oc.*$", var.existing_announcement_reader_group_name)) > 0 ? data.oci_identity_group.existing_announcement_reader_group.name : data.oci_identity_groups.existing_announcement_reader_group.groups[0].name)
  exainfra_admin_group_name      = length(trimspace(var.existing_exainfra_admin_group_name)) == 0      ? "${var.service_label}-exainfra-admin-group"      : (length(regexall("^ocid1.group.oc.*$", var.existing_exainfra_admin_group_name)) > 0      ? data.oci_identity_group.existing_exainfra_admin_group.name      : data.oci_identity_groups.existing_exainfra_admin_group.groups[0].name)
  cost_admin_group_name          = length(trimspace(var.existing_cost_admin_group_name)) == 0          ? "${var.service_label}-cost-admin-group"          : (length(regexall("^ocid1.group.oc.*$", var.existing_cost_admin_group_name)) > 0          ? data.oci_identity_group.existing_cost_admin_group.name          : data.oci_identity_groups.existing_cost_admin_group.groups[0].name)
  

  
  # Policy names
  security_admin_policy_name      = "${var.service_label}-security-admin-policy"
  security_admin_root_policy_name = "${var.service_label}-security-admin-root-policy"
  network_admin_policy_name       = "${var.service_label}-network-admin-policy"
  compute_agent_policy_name       = "${var.service_label}-compute-agent-policy"
  network_admin_root_policy_name  = "${var.service_label}-network-admin-root-policy"
  database_admin_policy_name      = "${var.service_label}-database-admin-policy"
  database_dynamic_group_policy_name = "${var.service_label}-database-dynamic_group-policy"
  database_admin_root_policy_name = "${var.service_label}-database-admin-root-policy"
  appdev_admin_policy_name        = "${var.service_label}-appdev-admin-policy"
  appdev_admin_root_policy_name   = "${var.service_label}-appdev-admin-root-policy"
  iam_admin_policy_name           = "${var.service_label}-iam-admin-policy"
  iam_admin_root_policy_name      = "${var.service_label}-iam-admin-root-policy"
  cred_admin_policy_name          = "${var.service_label}-credential-admin-policy"
  auditor_policy_name             = "${var.service_label}-auditor-policy"
  announcement_reader_policy_name = "${var.service_label}-announcement-reader-policy"
  exainfra_admin_policy_name      = "${var.service_label}-exainfra-admin-policy"
  cost_admin_root_policy_name  = "${var.service_label}-cost-admin-root-policy"

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

  ### Object Storage
  bucket_name  = "${var.service_label}-bucket"

  # Bastion
  bastion_name = "${var.service_label}-bastion"
  bastion_max_session_ttl_in_seconds = 3 * 60 * 60 // 3 hrs.

  # Notifications
  iam_events_rule_name     = "${var.service_label}-notify-on-iam-changes-rule"
  network_events_rule_name = "${var.service_label}-notify-on-network-changes-rule"
  # Whether compartments should be deleted upon resource destruction.
  enable_cmp_delete = false

  policy_scope = local.enclosing_compartment.name == "tenancy" ? "tenancy" : "compartment ${local.enclosing_compartment.name}"

  use_existing_root_cmp_grants    = upper(var.policies_in_root_compartment) == "CREATE" ? false : true
  
  # Delay in seconds for slowing down resource creation
  delay_in_secs = 70

  # Outputs display
  display_outputs = true

  # Tags
  landing_zone_tags = {"cis-landing-zone" : "${var.service_label}-quickstart"}
}

resource "null_resource" "wait_on_compartments" {
  depends_on = [module.lz_compartments]
  provisioner "local-exec" {
    command = "sleep ${local.delay_in_secs}" # Wait for compartments to be available.
  }
}

resource "null_resource" "wait_on_services_policy" {
  depends_on = [module.lz_services_policy]
  provisioner "local-exec" {
    command = "sleep ${local.delay_in_secs}" # Wait for policies to be available.
  }
}

resource "null_resource" "wait_on_keys_policy" {
   depends_on = [ module.lz_keys_policies ]
   provisioner "local-exec" {
     command = "sleep ${local.delay_in_secs}" # Wait for keys policy to be available.
   }
}
