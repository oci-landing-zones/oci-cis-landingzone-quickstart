# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

    ### Discovering the home region name and region key.
    regions_map = {for r in data.oci_identity_regions.these.regions : r.key => r.name} # All regions indexed by region key.
    regions_map_reverse = {for r in data.oci_identity_regions.these.regions : r.name => r.key} # All regions indexed by region name.
    home_region_key = data.oci_identity_tenancy.this.home_region_key # Home region key obtained from the tenancy data source
    region_key = lower(local.regions_map_reverse[var.region]) # Region key obtained from the region name
    
    ### IAM
    security_compartment_name = "${var.service_label}-Security"
    network_compartment_name  = "${var.service_label}-Network"
    database_compartment_name = "${var.service_label}-Database"
    appdev_compartment_name   = "${var.service_label}-AppDev" 

    security_admin_group_name = "${var.service_label}-SecurityAdmins"
    network_admin_group_name  = "${var.service_label}-NetworkAdmins"
    database_admin_group_name = "${var.service_label}-DatabaseAdmins"
    appdev_admin_group_name   = "${var.service_label}-AppDevAdmins"
    iam_admin_group_name      = "${var.service_label}-IAMAdmins"
    auditor_group_name        = "${var.service_label}-Auditors"
    announcement_readers_group_name = "${var.service_label}-AnnouncementReaders"

    # Tags
    createdby_tag_name = "CreatedBy"
    createdon_tag_name = "CreatedOn"

    ### Network
    anywhere = "0.0.0.0/0"
    valid_service_gateway_cidrs = ["oci-${local.region_key}-objectstorage", "all-${local.region_key}-services-in-oracle-services-network"]

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

    ### Service Connector Hub
    sch_audit_display_name = "${var.service_label}-audit-sch"
    sch_audit_bucket_name = "${var.service_label}-audit-sch-bucket"
    sch_audit_target_rollover_MBs = 100
    sch_audit_target_rollover_MSs = 420000
    
    sch_vcnFlowLogs_display_name = "${var.service_label}-vcn-flow-logs-sch"
    sch_vcnFlowLogs_bucket_name = "${var.service_label}-vcn-flow-logs-sch-bucket"
    sch_vcnFlowLogs_target_rollover_MBs = 100
    sch_vcnFlowLogs_target_rollover_MSs = 420000

    sch_audit_policy_name = "${var.service_label}-audit-sch-policy"
    sch_vcnFlowLogs_policy_name = "${var.service_label}-vcn-flow-logs-sch-policy"

    cg_target_name = "${var.service_label}-cloud-guard-root-target"
    ### Scanning
    scan_default_recipe_name    = "${var.service_label}-default-scan-recipe"
    security_cmp_target_name    = "${local.security_compartment_name}-scan-target"
    network_cmp_target_name     = "${local.network_compartment_name}-scan-target"
    appdev_cmp_target_name      = "${local.appdev_compartment_name}-scan-target"
    database_cmp_target_name    = "${local.database_compartment_name}-scan-target"

}