# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  #-------------------------------------------------------------------------- 
  #-- Any of these custom variables can be overriden in a _override.tf file
  #--------------------------------------------------------------------------
  custom_policies_defined_tags = null
  custom_policies_freeform_tags = null
  
  # Policy names
  basic_root_policy_name          = "${var.service_label}-basic-root-policy"
  security_admin_policy_name      = "${var.service_label}-security-admin-policy"
  security_admin_root_policy_name = "${var.service_label}-security-admin-root-policy"
  network_admin_policy_name       = "${var.service_label}-network-admin-policy"
  compute_agent_policy_name       = "${var.service_label}-compute-agent-policy"
  database_admin_policy_name      = "${var.service_label}-database-admin-policy"
  database_dynamic_group_policy_name = "${var.service_label}-database-dynamic_group-policy"
  appdev_admin_policy_name        = "${var.service_label}-appdev-admin-policy"
  iam_admin_policy_name           = "${var.service_label}-iam-admin-policy"
  iam_admin_root_policy_name      = "${var.service_label}-iam-admin-root-policy"
  cred_admin_policy_name          = "${var.service_label}-credential-admin-policy"
  auditor_policy_name             = "${var.service_label}-auditor-policy"
  announcement_reader_policy_name = "${var.service_label}-announcement-reader-policy"
  exainfra_admin_policy_name      = "${var.service_label}-exainfra-admin-policy"
  cost_admin_root_policy_name     = "${var.service_label}-cost-admin-root-policy"
  storage_admin_policy_name       = "${var.service_label}-storage-admin-policy"

  #iam_grants_condition = [for g in local.cred_admin_group_name : "target.group.name != ${g}"]
  iam_grants_condition = [for g in local.cred_admin_group_name : substr(g,0,1) == "'" && substr(g,length(g)-1,1) == "'" ? "target.group.name != ${g}" : "target.group.name != '${g}'"]

 

  ### User Group Policies ###
  ## IAM admin grants at the root compartment
  iam_admin_grants_on_root_cmp = [
    "allow group ${join(",",local.iam_admin_group_name)} to inspect users in tenancy",
    "allow group ${join(",",local.iam_admin_group_name)} to manage users in tenancy where all {request.operation != 'ListApiKeys',request.operation != 'ListAuthTokens',request.operation != 'ListCustomerSecretKeys',request.operation != 'UploadApiKey',request.operation != 'DeleteApiKey',request.operation != 'UpdateAuthToken',request.operation != 'CreateAuthToken',request.operation != 'DeleteAuthToken',request.operation != 'CreateSecretKey',request.operation != 'UpdateCustomerSecretKey',request.operation != 'DeleteCustomerSecretKey'}",
    # Users should be manage users and groups permissions via IDP
    "allow group ${join(",",local.iam_admin_group_name)} to inspect groups in tenancy",
    "allow group ${join(",",local.iam_admin_group_name)} to read policies in tenancy",
    #"allow group ${join(",",local.iam_admin_group_name)} to manage groups in tenancy where all {target.group.name != 'Administrators', target.group.name != ${local.cred_admin_group_name}}",
    "allow group ${join(",",local.iam_admin_group_name)} to manage groups in tenancy where all {target.group.name != 'Administrators',${join(",",local.iam_grants_condition)}}",
    "allow group ${join(",",local.iam_admin_group_name)} to inspect identity-providers in tenancy",
    "allow group ${join(",",local.iam_admin_group_name)} to manage identity-providers in tenancy where any {request.operation = 'AddIdpGroupMapping', request.operation = 'DeleteIdpGroupMapping'}",
    "allow group ${join(",",local.iam_admin_group_name)} to manage dynamic-groups in tenancy",
    "allow group ${join(",",local.iam_admin_group_name)} to manage authentication-policies in tenancy",
    "allow group ${join(",",local.iam_admin_group_name)} to manage network-sources in tenancy",
    "allow group ${join(",",local.iam_admin_group_name)} to manage quota in tenancy",
    "allow group ${join(",",local.iam_admin_group_name)} to read audit-events in tenancy",
    "allow group ${join(",",local.iam_admin_group_name)} to use cloud-shell in tenancy",
    "allow group ${join(",",local.iam_admin_group_name)} to manage tag-defaults in tenancy",
    "allow group ${join(",",local.iam_admin_group_name)} to manage tag-namespaces in tenancy",
    # Statements scoped to allow an IAM admin to deploy IAM resources via ORM
    "allow group ${join(",",local.iam_admin_group_name)} to manage orm-stacks in tenancy",
    "allow group ${join(",",local.iam_admin_group_name)} to manage orm-jobs in tenancy",
    "allow group ${join(",",local.iam_admin_group_name)} to manage orm-config-source-providers in tenancy"]

  ## IAM admin grants at the enclosing compartment level, which *can* be the root compartment
  iam_admin_grants_on_enclosing_cmp = [
    "allow group ${join(",",local.iam_admin_group_name)} to manage policies in ${local.policy_scope}", 
    "allow group ${join(",",local.iam_admin_group_name)} to manage compartments in ${local.policy_scope}"]

  // Security admin permissions to be created always at the root compartment
  security_admin_grants_on_root_cmp = [
  #  "allow group ${join(",",local.security_admin_group_name)} to manage cloudevents-rules in tenancy",
    "allow group ${join(",",local.security_admin_group_name)} to manage cloudevents-rules in tenancy",
    "allow group ${join(",",local.security_admin_group_name)} to manage cloud-guard-family in tenancy",
    "allow group ${join(",",local.security_admin_group_name)} to read tenancies in tenancy",
    "allow group ${join(",",local.security_admin_group_name)} to read objectstorage-namespaces in tenancy",
    "allow group ${join(",",local.security_admin_group_name)} to use cloud-shell in tenancy",
    "allow group ${join(",",local.security_admin_group_name)} to read usage-budgets in tenancy",
    "allow group ${join(",",local.security_admin_group_name)} to read usage-reports in tenancy"]

  ## Security admin grants at the enclosing compartment level, which *can* be the root compartment
  security_admin_grants_on_enclosing_cmp = [
    "allow group ${join(",",local.security_admin_group_name)} to manage tag-namespaces in ${local.policy_scope}",
    "allow group ${join(",",local.security_admin_group_name)} to manage tag-defaults in ${local.policy_scope}",
    "allow group ${join(",",local.security_admin_group_name)} to manage repos in ${local.policy_scope}",
    "allow group ${join(",",local.security_admin_group_name)} to read audit-events in ${local.policy_scope}",
    "allow group ${join(",",local.security_admin_group_name)} to read app-catalog-listing in ${local.policy_scope}",
    "allow group ${join(",",local.security_admin_group_name)} to read instance-images in ${local.policy_scope}",
    "allow group ${join(",",local.security_admin_group_name)} to inspect buckets in ${local.policy_scope}"]

  ## Security admin grants on Security compartment
  security_admin_grants_on_security_cmp = [
    "allow group ${join(",",local.security_admin_group_name)} to read all-resources in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.security_admin_group_name)} to manage instance-family in compartment ${local.security_compartment_name}",
    # CIS 1.2 - 1.14 Level 2
    "allow group ${join(",",local.security_admin_group_name)} to manage volume-family in compartment ${local.security_compartment_name} where all{request.permission != 'VOLUME_BACKUP_DELETE', request.permission != 'VOLUME_DELETE', request.permission != 'BOOT_VOLUME_BACKUP_DELETE'}",
    "allow group ${join(",",local.security_admin_group_name)} to manage object-family in compartment ${local.security_compartment_name} where all{request.permission != 'OBJECT_DELETE', request.permission != 'BUCKET_DELETE'}",
    "allow group ${join(",",local.security_admin_group_name)} to manage file-family in compartment ${local.security_compartment_name} where all{request.permission != 'FILE_SYSTEM_DELETE', request.permission != 'MOUNT_TARGET_DELETE', request.permission != 'EXPORT_SET_DELETE', request.permission != 'FILE_SYSTEM_DELETE_SNAPSHOT', request.permission != 'FILE_SYSTEM_NFSv3_UNEXPORT'}",
    "allow group ${join(",",local.security_admin_group_name)} to manage vaults in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.security_admin_group_name)} to manage keys in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.security_admin_group_name)} to manage secret-family in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.security_admin_group_name)} to manage logging-family in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.security_admin_group_name)} to manage serviceconnectors in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.security_admin_group_name)} to manage streams in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.security_admin_group_name)} to manage ons-family in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.security_admin_group_name)} to manage functions-family in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.security_admin_group_name)} to manage waas-family in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.security_admin_group_name)} to manage security-zone in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.security_admin_group_name)} to manage orm-stacks in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.security_admin_group_name)} to manage orm-jobs in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.security_admin_group_name)} to manage orm-config-source-providers in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.security_admin_group_name)} to manage vss-family in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.security_admin_group_name)} to read work-requests in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.security_admin_group_name)} to manage bastion-family in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.security_admin_group_name)} to read instance-agent-plugins in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.security_admin_group_name)} to manage cloudevents-rules in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.security_admin_group_name)} to manage alarms in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.security_admin_group_name)} to manage metrics in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.security_admin_group_name)} to use key-delegate in compartment ${local.security_compartment_name}"]

  ## Security admin grants on Network compartment
  security_admin_grants_on_network_cmp = [
    "allow group ${join(",",local.security_admin_group_name)} to read virtual-network-family in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.security_admin_group_name)} to use subnets in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.security_admin_group_name)} to use network-security-groups in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.security_admin_group_name)} to use vnics in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.security_admin_group_name)} to manage private-ips in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.security_admin_group_name)} to read keys in compartment ${local.network_compartment_name}"]

  ## Security admin grants on AppDev compartment
  security_admin_grants_on_appdev_cmp = [
    "allow group ${join(",",local.security_admin_group_name)} to read keys in compartment ${local.appdev_compartment_name}"
  ]  

  ## Security admin grants on Database compartment
  security_admin_grants_on_database_cmp = [
    "allow group ${join(",",local.security_admin_group_name)} to read keys in compartment ${local.database_compartment_name}"
  ]

  ## Security admin grants on Exainfra compartment
  security_admin_grants_on_exainfra_cmp = var.deploy_exainfra_cmp == true ? [
    "allow group ${join(",",local.security_admin_group_name)} to read keys in compartment ${local.exainfra_compartment_name}"
  ] : []

  ## All security admin grants
  security_admin_grants = concat(local.security_admin_grants_on_enclosing_cmp, local.security_admin_grants_on_security_cmp, local.security_admin_grants_on_network_cmp,
                                 local.security_admin_grants_on_appdev_cmp, local.security_admin_grants_on_database_cmp, local.security_admin_grants_on_exainfra_cmp)  

  ## Network admin grants on Network compartment
  network_admin_grants_on_network_cmp = [
    "allow group ${join(",",local.network_admin_group_name)} to read all-resources in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.network_admin_group_name)} to manage virtual-network-family in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.network_admin_group_name)} to manage dns in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.network_admin_group_name)} to manage load-balancers in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.network_admin_group_name)} to manage alarms in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.network_admin_group_name)} to manage metrics in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.network_admin_group_name)} to manage ons-family in compartment ${local.network_compartment_name}", 
    "allow group ${join(",",local.network_admin_group_name)} to manage orm-stacks in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.network_admin_group_name)} to manage orm-jobs in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.network_admin_group_name)} to manage orm-config-source-providers in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.network_admin_group_name)} to read audit-events in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.network_admin_group_name)} to read work-requests in compartment ${local.network_compartment_name}",
    # CIS 1.2 - 1.14 Level 2
    "allow group ${join(",",local.network_admin_group_name)} to manage instance-family in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.network_admin_group_name)} to manage volume-family in compartment ${local.network_compartment_name} where all{request.permission != 'VOLUME_BACKUP_DELETE', request.permission != 'VOLUME_DELETE', request.permission != 'BOOT_VOLUME_BACKUP_DELETE'}",
    "allow group ${join(",",local.network_admin_group_name)} to manage object-family in compartment ${local.network_compartment_name} where all{request.permission != 'OBJECT_DELETE', request.permission != 'BUCKET_DELETE'}",
    "allow group ${join(",",local.network_admin_group_name)} to manage file-family in compartment ${local.network_compartment_name} where all{request.permission != 'FILE_SYSTEM_DELETE', request.permission != 'MOUNT_TARGET_DELETE', request.permission != 'EXPORT_SET_DELETE', request.permission != 'FILE_SYSTEM_DELETE_SNAPSHOT', request.permission != 'FILE_SYSTEM_NFSv3_UNEXPORT'}",

    "allow group ${join(",",local.network_admin_group_name)} to manage bastion-session in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.network_admin_group_name)} to manage cloudevents-rules in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.network_admin_group_name)} to manage alarms in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.network_admin_group_name)} to manage metrics in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.network_admin_group_name)} to read instance-agent-plugins in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.network_admin_group_name)} to manage keys in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.network_admin_group_name)} to use key-delegate in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.network_admin_group_name)} to manage secret-family in compartment ${local.network_compartment_name}"] 

  ## Network admin grants on Security compartment
  network_admin_grants_on_security_cmp = [
    "allow group ${join(",",local.network_admin_group_name)} to read vss-family in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.network_admin_group_name)} to use bastion in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.network_admin_group_name)} to manage bastion-session in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.network_admin_group_name)} to use vaults in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.network_admin_group_name)} to read logging-family in compartment ${local.security_compartment_name}"]

  ## All network admin grants
  network_admin_grants = concat(local.network_admin_grants_on_network_cmp, local.network_admin_grants_on_security_cmp)      

  ## Database admin grants on Database compartment
  database_admin_grants_on_database_cmp = [
    "allow group ${join(",",local.database_admin_group_name)} to read all-resources in compartment ${local.database_compartment_name}",
    "allow group ${join(",",local.database_admin_group_name)} to manage database-family in compartment ${local.database_compartment_name}",
    "allow group ${join(",",local.database_admin_group_name)} to manage autonomous-database-family in compartment ${local.database_compartment_name}",
    "allow group ${join(",",local.database_admin_group_name)} to manage alarms in compartment ${local.database_compartment_name}",
    "allow group ${join(",",local.database_admin_group_name)} to manage metrics in compartment ${local.database_compartment_name}",
    "allow group ${join(",",local.database_admin_group_name)} to manage cloudevents-rules in compartment ${local.database_compartment_name}",
    # CIS 1.2 - 1.14 Level 2 
    "allow group ${join(",",local.database_admin_group_name)} to manage object-family in compartment ${local.database_compartment_name} where all{request.permission != 'OBJECT_DELETE', request.permission != 'BUCKET_DELETE'}",
    "allow group ${join(",",local.database_admin_group_name)} to manage instance-family in compartment ${local.database_compartment_name}",
    "allow group ${join(",",local.database_admin_group_name)} to manage volume-family in compartment ${local.database_compartment_name} where all{request.permission != 'VOLUME_BACKUP_DELETE', request.permission != 'VOLUME_DELETE', request.permission != 'BOOT_VOLUME_BACKUP_DELETE'}",
    "allow group ${join(",",local.database_admin_group_name)} to manage file-family in compartment ${local.database_compartment_name} where all{request.permission != 'FILE_SYSTEM_DELETE', request.permission != 'MOUNT_TARGET_DELETE', request.permission != 'EXPORT_SET_DELETE', request.permission != 'FILE_SYSTEM_DELETE_SNAPSHOT', request.permission != 'FILE_SYSTEM_NFSv3_UNEXPORT'}",
    "allow group ${join(",",local.database_admin_group_name)} to manage orm-stacks in compartment ${local.database_compartment_name}",
    "allow group ${join(",",local.database_admin_group_name)} to manage orm-jobs in compartment ${local.database_compartment_name}",
    "allow group ${join(",",local.database_admin_group_name)} to manage orm-config-source-providers in compartment ${local.database_compartment_name}",
    "allow group ${join(",",local.database_admin_group_name)} to manage ons-family in compartment ${local.database_compartment_name}", 
    "allow group ${join(",",local.database_admin_group_name)} to manage logging-family in compartment ${local.database_compartment_name}", 
    "allow group ${join(",",local.database_admin_group_name)} to read audit-events in compartment ${local.database_compartment_name}",
    "allow group ${join(",",local.database_admin_group_name)} to read work-requests in compartment ${local.database_compartment_name}",
    "allow group ${join(",",local.database_admin_group_name)} to manage bastion-session in compartment ${local.database_compartment_name}",
    "allow group ${join(",",local.database_admin_group_name)} to read instance-agent-plugins in compartment ${local.database_compartment_name}",
    "allow group ${join(",",local.database_admin_group_name)} to manage data-safe-family in compartment ${local.database_compartment_name}",
    "allow group ${join(",",local.database_admin_group_name)} to use vnics in compartment ${local.database_compartment_name}",
    "allow group ${join(",",local.database_admin_group_name)} to manage keys in compartment ${local.database_compartment_name}",
    "allow group ${join(",",local.database_admin_group_name)} to use key-delegate in compartment ${local.database_compartment_name}",
    "allow group ${join(",",local.database_admin_group_name)} to manage secret-family in compartment ${local.database_compartment_name}"]

  ## Database admin grants on Network compartment
  database_admin_grants_on_network_cmp = [
    # https://docs.oracle.com/en-us/iaas/autonomous-database-shared/doc/iam-private-endpoint-configure-policies.html
    "allow group ${join(",",local.database_admin_group_name)} to read virtual-network-family in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.database_admin_group_name)} to use vnics in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.database_admin_group_name)} to manage private-ips in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.database_admin_group_name)} to use subnets in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.database_admin_group_name)} to use network-security-groups in compartment ${local.network_compartment_name}"]  

  ## Database admin grants on Security compartment
  database_admin_grants_on_security_cmp = [
    "allow group ${join(",",local.database_admin_group_name)} to read vss-family in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.database_admin_group_name)} to use vaults in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.database_admin_group_name)} to read logging-family in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.database_admin_group_name)} to use bastion in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.database_admin_group_name)} to manage bastion-session in compartment ${local.security_compartment_name}"]

  ## Database admin grants on Exainfra compartment
  database_admin_grants_on_exainfra_cmp = var.deploy_exainfra_cmp == true ? [
    "allow group ${join(",",local.database_admin_group_name)} to read cloud-exadata-infrastructures in compartment ${local.exainfra_compartment_name}",
    "allow group ${join(",",local.database_admin_group_name)} to use cloud-vmclusters in compartment ${local.exainfra_compartment_name}",
    "allow group ${join(",",local.database_admin_group_name)} to read work-requests in compartment ${local.exainfra_compartment_name}",
    "allow group ${join(",",local.database_admin_group_name)} to manage db-nodes in compartment ${local.exainfra_compartment_name}",
    "allow group ${join(",",local.database_admin_group_name)} to manage db-homes in compartment ${local.exainfra_compartment_name}",
    "allow group ${join(",",local.database_admin_group_name)} to manage databases in compartment ${local.exainfra_compartment_name}",
    "allow group ${join(",",local.database_admin_group_name)} to manage db-backups in compartment ${local.exainfra_compartment_name}",
    "allow group ${join(",",local.database_admin_group_name)} to manage data-safe-family in compartment ${local.exainfra_compartment_name}"
  ] : []

  ## All database admin grants
  database_admin_grants = concat(local.database_admin_grants_on_database_cmp, local.database_admin_grants_on_network_cmp, 
                                 local.database_admin_grants_on_security_cmp, local.database_admin_grants_on_exainfra_cmp)

  ## AppDev admin grants on AppDev compartment
  appdev_admin_grants_on_appdev_cmp = [
    "allow group ${join(",",local.appdev_admin_group_name)} to read all-resources in compartment ${local.appdev_compartment_name}",
    "allow group ${join(",",local.appdev_admin_group_name)} to manage functions-family in compartment ${local.appdev_compartment_name}",
    "allow group ${join(",",local.appdev_admin_group_name)} to manage api-gateway-family in compartment ${local.appdev_compartment_name}",
    "allow group ${join(",",local.appdev_admin_group_name)} to manage ons-family in compartment ${local.appdev_compartment_name}",
    "allow group ${join(",",local.appdev_admin_group_name)} to manage streams in compartment ${local.appdev_compartment_name}",
    "allow group ${join(",",local.appdev_admin_group_name)} to manage cluster-family in compartment ${local.appdev_compartment_name}",
    "allow group ${join(",",local.appdev_admin_group_name)} to manage alarms in compartment ${local.appdev_compartment_name}",
    "allow group ${join(",",local.appdev_admin_group_name)} to manage metrics in compartment ${local.appdev_compartment_name}",
    "allow group ${join(",",local.appdev_admin_group_name)} to manage logging-family in compartment ${local.appdev_compartment_name}",
    "allow group ${join(",",local.appdev_admin_group_name)} to manage instance-family in compartment ${local.appdev_compartment_name}",
    # CIS 1.2 - 1.14 Level 2 
    "allow group ${join(",",local.appdev_admin_group_name)} to manage volume-family in compartment ${local.appdev_compartment_name} where all{request.permission != 'VOLUME_BACKUP_DELETE', request.permission != 'VOLUME_DELETE', request.permission != 'BOOT_VOLUME_BACKUP_DELETE'}",
    "allow group ${join(",",local.appdev_admin_group_name)} to manage object-family in compartment ${local.appdev_compartment_name} where all{request.permission != 'OBJECT_DELETE', request.permission != 'BUCKET_DELETE'}",
    "allow group ${join(",",local.appdev_admin_group_name)} to manage file-family in compartment ${local.appdev_compartment_name} where all{request.permission != 'FILE_SYSTEM_DELETE', request.permission != 'MOUNT_TARGET_DELETE', request.permission != 'EXPORT_SET_DELETE', request.permission != 'FILE_SYSTEM_DELETE_SNAPSHOT', request.permission != 'FILE_SYSTEM_NFSv3_UNEXPORT'}",
    "allow group ${join(",",local.appdev_admin_group_name)} to manage repos in compartment ${local.appdev_compartment_name}",
    "allow group ${join(",",local.appdev_admin_group_name)} to manage orm-stacks in compartment ${local.appdev_compartment_name}",
    "allow group ${join(",",local.appdev_admin_group_name)} to manage orm-jobs in compartment ${local.appdev_compartment_name}",
    "allow group ${join(",",local.appdev_admin_group_name)} to manage orm-config-source-providers in compartment ${local.appdev_compartment_name}",
    "allow group ${join(",",local.appdev_admin_group_name)} to read audit-events in compartment ${local.appdev_compartment_name}",
    "allow group ${join(",",local.appdev_admin_group_name)} to read work-requests in compartment ${local.appdev_compartment_name}",
    "allow group ${join(",",local.appdev_admin_group_name)} to manage bastion-session in compartment ${local.appdev_compartment_name}",
    "allow group ${join(",",local.appdev_admin_group_name)} to manage cloudevents-rules in compartment ${local.appdev_compartment_name}",
    "allow group ${join(",",local.appdev_admin_group_name)} to read instance-agent-plugins in compartment ${local.appdev_compartment_name}",
    "allow group ${join(",",local.appdev_admin_group_name)} to manage keys in compartment ${local.appdev_compartment_name}",
    "allow group ${join(",",local.appdev_admin_group_name)} to use key-delegate in compartment ${local.appdev_compartment_name}",
    "allow group ${join(",",local.appdev_admin_group_name)} to manage secret-family in compartment ${local.appdev_compartment_name}"]

  ## AppDev admin grants on Network compartment
  appdev_admin_grants_on_network_cmp = [
    "allow group ${join(",",local.appdev_admin_group_name)} to read virtual-network-family in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.appdev_admin_group_name)} to use subnets in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.appdev_admin_group_name)} to use network-security-groups in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.appdev_admin_group_name)} to use vnics in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.appdev_admin_group_name)} to manage private-ips in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.appdev_admin_group_name)} to use load-balancers in compartment ${local.network_compartment_name}"]    

  ## AppDev admin grants on Security compartment
  appdev_admin_grants_on_security_cmp = [
    "allow group ${join(",",local.appdev_admin_group_name)} to use vaults in compartment ${local.security_compartment_name}",
    #"allow group ${join(",",local.appdev_admin_group_name)} to inspect keys in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.appdev_admin_group_name)} to manage instance-images in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.appdev_admin_group_name)} to read vss-family in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.appdev_admin_group_name)} to use bastion in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.appdev_admin_group_name)} to manage bastion-session in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.appdev_admin_group_name)} to read logging-family in compartment ${local.security_compartment_name}"] 

  ## AppDev admin grants on Database compartment
  appdev_admin_grants_on_database_cmp = [
    "allow group ${join(",",local.appdev_admin_group_name)} to read autonomous-database-family in compartment ${local.database_compartment_name}",
    "allow group ${join(",",local.appdev_admin_group_name)} to read database-family in compartment ${local.database_compartment_name}"] 

  ## AppDev admin grants on enclosing compartment
  appdev_admin_grants_on_enclosing_cmp = [
    "allow group ${join(",",local.appdev_admin_group_name)} to read app-catalog-listing in ${local.policy_scope}",
    "allow group ${join(",",local.appdev_admin_group_name)} to read instance-images in ${local.policy_scope}",
    "allow group ${join(",",local.appdev_admin_group_name)} to read repos in ${local.policy_scope}"]                  

  ## All AppDev admin grants
  appdev_admin_grants = concat(local.appdev_admin_grants_on_appdev_cmp, local.appdev_admin_grants_on_network_cmp,
                               local.appdev_admin_grants_on_security_cmp, local.appdev_admin_grants_on_database_cmp,
                               local.appdev_admin_grants_on_enclosing_cmp)

  ## Exainfra admin grants on Exinfra compartment
  exainfra_admin_grants_on_exainfra_cmp = [
    "allow group ${join(",",local.exainfra_admin_group_name)} to manage cloud-exadata-infrastructures in compartment ${local.exainfra_compartment_name}",
    "allow group ${join(",",local.exainfra_admin_group_name)} to manage cloud-vmclusters in compartment ${local.exainfra_compartment_name}",
    "allow group ${join(",",local.exainfra_admin_group_name)} to read work-requests in compartment ${local.exainfra_compartment_name}",
    "allow group ${join(",",local.exainfra_admin_group_name)} to manage bastion-session in compartment ${local.exainfra_compartment_name}",
    "allow group ${join(",",local.exainfra_admin_group_name)} to manage instance-family in compartment ${local.exainfra_compartment_name}",
    "allow group ${join(",",local.exainfra_admin_group_name)} to read instance-agent-plugins in compartment ${local.exainfra_compartment_name}",
    "allow group ${join(",",local.exainfra_admin_group_name)} to manage ons-family in compartment ${local.exainfra_compartment_name}",
    "allow group ${join(",",local.exainfra_admin_group_name)} to manage alarms in compartment ${local.exainfra_compartment_name}",
    "allow group ${join(",",local.exainfra_admin_group_name)} to manage metrics in compartment ${local.exainfra_compartment_name}",
    "allow group ${join(",",local.exainfra_admin_group_name)} to manage data-safe-family in compartment ${local.exainfra_compartment_name}",
    "allow group ${join(",",local.exainfra_admin_group_name)} to manage keys in compartment ${local.exainfra_compartment_name}",
    "allow group ${join(",",local.exainfra_admin_group_name)} to use key-delegate in compartment ${local.exainfra_compartment_name}",
    "allow group ${join(",",local.exainfra_admin_group_name)} to manage secret-family in compartment ${local.exainfra_compartment_name}"]

  ## Exainfra admin grants on Security compartment
  exainfra_admin_grants_on_security_cmp = [
    "allow group ${join(",",local.exainfra_admin_group_name)} to read vss-family in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.exainfra_admin_group_name)} to use vaults in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.exainfra_admin_group_name)} to read logging-family in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.exainfra_admin_group_name)} to use bastion in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.exainfra_admin_group_name)} to manage bastion-session in compartment ${local.security_compartment_name}"] 

  ## Exainfra admin grants on Network compartment
  exainfra_admin_grants_on_network_cmp = [
    "allow group ${join(",",local.exainfra_admin_group_name)} to read virtual-network-family in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.exainfra_admin_group_name)} to use subnets in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.exainfra_admin_group_name)} to use network-security-groups in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.exainfra_admin_group_name)} to use vnics in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.exainfra_admin_group_name)} to manage private-ips in compartment ${local.network_compartment_name}"]

  ## All Exainfra admin grants 
  exainfra_admin_grants = concat(local.exainfra_admin_grants_on_exainfra_cmp, local.exainfra_admin_grants_on_security_cmp, local.exainfra_admin_grants_on_network_cmp)

  ## Cost admin permissions to be created always at the Root compartment
  cost_root_permissions = ["define tenancy usage-report as ocid1.tenancy.oc1..aaaaaaaaned4fkpkisbwjlr56u7cj63lf3wffbilvqknstgtvzub7vhqkggq", 
                           "endorse group ${join(",",local.cost_admin_group_name)} to read objects in tenancy usage-report",
                           "allow group ${join(",",local.cost_admin_group_name)} to manage usage-report in tenancy",
                           "allow group ${join(",",local.cost_admin_group_name)} to manage usage-budgets in tenancy"]

  ### Dynamic Group Policies ###
  ## Compute Agent grants
  compute_agent_grants = [
    "allow dynamic-group ${local.appdev_computeagent_dynamic_group_name} to manage management-agents in compartment ${local.appdev_compartment_name}",
    "allow dynamic-group ${local.appdev_computeagent_dynamic_group_name} to use metrics in compartment ${local.appdev_compartment_name}",
    "allow dynamic-group ${local.appdev_computeagent_dynamic_group_name} to use tag-namespaces in compartment ${local.appdev_compartment_name}"]

  ## ADB grants
  autonomous_database_grants = [
    "allow dynamic-group ${local.database_kms_dynamic_group_name} to use vaults in compartment ${local.security_compartment_name}",
    "allow dynamic-group ${local.database_kms_dynamic_group_name} to use keys in compartment ${local.database_compartment_name}",
    "allow dynamic-group ${local.database_kms_dynamic_group_name} to use secret-family in compartment ${local.database_compartment_name}"]
  
  ## Storage admin grants
  storage_admin_grants = [
    # Grants in appdev compartment
    # Object Storage
    "allow group ${join(",",local.storage_admin_group_name)} to read bucket in compartment ${local.appdev_compartment_name}",
    "allow group ${join(",",local.storage_admin_group_name)} to inspect object in compartment ${local.appdev_compartment_name}",
    "allow group ${join(",",local.storage_admin_group_name)} to manage object-family in compartment ${local.appdev_compartment_name} where any {request.permission = 'OBJECT_DELETE', request.permission = 'BUCKET_DELETE'}",
    # Volume Storage
    "allow group ${join(",",local.storage_admin_group_name)} to read volume-family in compartment ${local.appdev_compartment_name}",
    "allow group ${join(",",local.storage_admin_group_name)} to manage volume-family in compartment ${local.appdev_compartment_name} where any {request.permission = 'VOLUME_DELETE', request.permission = 'VOLUME_BACKUP_DELETE', request.permission = 'BOOT_VOLUME_BACKUP_DELETE'}",
    # File Storage
    "allow group ${join(",",local.storage_admin_group_name)} to read file-family in compartment ${local.appdev_compartment_name}",
    "allow group ${join(",",local.storage_admin_group_name)} to manage file-family in compartment ${local.appdev_compartment_name} where any {request.permission = 'FILE_SYSTEM_DELETE', request.permission = 'MOUNT_TARGET_DELETE', request.permission = 'EXPORT_SET_UPDATE', request.permission = 'FILE_SYSTEM_NFSv3_UNEXPORT', request.permission = 'EXPORT_SET_DELETE', request.permission = 'FILE_SYSTEM_DELETE_SNAPSHOT'}",
    # Grants in database compartment
    # Object Storage
    "allow group ${join(",",local.storage_admin_group_name)} to read bucket in compartment ${local.database_compartment_name}",
    "allow group ${join(",",local.storage_admin_group_name)} to inspect object in compartment ${local.database_compartment_name}",
    "allow group ${join(",",local.storage_admin_group_name)} to manage object-family in compartment ${local.database_compartment_name} where any {request.permission = 'OBJECT_DELETE', request.permission = 'BUCKET_DELETE'}",
    # Volume Storage
    "allow group ${join(",",local.storage_admin_group_name)} to read volume-family in compartment ${local.database_compartment_name}",
    "allow group ${join(",",local.storage_admin_group_name)} to manage volume-family in compartment ${local.database_compartment_name} where any {request.permission = 'VOLUME_DELETE', request.permission = 'VOLUME_BACKUP_DELETE', request.permission = 'BOOT_VOLUME_BACKUP_DELETE'}",
    # File Storage
    "allow group ${join(",",local.storage_admin_group_name)} to read file-family in compartment ${local.database_compartment_name}",
    "allow group ${join(",",local.storage_admin_group_name)} to manage file-family in compartment ${local.database_compartment_name} where any {request.permission = 'FILE_SYSTEM_DELETE', request.permission = 'MOUNT_TARGET_DELETE', request.permission = 'EXPORT_SET_UPDATE', request.permission = 'FILE_SYSTEM_NFSv3_UNEXPORT', request.permission = 'EXPORT_SET_DELETE', request.permission = 'FILE_SYSTEM_DELETE_SNAPSHOT'}",
    # Grants in security compartment
    # Object Storage
    "allow group ${join(",",local.storage_admin_group_name)} to read bucket in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.storage_admin_group_name)} to inspect object in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.storage_admin_group_name)} to manage object-family in compartment ${local.security_compartment_name} where any {request.permission = 'OBJECT_DELETE', request.permission = 'BUCKET_DELETE'}",
    # Volume Storage
    "allow group ${join(",",local.storage_admin_group_name)} to read volume-family in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.storage_admin_group_name)} to manage volume-family in compartment ${local.security_compartment_name} where any {request.permission = 'VOLUME_DELETE', request.permission = 'VOLUME_BACKUP_DELETE', request.permission = 'BOOT_VOLUME_BACKUP_DELETE'}",
    # File Storage
    "allow group ${join(",",local.storage_admin_group_name)} to read file-family in compartment ${local.security_compartment_name}",
    "allow group ${join(",",local.storage_admin_group_name)} to manage file-family in compartment ${local.security_compartment_name} where any {request.permission = 'FILE_SYSTEM_DELETE', request.permission = 'MOUNT_TARGET_DELETE', request.permission = 'EXPORT_SET_UPDATE', request.permission = 'FILE_SYSTEM_NFSv3_UNEXPORT', request.permission = 'EXPORT_SET_DELETE', request.permission = 'FILE_SYSTEM_DELETE_SNAPSHOT'}",
    # Grants in network compartment
    # Object Storage
    "allow group ${join(",",local.storage_admin_group_name)} to read bucket in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.storage_admin_group_name)} to inspect object in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.storage_admin_group_name)} to manage object-family in compartment ${local.network_compartment_name} where any {request.permission = 'OBJECT_DELETE', request.permission = 'BUCKET_DELETE'}",
    # Volume Storage
    "allow group ${join(",",local.storage_admin_group_name)} to read volume-family in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.storage_admin_group_name)} to manage volume-family in compartment ${local.network_compartment_name} where any {request.permission = 'VOLUME_DELETE', request.permission = 'VOLUME_BACKUP_DELETE', request.permission = 'BOOT_VOLUME_BACKUP_DELETE'}",
    # File Storage
    "allow group ${join(",",local.storage_admin_group_name)} to read file-family in compartment ${local.network_compartment_name}",
    "allow group ${join(",",local.storage_admin_group_name)} to manage file-family in compartment ${local.network_compartment_name} where any {request.permission = 'FILE_SYSTEM_DELETE', request.permission = 'MOUNT_TARGET_DELETE', request.permission = 'VNIC_DELETE', request.permission = 'SUBNET_DETACH', request.permission = 'VNIC_DETACH', request.permission = 'PRIVATE_IP_DELETE', request.permission = 'PRIVATE_IP_UNASSIGN', request.permission = 'VNIC_UNASSIGN', request.permission = 'EXPORT_SET_UPDATE', request.permission = 'FILE_SYSTEM_NFSv3_UNEXPORT', request.permission = 'EXPORT_SET_DELETE', request.permission = 'FILE_SYSTEM_DELETE_SNAPSHOT'}",
  ]
    default_policies = { 
      (local.compute_agent_policy_name) = {
        compartment_ocid = local.enclosing_compartment_id
        name            = local.compute_agent_policy_name
        description     = "Landing Zone policy for ${local.appdev_computeagent_dynamic_group_name} group to manage compute agent related services."
        defined_tags    = local.policies_defined_tags
        freeform_tags   = local.policies_freeform_tags
        statements      = local.compute_agent_grants
      },
      (local.database_dynamic_group_policy_name) = {
        compartment_ocid = local.enclosing_compartment_id
        name             = local.database_dynamic_group_policy_name
        description      = "Landing Zone policy for ${local.database_kms_dynamic_group_name} group to use keys in compartment ${local.security_compartment_name}."
        defined_tags     = local.policies_defined_tags
        freeform_tags    = local.policies_freeform_tags
        statements       = local.autonomous_database_grants
      },
       (local.network_admin_policy_name) = length(local.network_admin_grants) > 0 ? {
        compartment_ocid = local.enclosing_compartment_id
        name = local.network_admin_policy_name
        description    = "Landing Zone policy for ${join(",",local.network_admin_group_name)} group to manage network related services."
        defined_tags   = local.policies_defined_tags
        freeform_tags  = local.policies_freeform_tags
        statements = local.network_admin_grants
      } : null,
      (local.security_admin_policy_name) = length(local.security_admin_grants) > 0 ? {
        compartment_ocid = local.enclosing_compartment_id
        name = local.security_admin_policy_name
        description    = "Landing Zone policy for ${join(",",local.security_admin_group_name)} group to manage security related services in Landing Zone enclosing compartment (${local.policy_scope})."
        defined_tags   = local.policies_defined_tags
        freeform_tags  = local.policies_freeform_tags
        statements     = local.security_admin_grants
      } : null,
      (local.database_admin_policy_name) = length(local.database_admin_grants) > 0 ? {
        compartment_ocid = local.enclosing_compartment_id
        name = local.database_admin_policy_name
        description    = "Landing Zone policy for ${join(",",local.database_admin_group_name)} group to manage database related resources."
        defined_tags   = local.policies_defined_tags
        freeform_tags  = local.policies_freeform_tags
        statements = local.database_admin_grants
      } : null,
      (local.appdev_admin_policy_name) = length(local.appdev_admin_grants) > 0 ? {
        compartment_ocid = local.enclosing_compartment_id
        name = local.appdev_admin_policy_name
        description    = "Landing Zone policy for ${join(",",local.appdev_admin_group_name)} group to manage app development related services."
        defined_tags   = local.policies_defined_tags
        freeform_tags  = local.policies_freeform_tags
        statements     = local.appdev_admin_grants
      } : null,
      (local.iam_admin_policy_name) = length(local.iam_admin_grants_on_enclosing_cmp) > 0 ? {
        compartment_ocid = local.enclosing_compartment_id
        name = local.iam_admin_policy_name
        description    = "Landing Zone policy for ${join(",",local.iam_admin_group_name)} group to manage IAM resources in Landing Zone enclosing compartment (${local.policy_scope})."
        defined_tags   = local.policies_defined_tags
        freeform_tags  = local.policies_freeform_tags
        statements     = local.iam_admin_grants_on_enclosing_cmp
      } : null,
      (local.storage_admin_policy_name) = length(local.storage_admin_grants) > 0 ? {
        compartment_ocid = local.enclosing_compartment_id
        name = local.storage_admin_policy_name
        description    = "Landing Zone policy for ${join(",",local.storage_admin_group_name)} group to manage storage resources."
        defined_tags   = local.policies_defined_tags
        freeform_tags  = local.policies_freeform_tags
        statements     = local.storage_admin_grants
      } : null,
    }

    exainfra_policy = var.deploy_exainfra_cmp == true ? {
      (local.exainfra_admin_policy_name) = length(local.exainfra_admin_grants) > 0 ? {
        compartment_ocid = local.enclosing_compartment_id
        name = local.exainfra_admin_policy_name
        description = "Landing Zone policy for ${join(",",local.exainfra_admin_group_name)} group to manage Exadata infrastructures in compartment ${local.exainfra_compartment_name}."
        defined_tags = local.policies_defined_tags
        freeform_tags = local.policies_freeform_tags
        statements  = local.exainfra_admin_grants
      } : null
    } : {}
  
    policies = merge(local.default_policies, local.exainfra_policy)

    #-- Basic grants on Root compartment
    basic_grants_default_grantees = concat(local.security_admin_group_name, local.network_admin_group_name, local.appdev_admin_group_name, local.database_admin_group_name, local.storage_admin_group_name)
    basic_grants_grantees = var.deploy_exainfra_cmp == true ? concat(local.basic_grants_default_grantees,local.exainfra_admin_group_name) : local.basic_grants_default_grantees
    basic_grants_on_root_cmp = [
      "allow group ${join(",",local.basic_grants_grantees)} to use cloud-shell in tenancy",
      "allow group ${join(",",local.basic_grants_grantees)} to read usage-budgets in tenancy",
      "allow group ${join(",",local.basic_grants_grantees)} to read usage-reports in tenancy",
      "allow group ${join(",",local.basic_grants_grantees)} to read objectstorage-namespaces in tenancy"
    ]

    root_policies = {
      (local.basic_root_policy_name) = {
        compartment_ocid = var.tenancy_ocid
        name = local.basic_root_policy_name
        description    = "CIS Landing Zone basic root compartment policy."
        defined_tags   = local.policies_defined_tags
        freeform_tags  = local.policies_freeform_tags
        statements     = local.basic_grants_on_root_cmp
      }
      (local.security_admin_root_policy_name) = {
        compartment_ocid = var.tenancy_ocid
        name = local.security_admin_root_policy_name
        description    = "CIS Landing Zone root compartment policy for ${join(",",local.security_admin_group_name)} group."
        defined_tags   = local.policies_defined_tags
        freeform_tags  = local.policies_freeform_tags
        statements     = local.security_admin_grants_on_root_cmp
      },
      (local.iam_admin_root_policy_name) = {
        compartment_ocid = var.tenancy_ocid
        name = local.iam_admin_root_policy_name
        description    = "CIS Landing Zone root compartment policy for ${join(",",local.iam_admin_group_name)} group."
        defined_tags   = local.policies_defined_tags
        freeform_tags  = local.policies_freeform_tags
        statements     = local.iam_admin_grants_on_root_cmp
      },
      (local.auditor_policy_name) = {
        compartment_ocid = var.tenancy_ocid
        name = local.auditor_policy_name
        description    = "CIS Landing Zone root compartment policy for ${join(",",local.auditor_group_name)} group."
        defined_tags = local.policies_defined_tags
        freeform_tags = local.policies_freeform_tags
        statements = [
          "allow group ${join(",",local.auditor_group_name)} to inspect all-resources in tenancy",
          "allow group ${join(",",local.auditor_group_name)} to read instances in tenancy",
          "allow group ${join(",",local.auditor_group_name)} to read load-balancers in tenancy",
          "allow group ${join(",",local.auditor_group_name)} to read buckets in tenancy",
          "allow group ${join(",",local.auditor_group_name)} to read nat-gateways in tenancy",
          "allow group ${join(",",local.auditor_group_name)} to read public-ips in tenancy",
          "allow group ${join(",",local.auditor_group_name)} to read file-family in tenancy",
          "allow group ${join(",",local.auditor_group_name)} to read instance-configurations in tenancy",
          "allow group ${join(",",local.auditor_group_name)} to read network-security-groups in tenancy",
          "allow group ${join(",",local.auditor_group_name)} to read resource-availability in tenancy",
          "allow group ${join(",",local.auditor_group_name)} to read audit-events in tenancy",
          "allow group ${join(",",local.auditor_group_name)} to read users in tenancy",
          "allow group ${join(",",local.auditor_group_name)} to use cloud-shell in tenancy",
          "allow group ${join(",",local.auditor_group_name)} to read vss-family in tenancy",       
          "allow group ${join(",",local.auditor_group_name)} to read usage-budgets in tenancy" ,
          "allow group ${join(",",local.auditor_group_name)} to read usage-reports in tenancy",
          "allow group ${join(",",local.auditor_group_name)} to read data-safe-family in tenancy"
        ]
      },
      (local.announcement_reader_policy_name) = {
        compartment_ocid = var.tenancy_ocid
        name = local.announcement_reader_policy_name
        description    = "CIS Landing Zone root compartment policy for ${join(",",local.announcement_reader_group_name)} group."
        defined_tags   = local.policies_defined_tags
        freeform_tags  = local.policies_freeform_tags
        statements = [
          "allow group ${join(",",local.announcement_reader_group_name)} to read announcements in tenancy",
          "allow group ${join(",",local.announcement_reader_group_name)} to use cloud-shell in tenancy"
        ]
      },
      (local.cred_admin_policy_name) = {
        compartment_ocid = var.tenancy_ocid
        name = local.cred_admin_policy_name
        description    = "CIS Landing Zone root compartment policy for ${join(",",local.cred_admin_group_name)} group."
        defined_tags   = local.policies_defined_tags
        freeform_tags  = local.policies_freeform_tags
        statements = [
          "allow group ${join(",",local.cred_admin_group_name)} to inspect users in tenancy",
          "allow group ${join(",",local.cred_admin_group_name)} to inspect groups in tenancy",
          "allow group ${join(",",local.cred_admin_group_name)} to manage users in tenancy  where any {request.operation = 'ListApiKeys',request.operation = 'ListAuthTokens',request.operation = 'ListCustomerSecretKeys',request.operation = 'UploadApiKey',request.operation = 'DeleteApiKey',request.operation = 'UpdateAuthToken',request.operation = 'CreateAuthToken',request.operation = 'DeleteAuthToken',request.operation = 'CreateSecretKey',request.operation = 'UpdateCustomerSecretKey',request.operation = 'DeleteCustomerSecretKey',request.operation = 'UpdateUserCapabilities'}",
          "allow group ${join(",",local.cred_admin_group_name)} to use cloud-shell in tenancy"
        ]
      },
      (local.cost_admin_root_policy_name) = {
        compartment_ocid = var.tenancy_ocid
        name = local.cost_admin_root_policy_name
        description    = "CIS Landing Zone root compartment policy for ${join(",",local.cost_admin_group_name)} group."
        defined_tags   = local.policies_defined_tags
        freeform_tags  = local.policies_freeform_tags
        statements     = local.cost_root_permissions
      }
    }
}

