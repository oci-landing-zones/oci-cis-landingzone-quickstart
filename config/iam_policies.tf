# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration provisions Landing Zone policies.

locals {
  // IAM admin permissions to be created always at the root compartment
  iam_root_permissions = ["Allow group ${local.iam_admin_group_name} to inspect users in tenancy",
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

  // IAM admin permissions to be created always at the enclosing compartment level, which *can* be the root compartment
  iam_enccmp_permissions = ["Allow group ${local.iam_admin_group_name} to manage policies in ${local.policy_scope}",
    "Allow group ${local.iam_admin_group_name} to manage compartments in ${local.policy_scope}",
    "Allow group ${local.iam_admin_group_name} to manage tag-defaults in ${local.policy_scope}",
    "Allow group ${local.iam_admin_group_name} to manage tag-namespaces in ${local.policy_scope}",
    "Allow group ${local.iam_admin_group_name} to manage orm-stacks in ${local.policy_scope}",
    "Allow group ${local.iam_admin_group_name} to manage orm-jobs in ${local.policy_scope}",
  "Allow group ${local.iam_admin_group_name} to manage orm-config-source-providers in ${local.policy_scope}"]

  // Security admin permissions to be created always at the root compartment
  security_root_permissions = ["Allow group ${local.security_admin_group_name} to manage cloudevents-rules in tenancy",
    "Allow group ${local.security_admin_group_name} to manage cloud-guard-family in tenancy",
    "Allow group ${local.security_admin_group_name} to read tenancies in tenancy",
    "Allow group ${local.security_admin_group_name} to read objectstorage-namespaces in tenancy",
    "Allow group ${local.security_admin_group_name} to use cloud-shell in tenancy",
    "Allow group ${local.security_admin_group_name} to read usage-budgets in tenancy",
    "Allow group ${local.security_admin_group_name} to read usage-reports in tenancy"]

  // Security admin permissions to be created always at the enclosing compartment level, which *can* be the root compartment
  security_enccmp_permissions = ["Allow group ${local.security_admin_group_name} to manage tag-namespaces in ${local.policy_scope}",
    "Allow group ${local.security_admin_group_name} to manage tag-defaults in ${local.policy_scope}",
    "Allow group ${local.security_admin_group_name} to manage repos in ${local.policy_scope}",
    "Allow group ${local.security_admin_group_name} to read audit-events in ${local.policy_scope}",
    "Allow group ${local.security_admin_group_name} to read app-catalog-listing in ${local.policy_scope}",
    "Allow group ${local.security_admin_group_name} to read instance-images in ${local.policy_scope}",
  "Allow group ${local.security_admin_group_name} to inspect buckets in ${local.policy_scope}"]

  ## Security admin permissions 
  security_permissions = ["Allow group ${local.security_admin_group_name} to read all-resources in compartment ${local.security_compartment.name}",
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
    "Allow group ${local.security_admin_group_name} to read virtual-network-family in compartment ${local.network_compartment.name}",
    "Allow group ${local.security_admin_group_name} to use subnets in compartment ${local.network_compartment.name}",
    "Allow group ${local.security_admin_group_name} to use network-security-groups in compartment ${local.network_compartment.name}",
    "Allow group ${local.security_admin_group_name} to use vnics in compartment ${local.network_compartment.name}",
    "Allow group ${local.security_admin_group_name} to manage orm-stacks in compartment ${local.security_compartment.name}",
    "Allow group ${local.security_admin_group_name} to manage orm-jobs in compartment ${local.security_compartment.name}",
    "Allow group ${local.security_admin_group_name} to manage orm-config-source-providers in compartment ${local.security_compartment.name}",
    "Allow group ${local.security_admin_group_name} to manage vss-family in compartment ${local.security_compartment.name}",
    "Allow group ${local.security_admin_group_name} to read work-requests in compartment ${local.security_compartment.name}",
    "Allow group ${local.security_admin_group_name} to manage bastion-family in compartment ${local.security_compartment.name}",
    "Allow group ${local.security_admin_group_name} to read instance-agent-plugins in compartment ${local.security_compartment.name}",
    "Allow group ${local.security_admin_group_name} to manage cloudevents-rules in compartment ${local.security_compartment.name}",
    "Allow group ${local.security_admin_group_name} to manage alarms in compartment ${local.security_compartment.name}",
    "Allow group ${local.security_admin_group_name} to manage metrics in compartment ${local.security_compartment.name}"]

  ##Compute Agent Permissions
  compute_agent_permissions = ["Allow dynamic-group ${local.compute_agent_group_name} to manage management-agents in compartment ${local.appdev_compartment.name}",
        "Allow dynamic-group ${local.compute_agent_group_name} to use metrics in compartment ${local.appdev_compartment.name}",
        "Allow dynamic-group ${local.compute_agent_group_name} to use tag-namespaces in compartment ${local.appdev_compartment.name}"]

  ## Network admin permissions
  network_permissions = ["Allow group ${local.network_admin_group_name} to read all-resources in compartment ${local.network_compartment.name}",
        "Allow group ${local.network_admin_group_name} to manage virtual-network-family in compartment ${local.network_compartment.name}",
        "Allow group ${local.network_admin_group_name} to manage dns in compartment ${local.network_compartment.name}",
        "Allow group ${local.network_admin_group_name} to manage load-balancers in compartment ${local.network_compartment.name}",
        "Allow group ${local.network_admin_group_name} to manage alarms in compartment ${local.network_compartment.name}",
        "Allow group ${local.network_admin_group_name} to manage metrics in compartment ${local.network_compartment.name}",
        "Allow group ${local.network_admin_group_name} to manage orm-stacks in compartment ${local.network_compartment.name}",
        "Allow group ${local.network_admin_group_name} to manage orm-jobs in compartment ${local.network_compartment.name}",
        "Allow group ${local.network_admin_group_name} to manage orm-config-source-providers in compartment ${local.network_compartment.name}",
        "Allow group ${local.network_admin_group_name} to read audit-events in compartment ${local.network_compartment.name}",
        "Allow group ${local.network_admin_group_name} to read vss-family in compartment ${local.security_compartment.name}",
        "Allow group ${local.network_admin_group_name} to read work-requests in compartment ${local.network_compartment.name}",
        "Allow group ${local.network_admin_group_name} to manage instance-family in compartment ${local.network_compartment.name}",
        "Allow group ${local.network_admin_group_name} to use bastion in compartment ${local.security_compartment.name}",
        "Allow group ${local.network_admin_group_name} to manage bastion-session in compartment ${local.security_compartment.name}",
        "Allow group ${local.network_admin_group_name} to manage bastion-session in compartment ${local.network_compartment.name}",
        "Allow group ${local.network_admin_group_name} to manage cloudevents-rules in compartment ${local.network_compartment.name}",
        "Allow group ${local.network_admin_group_name} to manage alarms in compartment ${local.network_compartment.name}",
        "Allow group ${local.network_admin_group_name} to manage metrics in compartment ${local.network_compartment.name}",
        "Allow group ${local.network_admin_group_name} to read instance-agent-plugins in compartment ${local.network_compartment.name}"]  

  ## Database admin permissions
  database_permissions = ["Allow group ${local.database_admin_group_name} to read all-resources in compartment ${local.database_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage database-family in compartment ${local.database_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage autonomous-database-family in compartment ${local.database_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage alarms in compartment ${local.database_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage metrics in compartment ${local.database_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage object-family in compartment ${local.database_compartment.name}",
        "Allow group ${local.database_admin_group_name} to read virtual-network-family in compartment ${local.network_compartment.name}",
        "Allow group ${local.database_admin_group_name} to use vnics in compartment ${local.network_compartment.name}",
        "Allow group ${local.database_admin_group_name} to use subnets in compartment ${local.network_compartment.name}",
        "Allow group ${local.database_admin_group_name} to use network-security-groups in compartment ${local.network_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage orm-stacks in compartment ${local.database_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage orm-jobs in compartment ${local.database_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage orm-config-source-providers in compartment ${local.database_compartment.name}",
        "Allow group ${local.database_admin_group_name} to read audit-events in compartment ${local.database_compartment.name}",
        "Allow group ${local.database_admin_group_name} to read vss-family in compartment ${local.security_compartment.name}",
        "Allow group ${local.database_admin_group_name} to read vaults in compartment ${local.security_compartment.name}",
        "Allow group ${local.database_admin_group_name} to inspect keys in compartment ${local.security_compartment.name}",
        "Allow group ${local.database_admin_group_name} to read work-requests in compartment ${local.database_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage instance-family in compartment ${local.database_compartment.name}",
        "Allow group ${local.database_admin_group_name} to use bastion in compartment ${local.security_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage bastion-session in compartment ${local.security_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage bastion-session in compartment ${local.database_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage cloudevents-rules in compartment ${local.database_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage alarms in compartment ${local.database_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage metrics in compartment ${local.database_compartment.name}",
        "Allow group ${local.database_admin_group_name} to read instance-agent-plugins in compartment ${local.database_compartment.name}"] 

  ## Exadata admin permissions
  database_permissions_on_exainfra_cmp = length(var.exacs_vcn_cidrs) > 0 && var.deploy_exainfra_cmp == true ? [
        "Allow group ${local.database_admin_group_name} to read cloud-exadata-infrastructures in compartment ${local.exainfra_compartment.name}",
        "Allow group ${local.database_admin_group_name} to use cloud-vmclusters in compartment ${local.exainfra_compartment.name}",
        "Allow group ${local.database_admin_group_name} to read work-requests in compartment ${local.exainfra_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage db-nodes in compartment ${local.exainfra_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage db-homes in compartment ${local.exainfra_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage databases in compartment ${local.exainfra_compartment.name}",
        "Allow group ${local.database_admin_group_name} to manage backups in compartment ${local.exainfra_compartment.name}"] : []     

  ## AppDev admin permissions
  appdev_permissions = ["Allow group ${local.appdev_admin_group_name} to read all-resources in compartment ${local.appdev_compartment.name}",
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
        "Allow group ${local.appdev_admin_group_name} to read virtual-network-family in compartment ${local.network_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to use subnets in compartment ${local.network_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to use network-security-groups in compartment ${local.network_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to use vnics in compartment ${local.network_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to use load-balancers in compartment ${local.network_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to read autonomous-database-family in compartment ${local.database_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to read database-family in compartment ${local.database_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to read vaults in compartment ${local.security_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to inspect keys in compartment ${local.security_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to read app-catalog-listing in ${local.policy_scope}",
        "Allow group ${local.appdev_admin_group_name} to manage instance-images in compartment ${local.security_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to read instance-images in ${local.policy_scope}",
        "Allow group ${local.appdev_admin_group_name} to manage repos in compartment ${local.appdev_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to read repos in ${local.policy_scope}",
        "Allow group ${local.appdev_admin_group_name} to manage orm-stacks in compartment ${local.appdev_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to manage orm-jobs in compartment ${local.appdev_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to manage orm-config-source-providers in compartment ${local.appdev_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to read audit-events in compartment ${local.appdev_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to read vss-family in compartment ${local.security_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to read work-requests in compartment ${local.appdev_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to use bastion in compartment ${local.security_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to manage bastion-session in compartment ${local.security_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to manage bastion-session in compartment ${local.appdev_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to manage cloudevents-rules in compartment ${local.appdev_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to manage alarms in compartment ${local.appdev_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to manage metrics in compartment ${local.appdev_compartment.name}",
        "Allow group ${local.appdev_admin_group_name} to read instance-agent-plugins in compartment ${local.appdev_compartment.name}"] 

    ## Exadata admin permissions
    exainfra_permissions = ["Allow group ${local.exainfra_admin_group_name} to manage cloud-exadata-infrastructures in compartment ${local.exainfra_compartment.name}",
                            "Allow group ${local.exainfra_admin_group_name} to manage cloud-vmclusters in compartment ${local.exainfra_compartment.name}",
                            "Allow group ${local.exainfra_admin_group_name} to read work-requests in compartment ${local.exainfra_compartment.name}",
                            # Grants for Bastion session creation
                            "Allow group ${local.exainfra_admin_group_name} to use bastion in compartment ${local.security_compartment.name}",
                            "Allow group ${local.exainfra_admin_group_name} to manage bastion-session in compartment ${local.security_compartment.name}",
                            "Allow group ${local.exainfra_admin_group_name} to manage bastion-session in compartment ${local.exainfra_compartment.name}",
                            "Allow group ${local.exainfra_admin_group_name} to manage instance-family in compartment ${local.exainfra_compartment.name}",
                            "Allow group ${local.exainfra_admin_group_name} to read instance-agent-plugins in compartment ${local.exainfra_compartment.name}",
                            "Allow group ${local.exainfra_admin_group_name} to read virtual-network-family in compartment ${local.network_compartment.name}"]

// Cost admin permissions to be created always at the root compartment
  cost_root_permissions = ["define tenancy usage-report as ocid1.tenancy.oc1..aaaaaaaaned4fkpkisbwjlr56u7cj63lf3wffbilvqknstgtvzub7vhqkggq", 
                           "Allow group ${local.cost_admin_group_name} to manage usage-report in tenancy",
                           "Allow group ${local.cost_admin_group_name} to manage usage-budgets in tenancy", 
                           "endorse group ${local.cost_admin_group_name} to read objects in tenancy usage-report"]


    default_policies = { 
      (local.compute_agent_policy_name) = {
        compartment_id = local.parent_compartment_id
        description    = "Landing Zone policy for ${local.compute_agent_group_name} group to manage compute agent related services."
        statements = local.compute_agent_permissions
      },
       (local.network_admin_policy_name) = {
        compartment_id = local.parent_compartment_id
        description    = "Landing Zone policy for ${local.network_admin_group_name} group to manage network related services."
        statements = local.network_permissions
      },
      (local.security_admin_policy_name) = {
        compartment_id = local.parent_compartment_id
        description    = "Landing Zone policy for ${local.security_admin_group_name} group to manage security related services in Landing Zone enclosing compartment (${local.policy_scope})."
        statements     = concat(local.security_enccmp_permissions, local.security_permissions)
      },
      (local.database_admin_policy_name) = {
        compartment_id = local.parent_compartment_id
        description    = "Landing Zone policy for ${local.database_admin_group_name} group to manage database related resources."
        statements = concat(local.database_permissions, local.database_permissions_on_exainfra_cmp)
      },
      (local.appdev_admin_policy_name) = {
        compartment_id = local.parent_compartment_id
        description    = "Landing Zone policy for ${local.appdev_admin_group_name} group to manage app development related services."
        statements = local.appdev_permissions
      },
      (local.iam_admin_policy_name) = {
        compartment_id = local.parent_compartment_id
        description    = "Landing Zone policy for ${local.iam_admin_group_name} group to manage IAM resources in Landing Zone enclosing compartment (${local.policy_scope})."
        statements     = local.iam_enccmp_permissions
      }
    }

    exainfra_policy = var.deploy_exainfra_cmp == true ? {
      (local.exainfra_admin_policy_name) = {
        compartment_id = local.parent_compartment_id
        description = "Landing Zone policy for ${local.exainfra_admin_group_name} group to manage Exadata infrastructures in compartment ${local.exainfra_compartment.name}."
        statements  = local.exainfra_permissions
      }
    } : {}
  
    policies = merge(local.default_policies, local.exainfra_policy)
}

module "lz_root_policies" {
  source     = "../modules/iam/iam-policy"
  providers  = { oci = oci.home }
  depends_on = [module.lz_groups, module.lz_compartments] ### Explicitly declaring dependencies on the group and compartments modules.
  policies = local.use_existing_tenancy_policies == false ? {
    (local.security_admin_root_policy_name) = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone ${local.security_admin_group_name}'s root compartment policy."
      statements     = local.security_root_permissions
    },
    (local.iam_admin_root_policy_name) = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone ${local.iam_admin_group_name}'s root compartment policy."
      statements     = local.iam_root_permissions
    },
    (local.network_admin_root_policy_name) = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone ${local.network_admin_group_name}'s root compartment policy."
      statements     = ["Allow group ${local.network_admin_group_name} to use cloud-shell in tenancy",
                        "Allow group ${local.network_admin_group_name} to read usage-budgets in tenancy",
                        "Allow group ${local.network_admin_group_name} to read usage-reports in tenancy"]
    },
    (local.appdev_admin_root_policy_name) = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone ${local.appdev_admin_group_name}'s root compartment policy."
      statements     = ["Allow group ${local.appdev_admin_group_name} to use cloud-shell in tenancy",
                        "Allow group ${local.appdev_admin_group_name} to read usage-budgets in tenancy",
                        "Allow group ${local.appdev_admin_group_name} to read usage-reports in tenancy"]
    },
    (local.database_admin_root_policy_name) = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone ${local.database_admin_group_name}'s root compartment policy."
      statements     = ["Allow group ${local.database_admin_group_name} to use cloud-shell in tenancy",
                        "Allow group ${local.database_admin_group_name} to read usage-budgets in tenancy",
                        "Allow group ${local.database_admin_group_name} to read usage-reports in tenancy"]
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
        "Allow group ${local.auditor_group_name} to read vss-family in tenancy",       
        "Allow group ${local.auditor_group_name} to read usage-budgets in tenancy" ,
        "Allow group ${local.auditor_group_name} to read usage-reports in tenancy"]
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
    },
    (local.cost_admin_root_policy_name) = {
      compartment_id = var.tenancy_ocid
      description    = "Landing Zone ${local.cost_admin_group_name}'s root compartment policy."
      statements     = local.cost_root_permissions
    }
  } : {}
}

module "lz_policies" {
  source     = "../modules/iam/iam-policy"
  providers  = { oci = oci.home }
  depends_on = [module.lz_groups, module.lz_dynamic_groups, module.lz_compartments] ### Explicitly declaring dependencies on the group and compartments modules.
  policies = local.policies
}
