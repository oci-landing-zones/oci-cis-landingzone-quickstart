# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration provisions Landing Zone policies.

locals {
  ## IAM admin grants at the root compartment
  iam_admin_grants_on_root_cmp = [
    "Allow group ${local.iam_admin_group_name} to inspect users in tenancy",
    "Allow group ${local.iam_admin_group_name} to inspect groups in tenancy",
    "Allow group ${local.iam_admin_group_name} to manage groups in tenancy where all {target.group.name != 'Administrators', target.group.name != '${local.cred_admin_group_name}'}",
    "Allow group ${local.iam_admin_group_name} to inspect identity-providers in tenancy",
    "Allow group ${local.iam_admin_group_name} to manage identity-providers in tenancy where any {request.operation = 'AddIdpGroupMapping', request.operation = 'DeleteIdpGroupMapping'}",
    "Allow group ${local.iam_admin_group_name} to manage dynamic-groups in tenancy",
    "Allow group ${local.iam_admin_group_name} to manage authentication-policies in tenancy",
    "Allow group ${local.iam_admin_group_name} to manage network-sources in tenancy",
    "Allow group ${local.iam_admin_group_name} to manage quota in tenancy",
    "Allow group ${local.iam_admin_group_name} to read audit-events in tenancy",
    "Allow group ${local.iam_admin_group_name} to use cloud-shell in tenancy"]

  ## IAM admin grants at the enclosing compartment level, which *can* be the root compartment
  iam_admin_grants_on_enclosing_cmp = var.use_existing_grants_in_enc_compartment == false ? [
    "Allow group ${local.iam_admin_group_name} to manage policies in ${local.policy_scope}",
    "Allow group ${local.iam_admin_group_name} to manage compartments in ${local.policy_scope}",
    "Allow group ${local.iam_admin_group_name} to manage tag-defaults in ${local.policy_scope}",
    "Allow group ${local.iam_admin_group_name} to manage tag-namespaces in ${local.policy_scope}",
    "Allow group ${local.iam_admin_group_name} to manage orm-stacks in ${local.policy_scope}",
    "Allow group ${local.iam_admin_group_name} to manage orm-jobs in ${local.policy_scope}",
    "Allow group ${local.iam_admin_group_name} to manage orm-config-source-providers in ${local.policy_scope}"] : []

  ## Security admin grants at the root compartment
  security_admin_grants_on_root_cmp = [
    "Allow group ${local.security_admin_group_name} to manage cloudevents-rules in tenancy",
    "Allow group ${local.security_admin_group_name} to manage cloud-guard-family in tenancy",
    "Allow group ${local.security_admin_group_name} to read tenancies in tenancy",
    "Allow group ${local.security_admin_group_name} to read objectstorage-namespaces in tenancy",
    "Allow group ${local.security_admin_group_name} to use cloud-shell in tenancy"]

  ## Security admin grants at the enclosing compartment level, which *can* be the root compartment
  security_admin_grants_on_enclosing_cmp = var.use_existing_grants_in_enc_compartment == false ? [
    "Allow group ${local.security_admin_group_name} to manage tag-namespaces in ${local.policy_scope}",
    "Allow group ${local.security_admin_group_name} to manage tag-defaults in ${local.policy_scope}",
    "Allow group ${local.security_admin_group_name} to manage repos in ${local.policy_scope}",
    "Allow group ${local.security_admin_group_name} to read audit-events in ${local.policy_scope}",
    "Allow group ${local.security_admin_group_name} to read app-catalog-listing in ${local.policy_scope}",
    "Allow group ${local.security_admin_group_name} to read instance-images in ${local.policy_scope}",
    "Allow group ${local.security_admin_group_name} to inspect buckets in ${local.policy_scope}"] : []

  ## Security admin grants on Security compartment
  security_admin_grants_on_security_cmp = var.existing_security_cmp_ocid == null ? [
    "Allow group ${local.security_admin_group_name} to read all-resources in compartment ${local.security_compartment.name}",
    "Allow group ${local.security_admin_group_name} to manage instance-family in compartment ${local.security_compartment.name}",
    "Allow group ${local.security_admin_group_name} to manage vaults in compartment ${local.security_compartment.name}",
    "Allow group ${local.security_admin_group_name} to manage keys in compartment ${local.security_compartment.name}",
    "Allow group ${local.security_admin_group_name} to manage secret-family in compartment ${local.security_compartment.name}",
    "Allow group ${local.security_admin_group_name} to manage logging-family in compartment ${local.security_compartment.name}",
    "Allow group ${local.security_admin_group_name} to manage serviceconnectors in compartment ${local.security_compartment.name}",
    "Allow group ${local.security_admin_group_name} to manage streams in compartment ${local.security_compartment.name}",
    "Allow group ${local.security_admin_group_name} to manage ons-family in compartment ${local.security_compartment.name}",
    "Allow group ${local.security_admin_group_name} to manage functions-family in compartment ${local.security_compartment.name}",
    "Allow group ${local.security_admin_group_name} to manage waas-family in compartment ${local.security_compartment.name}",
    "Allow group ${local.security_admin_group_name} to manage security-zone in compartment ${local.security_compartment.name}",
    "Allow group ${local.security_admin_group_name} to manage orm-stacks in compartment ${local.security_compartment.name}",
    "Allow group ${local.security_admin_group_name} to manage orm-jobs in compartment ${local.security_compartment.name}",
    "Allow group ${local.security_admin_group_name} to manage orm-config-source-providers in compartment ${local.security_compartment.name}",
    "Allow group ${local.security_admin_group_name} to manage vss-family in compartment ${local.security_compartment.name}",
    "Allow group ${local.security_admin_group_name} to read work-requests in compartment ${local.security_compartment.name}",
    "Allow group ${local.security_admin_group_name} to manage bastion-family in compartment ${local.security_compartment.name}",
    "Allow group ${local.security_admin_group_name} to read instance-agent-plugins in compartment ${local.security_compartment.name}"] : []

  ## Security admin grants on Network compartment
  security_admin_grants_on_network_cmp = var.existing_network_cmp_ocid == null ? [
    "Allow group ${local.security_admin_group_name} to read virtual-network-family in compartment ${local.network_compartment.name}",
    "Allow group ${local.security_admin_group_name} to use subnets in compartment ${local.network_compartment.name}",
    "Allow group ${local.security_admin_group_name} to use network-security-groups in compartment ${local.network_compartment.name}",
    "Allow group ${local.security_admin_group_name} to use vnics in compartment ${local.network_compartment.name}"] : [] 

  ## All security admin grants
  security_admin_grants = concat(local.security_admin_grants_on_enclosing_cmp, local.security_admin_grants_on_security_cmp, local.security_admin_grants_on_network_cmp)  

  ## Network admin grants on Network compartment
  network_admin_grants_on_network_cmp = var.existing_network_cmp_ocid == null ? [
        "Allow group ${local.network_admin_group_name} to read all-resources in compartment ${local.network_compartment.name}",
        "Allow group ${local.network_admin_group_name} to manage virtual-network-family in compartment ${local.network_compartment.name}",
        "Allow group ${local.network_admin_group_name} to manage dns in compartment ${local.network_compartment.name}",
        "Allow group ${local.network_admin_group_name} to manage load-balancers in compartment ${local.network_compartment.name}",
        "Allow group ${local.network_admin_group_name} to manage alarms in compartment ${local.network_compartment.name}",
        "Allow group ${local.network_admin_group_name} to manage metrics in compartment ${local.network_compartment.name}",
        "Allow group ${local.network_admin_group_name} to manage orm-stacks in compartment ${local.network_compartment.name}",
        "Allow group ${local.network_admin_group_name} to manage orm-jobs in compartment ${local.network_compartment.name}",
        "Allow group ${local.network_admin_group_name} to manage orm-config-source-providers in compartment ${local.network_compartment.name}",
        "Allow group ${local.network_admin_group_name} to read audit-events in compartment ${local.network_compartment.name}",
        "Allow group ${local.network_admin_group_name} to read work-requests in compartment ${local.network_compartment.name}",
        "Allow group ${local.network_admin_group_name} to manage instance-family in compartment ${local.network_compartment.name}",
        "Allow group ${local.network_admin_group_name} to manage bastion-session in compartment ${local.network_compartment.name}",
        "Allow group ${local.network_admin_group_name} to read instance-agent-plugins in compartment ${local.network_compartment.name}"] : [] 

  ## Network admin grants on Security compartment
  network_admin_grants_on_security_cmp = var.existing_security_cmp_ocid == null ? [
        "Allow group ${local.network_admin_group_name} to read vss-family in compartment ${local.security_compartment.name}",
        "Allow group ${local.network_admin_group_name} to use bastion in compartment ${local.security_compartment.name}",
        "Allow group ${local.network_admin_group_name} to manage bastion-session in compartment ${local.security_compartment.name}"] : []

  ## All network admin grants
  network_admin_grants = concat(local.network_admin_grants_on_network_cmp, local.network_admin_grants_on_security_cmp)      

  ## Database admin grants on Database compartment
  database_admin_grants_on_database_cmp = var.existing_database_cmp_ocid == null ? [
        "Allow group ${local.database_admin_group_name} to read all-resources in compartment ${local.database_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage database-family in compartment ${local.database_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage autonomous-database-family in compartment ${local.database_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage alarms in compartment ${local.database_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage metrics in compartment ${local.database_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage object-family in compartment ${local.database_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage orm-stacks in compartment ${local.database_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage orm-jobs in compartment ${local.database_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage orm-config-source-providers in compartment ${local.database_compartment.name}",
        "Allow group ${local.database_admin_group_name} to read audit-events in compartment ${local.database_compartment.name}",
        "Allow group ${local.database_admin_group_name} to read work-requests in compartment ${local.database_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage instance-family in compartment ${local.database_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage bastion-session in compartment ${local.database_compartment.name}",
        "Allow group ${local.database_admin_group_name} to read instance-agent-plugins in compartment ${local.database_compartment.name}"] : []

  ## Database admin grants on Network compartment
  database_admin_grants_on_network_cmp = var.existing_network_cmp_ocid == null ? [
        "Allow group ${local.database_admin_group_name} to read virtual-network-family in compartment ${local.network_compartment.name}",
        "Allow group ${local.database_admin_group_name} to use vnics in compartment ${local.network_compartment.name}",
        "Allow group ${local.database_admin_group_name} to use subnets in compartment ${local.network_compartment.name}",
        "Allow group ${local.database_admin_group_name} to use network-security-groups in compartment ${local.network_compartment.name}"] : []    

  ## Database admin grants on Security compartment
  database_admin_grants_on_security_cmp = var.existing_security_cmp_ocid == null ? [
        "Allow group ${local.database_admin_group_name} to read vss-family in compartment ${local.security_compartment.name}",
        "Allow group ${local.database_admin_group_name} to read vaults in compartment ${local.security_compartment.name}",
        "Allow group ${local.database_admin_group_name} to inspect keys in compartment ${local.security_compartment.name}",
        "Allow group ${local.database_admin_group_name} to use bastion in compartment ${local.security_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage bastion-session in compartment ${local.security_compartment.name}"] : []       

  ## Database admin grants on Exainfra compartment
  database_admin_grants_on_exainfra_cmp = length(var.exacs_vcn_cidrs) > 0 && var.deploy_exainfra_cmp == true && var.existing_exainfra_cmp_ocid == null ? [
        "Allow group ${local.database_admin_group_name} to read cloud-exadata-infrastructures in compartment ${local.exainfra_compartment.name}",
        "Allow group ${local.database_admin_group_name} to use cloud-vmclusters in compartment ${local.exainfra_compartment.name}",
        "Allow group ${local.database_admin_group_name} to read work-requests in compartment ${local.exainfra_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage db-nodes in compartment ${local.exainfra_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage db-homes in compartment ${local.exainfra_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage databases in compartment ${local.exainfra_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage backups in compartment ${local.exainfra_compartment.name}"] : []     

  ## All database admin grants
  database_admin_grants = concat(local.database_admin_grants_on_database_cmp, local.database_admin_grants_on_network_cmp, 
                                 local.database_admin_grants_on_security_cmp, local.database_admin_grants_on_exainfra_cmp)

  ## AppDev admin grants on AppDev compartment
  appdev_admin_grants_on_appdev_cmp = var.existing_appdev_cmp_ocid == null ? [
        "Allow group ${local.appdev_admin_group_name} to read all-resources in compartment ${local.appdev_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to manage functions-family in compartment ${local.appdev_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to manage api-gateway-family in compartment ${local.appdev_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to manage ons-family in compartment ${local.appdev_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to manage streams in compartment ${local.appdev_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to manage cluster-family in compartment ${local.appdev_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to manage alarms in compartment ${local.appdev_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to manage metrics in compartment ${local.appdev_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to manage logs in compartment ${local.appdev_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to manage instance-family in compartment ${local.appdev_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to manage volume-family in compartment ${local.appdev_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to manage object-family in compartment ${local.appdev_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to manage repos in compartment ${local.appdev_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to manage orm-stacks in compartment ${local.appdev_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to manage orm-jobs in compartment ${local.appdev_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to manage orm-config-source-providers in compartment ${local.appdev_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to read audit-events in compartment ${local.appdev_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to read work-requests in compartment ${local.appdev_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to manage bastion-session in compartment ${local.appdev_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to read instance-agent-plugins in compartment ${local.appdev_compartment.name}"] : []

  ## AppDev admin grants on Network compartment
  appdev_admin_grants_on_network_cmp = var.existing_network_cmp_ocid == null ? [
        "Allow group ${local.appdev_admin_group_name} to read virtual-network-family in compartment ${local.network_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to use subnets in compartment ${local.network_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to use network-security-groups in compartment ${local.network_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to use vnics in compartment ${local.network_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to use load-balancers in compartment ${local.network_compartment.name}"] : []    

  ## AppDev admin grants on Security compartment
  appdev_admin_grants_on_security_cmp = var.existing_security_cmp_ocid == null ? [
        "Allow group ${local.appdev_admin_group_name} to read vaults in compartment ${local.security_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to inspect keys in compartment ${local.security_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to manage instance-images in compartment ${local.security_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to read vss-family in compartment ${local.security_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to use bastion in compartment ${local.security_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to manage bastion-session in compartment ${local.security_compartment.name}"] : [] 

  ## AppDev admin grants on Database compartment
  appdev_admin_grants_on_database_cmp = var.existing_database_cmp_ocid == null ? [
        "Allow group ${local.appdev_admin_group_name} to read autonomous-database-family in compartment ${local.database_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to read database-family in compartment ${local.database_compartment.name}"] : [] 

  ## AppDev admin grants on enclosing compartment
  appdev_admin_grants_on_enclosing_cmp = var.existing_enclosing_compartment_ocid == null ? [
        "Allow group ${local.appdev_admin_group_name} to read app-catalog-listing in ${local.policy_scope}",
        "Allow group ${local.appdev_admin_group_name} to read instance-images in ${local.policy_scope}",
        "Allow group ${local.appdev_admin_group_name} to read repos in ${local.policy_scope}"] : []                   

  ## All AppDev admin grants
  appdev_admin_grants = concat(local.appdev_admin_grants_on_appdev_cmp, local.appdev_admin_grants_on_network_cmp,
                               local.appdev_admin_grants_on_security_cmp, local.appdev_admin_grants_on_database_cmp,
                               local.appdev_admin_grants_on_enclosing_cmp)

  ## Exainfra admin grants on Exinfra compartment
  exainfra_admin_grants_on_exainfra_cmp = var.existing_exainfra_cmp_ocid == null ? [
        "Allow group ${local.exainfra_admin_group_name} to manage cloud-exadata-infrastructures in compartment ${local.exainfra_compartment.name}",
        "Allow group ${local.exainfra_admin_group_name} to manage cloud-vmclusters in compartment ${local.exainfra_compartment.name}",
        "Allow group ${local.exainfra_admin_group_name} to read work-requests in compartment ${local.exainfra_compartment.name}",
        "Allow group ${local.exainfra_admin_group_name} to manage bastion-session in compartment ${local.exainfra_compartment.name}",
        "Allow group ${local.exainfra_admin_group_name} to manage instance-family in compartment ${local.exainfra_compartment.name}",
        "Allow group ${local.exainfra_admin_group_name} to read instance-agent-plugins in compartment ${local.exainfra_compartment.name}"] : []

  ## Exainfra admin grants on Security compartment
  exainfra_admin_grants_on_security_cmp = var.existing_security_cmp_ocid == null ? [
        "Allow group ${local.exainfra_admin_group_name} to use bastion in compartment ${local.security_compartment.name}",
        "Allow group ${local.exainfra_admin_group_name} to manage bastion-session in compartment ${local.security_compartment.name}"] : []  

  ## Exainfra admin grants on Network compartment
  exainfra_admin_grants_on_network_cmp = var.existing_network_cmp_ocid == null ? [
        "Allow group ${local.exainfra_admin_group_name} to read virtual-network-family in compartment ${local.network_compartment.name}"] : [] 

  ## All Exainfra admin grants 
  exainfra_admin_grants = concat(local.exainfra_admin_grants_on_exainfra_cmp, local.exainfra_admin_grants_on_security_cmp, local.exainfra_admin_grants_on_network_cmp)

    default_policies = { 
      (local.network_admin_policy_name) = length(local.network_admin_grants) > 0 ? {
        compartment_id = local.parent_compartment_id
        description    = "Landing Zone policy for ${local.network_admin_group_name} group to manage network related services."
        statements = local.network_admin_grants
      } : null,
      (local.security_admin_policy_name) = length(local.security_admin_grants) > 0 ? {
        compartment_id = local.parent_compartment_id
        description    = "Landing Zone policy for ${local.security_admin_group_name} group to manage security related services in Landing Zone enclosing compartment (${local.policy_scope})."
        statements     = local.security_admin_grants
      } : null,
      (local.database_admin_policy_name) = length(local.database_admin_grants) > 0 ? {
        compartment_id = local.parent_compartment_id
        description    = "Landing Zone policy for ${local.database_admin_group_name} group to manage database related resources."
        statements = local.database_admin_grants
      } : null,
      (local.appdev_admin_policy_name) = length(local.appdev_admin_grants) > 0 ? {
        compartment_id = local.parent_compartment_id
        description    = "Landing Zone policy for ${local.appdev_admin_group_name} group to manage app development related services."
        statements = local.appdev_admin_grants
      } : null,
      (local.iam_admin_policy_name) = length(local.iam_admin_grants_on_enclosing_cmp) > 0 ? {
        compartment_id = local.parent_compartment_id
        description    = "Landing Zone policy for ${local.iam_admin_group_name} group to manage IAM resources in Landing Zone enclosing compartment (${local.policy_scope})."
        statements     = local.iam_admin_grants_on_enclosing_cmp
      } : null
    }

    exainfra_policy = length(var.exacs_vcn_cidrs) > 0 && var.deploy_exainfra_cmp == true ? {
      (local.exainfra_admin_policy_name) = length(local.exainfra_admin_grants) > 0 ? {
        compartment_id = local.parent_compartment_id
        description = "Landing Zone policy for ${local.exainfra_admin_group_name} group to manage Exadata infrastructures in compartment ${local.exainfra_compartment.name}."
        statements  = local.exainfra_admin_grants
      } : null
    } : {}
  
    policies = merge(local.default_policies, local.exainfra_policy)
}

