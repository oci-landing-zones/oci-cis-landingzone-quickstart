# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  ### IAM
  security_compartment_name = "${var.service_label}-Security"
  network_compartment_name  = "${var.service_label}-Network"
  database_compartment_name = "${var.service_label}-Database"
  appdev_compartment_name   = "${var.service_label}-AppDev"

  /* security_compartment_name_output = module.cis_compartments.compartments[local.security_compartment_name].name
    network_compartment_name_output  = module.cis_compartments.compartments[local.network_compartment_name].name
    database_compartment_name_output = module.cis_compartments.compartments[local.database_compartment_name].name
    appdev_compartment_name_output   = module.cis_compartments.compartments[local.appdev_compartment_name].name */

  security_admin_group_name = "${var.service_label}-SecurityAdmins"
  network_admin_group_name  = "${var.service_label}-NetworkAdmins"
  database_admin_group_name = "${var.service_label}-DatabaseAdmins"
  appdev_admin_group_name   = "${var.service_label}-AppDevAdmins"
  iam_admin_group_name      = "${var.service_label}-IAMAdmins"
  auditor_group_name        = "${var.service_label}-Auditors"

  # Tags
  createdby_tag_name = "CreatedBy"
  createdon_tag_name = "CreatedOn"

  ### Network
  anywhere                    = "0.0.0.0/0"
  valid_service_gateway_cidrs = ["oci-${var.region_key}-objectstorage", "all-${var.region_key}-services-in-oracle-services-network"]

  # VCN names
  vcn_display_name = "${var.service_label}-VCN"

  # Subnet names
  public_subnet_name      = "${var.service_label}-Public-Subnet"
  private_subnet_app_name = "${var.service_label}-Private-Subnet-App"
  private_subnet_db_name  = "${var.service_label}-Private-Subnet-DB"

  # Security lists names
  public_subnet_security_list_name      = "${local.public_subnet_name}-Security-List"
  private_subnet_app_security_list_name = "${local.private_subnet_app_name}-Security-List"
  private_subnet_db_security_list_name  = "${local.private_subnet_db_name}-Security-List"

  # Network security groups names
  bastion_nsg_name = "${var.service_label}-NSG-Bastion"
  lbr_nsg_name     = "${var.service_label}-NSG-LBR"
  app_nsg_name     = "${var.service_label}-NSG-App"
  db_nsg_name      = "${var.service_label}-NSG-DB"

  # Route tables names
  public_subnet_route_table_name      = "${local.public_subnet_name}-Route"
  private_subnet_app_route_table_name = "${local.private_subnet_app_name}-Route"
  private_subnet_db_route_table_name  = "${local.private_subnet_db_name}-Route"

  ### Object Storage
  oss_key_name = "${var.service_label}-oss-key"
  bucket_name  = "${var.service_label}-bucket"
  vault_name   = "${var.service_label}-vault"
  vault_type   = "DEFAULT"
}