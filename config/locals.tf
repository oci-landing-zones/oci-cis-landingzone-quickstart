# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

    runner_group_ids = data.oci_identity_user_group_memberships.runner.memberships != null ? [for m in data.oci_identity_user_group_memberships.runner.memberships : m.group_id] : []
    is_runner_an_admin = contains([for g in data.oci_identity_group.runner_group : g.name], "Administrators")

    ### IAM
    # Default compartment names
    default_top_compartment_name = "${var.service_label}-Top"
    security_compartment_name    = "${var.service_label}-Security"
    network_compartment_name     = "${var.service_label}-Network"
    database_compartment_name    = "${var.service_label}-Database"
    appdev_compartment_name      = "${var.service_label}-AppDev" 

    # Whether or not to create a top level compartment
    parent_compartment_id = var.top_compartment == true ? (var.existing_top_compartment_name != null ? data.oci_identity_compartments.existing_top_compartment.compartments[0].id : module.cis_top_compartment[0].compartments[local.default_top_compartment_name].id) : local.is_runner_an_admin == true ? var.tenancy_ocid : try(tolist({}))
    parent_compartment_name = var.top_compartment == true ? (var.existing_top_compartment_name != null ? var.existing_top_compartment_name : local.default_top_compartment_name) : "tenancy"
    policy_level = local.parent_compartment_name == "tenancy" ? "tenancy" : "compartment ${local.parent_compartment_name}"

    # Default group names and whether or not to use existing IAM groups
    security_admin_group_name       = var.use_existing_iam_groups == false ? "${var.service_label}-SecurityAdmins" : var.security_admin_group_name
    network_admin_group_name        = var.use_existing_iam_groups == false ? "${var.service_label}-NetworkAdmins" : var.network_admin_group_name
    database_admin_group_name       = var.use_existing_iam_groups == false ? "${var.service_label}-DatabaseAdmins" : var.database_admin_group_name
    appdev_admin_group_name         = var.use_existing_iam_groups == false ? "${var.service_label}-AppDevAdmins" : var.appdev_admin_group_name
    iam_admin_group_name            = var.use_existing_iam_groups == false ? "${var.service_label}-IAMAdmins" : var.iam_admin_group_name
    cred_admin_group_name           = var.use_existing_iam_groups == false ? "${var.service_label}-CredAdmins" : var.cred_admin_group_name
    auditors_group_name             = var.use_existing_iam_groups == false ? "${var.service_label}-Auditors" : var.auditors_group_name
    announcement_readers_group_name = var.use_existing_iam_groups == false ? "${var.service_label}-AnnouncementReaders" : var.announcement_readers_group_name

    # Tags
    createdby_tag_name = "CreatedBy"
    createdon_tag_name = "CreatedOn"

    ### Network
    anywhere = "0.0.0.0/0"
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