module "lz_root_policies" {
  source     = "../modules/iam/iam-policy"
  providers  = { oci = oci.home }
  depends_on = [module.lz_groups, module.lz_compartments] ### Explicitly declaring dependencies on the group and compartments modules.
  policies = local.use_existing_root_cmp_grants == false ? {
    (local.security_admin_root_policy_name) = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone ${local.security_admin_group_name}'s root compartment policy."
      statements     = local.security_admin_grants_on_root_cmp
    },
    (local.iam_admin_root_policy_name) = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone ${local.iam_admin_group_name}'s root compartment policy."
      statements     = local.iam_admin_grants_on_root_cmp
    },
    (local.network_admin_root_policy_name) = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone ${local.network_admin_group_name}'s root compartment policy."
      statements     = ["Allow group ${local.network_admin_group_name} to use cloud-shell in tenancy"]
    },
    (local.appdev_admin_root_policy_name) = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone ${local.appdev_admin_group_name}'s root compartment policy."
      statements     = ["Allow group ${local.appdev_admin_group_name} to use cloud-shell in tenancy"]
    },
    (local.database_admin_root_policy_name) = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone ${local.database_admin_group_name}'s root compartment policy."
      statements     = ["Allow group ${local.database_admin_group_name} to use cloud-shell in tenancy"]
    },
    (local.auditor_policy_name) = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone ${local.auditor_group_name}'s root compartment policy."
      statements = ["Allow group ${local.auditor_group_name} to inspect all-resources in tenancy",
        "Allow group ${local.auditor_group_name} to read instances in tenancy",
        "Allow group ${local.auditor_group_name} to read load-balancers in tenancy",
        "Allow group ${local.auditor_group_name} to read buckets in tenancy",
        "Allow group ${local.auditor_group_name} to read nat-gateways in tenancy",
        "Allow group ${local.auditor_group_name} to read public-ips in tenancy",
        "Allow group ${local.auditor_group_name} to read file-family in tenancy",
        "Allow group ${local.auditor_group_name} to read instance-configurations in tenancy",
        "Allow group ${local.auditor_group_name} to read network-security-groups in tenancy",
        "Allow group ${local.auditor_group_name} to read resource-availability in tenancy",
        "Allow group ${local.auditor_group_name} to read audit-events in tenancy",
        "Allow group ${local.auditor_group_name} to read users in tenancy",
        "Allow group ${local.auditor_group_name} to use cloud-shell in tenancy",
        "Allow group ${local.auditor_group_name} to read vss-family in tenancy"]
    },
    (local.announcement_reader_policy_name) = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone ${local.announcement_reader_group_name}'s root compartment policy."
      statements = ["Allow group ${local.announcement_reader_group_name} to read announcements in tenancy",
                    "Allow group ${local.announcement_reader_group_name} to use cloud-shell in tenancy"]
    },
    (local.cred_admin_policy_name) = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone ${local.cred_admin_group_name}'s root compartment policy."
      statements = ["Allow group ${local.cred_admin_group_name} to inspect users in tenancy",
        "Allow group ${local.cred_admin_group_name} to inspect groups in tenancy",
        "Allow group ${local.cred_admin_group_name} to manage users in tenancy  where any {request.operation = 'ListApiKeys',request.operation = 'ListAuthTokens',request.operation = 'ListCustomerSecretKeys',request.operation = 'UploadApiKey',request.operation = 'DeleteApiKey',request.operation = 'UpdateAuthToken',request.operation = 'CreateAuthToken',request.operation = 'DeleteAuthToken',request.operation = 'CreateSecretKey',request.operation = 'UpdateCustomerSecretKey',request.operation = 'DeleteCustomerSecretKey',request.operation = 'UpdateUserCapabilities'}",
        "Allow group ${local.cred_admin_group_name} to use cloud-shell in tenancy"]
    }
  } : {}
}

module "lz_policies" {
  source     = "../modules/iam/iam-policy"
  providers  = { oci = oci.home }
  depends_on = [module.lz_groups, module.lz_compartments] ### Explicitly declaring dependencies on the group and compartments modules.
  policies = local.policies
}
