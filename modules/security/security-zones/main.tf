/**
 * ## CIS OCI Landing Zone Security Zone Module.
 *
 * This module manages Cloud Guard Security Zones targets and recipes. 
 * It manages multiple Security Zones and recipes in var.sz_target_compartments and the policies for those recipes in var.security_policies
 * The module will create one recipe for each compartment and create a Security Zone for each compartment with the associated recipe.
 * Each recipe will include CIS Level 1 or CIS Level 2 polices based on var.cis_level and append the customer provided polices in var.security_policies
 */
# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

data "oci_cloud_guard_security_policies" "these" {
  compartment_id = var.compartment_id
}

locals {

  sz_suffix        = "security-zone"
  sz_recipe_suffix = "${local.sz_suffix}-recipe"

  # Security Zone recipes aligned to CIS 1.2 Level 1
  cis_1_2_l1_policy_names = ["deny public_buckets", "deny db_instance_public_access"]
  # Security Zone recipes aligned to CIS 1.2 Level 2
  cis_1_2_l2_policy_names = ["deny block_volume_without_vault_key", "deny boot_volume_without_vault_key", "deny buckets_without_vault_key", "deny file_system_without_vault_key"]

  sz_policies = {for policy in data.oci_cloud_guard_security_policies.these.security_policy_collection[0].items : policy.friendly_name => policy.id}

  cis_1_2_l1_policy_ocids = [for name in local.cis_1_2_l1_policy_names : local.sz_policies[name]]
  cis_1_2_l2_policy_ocids = [for name in local.cis_1_2_l2_policy_names : local.sz_policies[name]]

  # For reference, below are the OCIDs for the policy names above in commercial realm regions
  # CIS 1.2 Level 1
  # "ocid1.securityzonessecuritypolicy.oc1..aaaaaaaa5ocyo7jqjzgjenvccch46buhpaaofplzxlp3xbxfcdwwk2tyrwqa"
  # "ocid1.securityzonessecuritypolicy.oc1..aaaaaaaauoi2xnbusvfd4yffdjaaazk64gndp4flumaw3r7vedwndqd6vmrq"
  # CIS 1.2 Level 2
  # "ocid1.securityzonessecuritypolicy.oc1..aaaaaaaa7pgtjyod3pze6wuylgmts6ensywmeplabsxqq2bk4ighps4fqq4a"
  # "ocid1.securityzonessecuritypolicy.oc1..aaaaaaaaxxs63ulmtcnxqmcvy6eaozh5jdtiaa2bk7wll5bbdsbnmmoczp5a"
  # "ocid1.securityzonessecuritypolicy.oc1..aaaaaaaaqmq4jqcxqbjj5cjzb7t5ira66dctyypq2m2o4psxmx6atp45lyda"
  # "ocid1.securityzonessecuritypolicy.oc1..aaaaaaaaff6n52aojbgdg46jpm3kn7nizmh6iwvr7myez7svtfxsfs7irigq"
  
  landing_zone_security_policies = coalesce(var.cis_level, "1") == "2" ? setunion(local.cis_1_2_l2_policy_ocids, local.cis_1_2_l1_policy_ocids, coalesce(var.security_policies, [])) : setunion(local.cis_1_2_l1_policy_ocids, coalesce(var.security_policies, []))
  
  security_zones = { for k, v in var.sz_target_compartments : k => {
    compartment_id         = v.sz_compartment_id
    sz_display_name        = "${v.sz_compartment_name}-${local.sz_suffix}"
    sz_recipe_display_name = "${v.sz_compartment_name}-${local.sz_recipe_suffix}"
    sz_description         = coalesce("${replace(v.sz_compartment_name, "-", " ")} security zone.", var.description)
    sz_recipe_description  = coalesce("${replace(v.sz_compartment_name, "-", " ")} security zone recipes.", var.description)
    security_policies      = local.landing_zone_security_policies
    defined_tags           = var.defined_tags
    freeform_tags          = var.freeform_tags
    }
  }
}

resource "oci_cloud_guard_security_recipe" "these" {
  for_each          = local.security_zones
  compartment_id    = each.value.compartment_id
  display_name      = each.value.sz_recipe_display_name
  description       = each.value.sz_recipe_description
  security_policies = each.value.security_policies
  defined_tags      = each.value.defined_tags
  freeform_tags     = each.value.freeform_tags
}

resource "oci_cloud_guard_security_zone" "these" {
  for_each                = local.security_zones
  compartment_id          = each.value.compartment_id
  display_name            = each.value.sz_display_name
  description             = each.value.sz_description
  security_zone_recipe_id = oci_cloud_guard_security_recipe.these[each.key].id
  defined_tags            = each.value.defined_tags
  freeform_tags           = each.value.freeform_tags
}