module "lz_root_policies" {
  depends_on = [module.lz_top_compartment, module.lz_groups] ### Explicitly declaring dependencies on the group and compartments modules.
  source = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam/policies"
  providers  = { oci = oci.home }
  tenancy_ocid = var.tenancy_ocid
  policies_configuration = var.extend_landing_zone_to_new_region == false && var.enable_template_policies == false ? (local.use_existing_root_cmp_grants == true ? local.empty_policies_configuration : local.root_policies_configuration) : local.empty_policies_configuration
}

module "lz_policies" {
  depends_on = [module.lz_compartments, module.lz_groups, module.lz_dynamic_groups]
  source = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam/policies"
  providers = { oci = oci.home }
  tenancy_ocid = var.tenancy_ocid
  policies_configuration = var.extend_landing_zone_to_new_region == false && var.enable_template_policies == false ? local.policies_configuration : local.empty_policies_configuration
}

locals {
  #----------------------------------------------------------------------- 
  #-- These variables are NOT meant to be overriden.
  #-----------------------------------------------------------------------
  default_policies_defined_tags = null
  default_policies_freeform_tags = local.landing_zone_tags

  policies_defined_tags = local.custom_policies_defined_tags != null ? merge(local.custom_policies_defined_tags, local.default_policies_defined_tags) : local.default_policies_defined_tags
  policies_freeform_tags = local.custom_policies_freeform_tags != null ? merge(local.custom_policies_freeform_tags, local.default_policies_freeform_tags) : local.default_policies_freeform_tags

  policy_scope = local.enclosing_compartment_name == "tenancy" ? "tenancy" : "compartment ${local.enclosing_compartment_name}"
  
  use_existing_root_cmp_grants    = upper(var.policies_in_root_compartment) == "CREATE" ? false : true

  root_policies_configuration = {
    enable_cis_benchmark_checks : true
    supplied_policies : local.root_policies
  }

  policies_configuration = {
    enable_cis_benchmark_checks : true
    supplied_policies : local.policies
  }

  # Helper object meaning no policies. It satisfies Terraform's ternary operator.
  empty_policies_configuration = {
    enable_cis_benchmark_checks : false
    supplied_policies : null
  }
}