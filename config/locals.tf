# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

    ### IAM
    # Default compartment names
    default_enclosing_compartment_name = "${var.service_label}-top-cmp"
    security_compartment_name          = "${var.service_label}-Security"
    network_compartment_name           = "${var.service_label}-Network"
    database_compartment_name          = "${var.service_label}-Database"
    appdev_compartment_name            = "${var.service_label}-AppDev" 

    # Whether or not to create an enclosing compartment
    parent_compartment_id = var.enclosing_compartment == true ? (var.existing_enclosing_compartment_ocid != null ? var.existing_enclosing_compartment_ocid : module.cis_top_compartment[0].compartments[local.default_enclosing_compartment_name].id) : var.tenancy_ocid
    parent_compartment_name = var.enclosing_compartment == true ? (var.existing_enclosing_compartment_ocid != null ? data.oci_identity_compartment.existing_enclosing_compartment.name : local.default_enclosing_compartment_name) : "tenancy"
    policy_level = local.parent_compartment_name == "tenancy" ? "tenancy" : "compartment ${local.parent_compartment_name}"

    # Group names
    security_admin_group_name       = var.use_existing_iam_groups == false ? "${var.service_label}-SecurityAdmins" : var.security_admin_group_name
    network_admin_group_name        = var.use_existing_iam_groups == false ? "${var.service_label}-NetworkAdmins" : var.network_admin_group_name
    database_admin_group_name       = var.use_existing_iam_groups == false ? "${var.service_label}-DatabaseAdmins" : var.database_admin_group_name
    appdev_admin_group_name         = var.use_existing_iam_groups == false ? "${var.service_label}-AppDevAdmins" : var.appdev_admin_group_name
    iam_admin_group_name            = var.use_existing_iam_groups == false ? "${var.service_label}-IAMAdmins" : var.iam_admin_group_name
    cred_admin_group_name           = var.use_existing_iam_groups == false ? "${var.service_label}-CredentialAdmins" : var.cred_admin_group_name
    auditor_group_name              = var.use_existing_iam_groups == false ? "${var.service_label}-Auditors" : var.auditor_group_name
    announcement_reader_group_name  = var.use_existing_iam_groups == false ? "${var.service_label}-AnnouncementReaders" : var.announcement_reader_group_name

    # Policy names
    security_admin_policy_name       = "${var.service_label}-security-admin-policy"
    network_admin_policy_name        = "${var.service_label}-network-admin-policy"
    database_admin_policy_name       = "${var.service_label}-database-admin-policy"
    appdev_admin_policy_name         = "${var.service_label}-appdev-admin-policy"
    iam_admin_policy_name            = "${var.service_label}-iam-admin-policy"
    cred_admin_policy_name           = "${var.service_label}-credential-admin-policy"
    auditor_policy_name              = "${var.service_label}-auditor-policy"
    announcement_reader_policy_name  = "${var.service_label}-announcement-reader-policy"
    cloud_guard_policy_name          = "${var.service_label}-cloud-guard-policy"
    os_mgmt_policy_name              = "${var.service_label}-os-management-policy"

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