/**
 * ## CIS OCI Landing Zone Security Zone Module.
 *
 * This module manages Cloud Guard Security Zones targets and recipes. 
 * It manages multiple Security Zones and recipes in var.sz_target_compartments and the policies for those recipes in var.security_policies
 * The module will create one recipe for each compartment and create a Security Zone for each compartment with the assocaited recipe.
 * Each recipe will include CIS Level 1 or CIS Level 2 polices based on var.cis_level and append the customer provided polices in var.security_policies
 * key, as these keys can exist in different compartments.
 */
# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_providers {
    oci = {
      source = "hashicorp/oci"
    }
  }
}

locals {

    sz_suffix = "security-zone"
    sz_recipe_suffix = "${local.sz_suffix}-recipe"

    # Secuirty Zone recipes aligned to CIS 1.2 Level 1
    cis_1_2_L1 = [
        "ocid1.securityzonessecuritypolicy.oc1..aaaaaaaa5ocyo7jqjzgjenvccch46buhpaaofplzxlp3xbxfcdwwk2tyrwqa",
        "ocid1.securityzonessecuritypolicy.oc1..aaaaaaaauoi2xnbusvfd4yffdjaaazk64gndp4flumaw3r7vedwndqd6vmrq"
      ]
    # Secuirty Zone recipes aligned to CIS 1.2 Level 2
    cis_1_2_L2 = [
        "ocid1.securityzonessecuritypolicy.oc1..aaaaaaaa7pgtjyod3pze6wuylgmts6ensywmeplabsxqq2bk4ighps4fqq4a", 
        "ocid1.securityzonessecuritypolicy.oc1..aaaaaaaaxxs63ulmtcnxqmcvy6eaozh5jdtiaa2bk7wll5bbdsbnmmoczp5a",
        "ocid1.securityzonessecuritypolicy.oc1..aaaaaaaaqmq4jqcxqbjj5cjzb7t5ira66dctyypq2m2o4psxmx6atp45lyda",
        "ocid1.securityzonessecuritypolicy.oc1..aaaaaaaaff6n52aojbgdg46jpm3kn7nizmh6iwvr7myez7svtfxsfs7irigq",
    ]

  
  landing_zone_security_policies = coalesce(var.cis_level,"1") == "2" ? setunion(local.cis_1_2_L2,local.cis_1_2_L1,coalesce(var.security_policies,[])) : setunion(local.cis_1_2_L1,coalesce(var.security_policies,[]))

  security_zones = { for k, v in var.sz_target_compartments : k => {
    compartment_id          = v.sz_compartment_id
    sz_display_name         = "${v.sz_compartment_name}-${local.sz_suffix}"
    sz_recipe_display_name  = "${v.sz_compartment_name}-${local.sz_recipe_suffix}"
    sz_description          = coalesce("${replace(v.sz_compartment_name, "-", " ")} security zone.", var.description)
    sz_recipe_description   = coalesce("${replace(v.sz_compartment_name, "-", " ")} security zone recipes.", var.description)
    security_policies       = local.landing_zone_security_policies
    defined_tags            = var.defined_tags
    freeform_tags           = var.freeform_tags
  }
  }
  
}

resource "oci_cloud_guard_security_recipe" "these" {
  for_each = local.security_zones
      compartment_id    = each.value.compartment_id
      display_name      = each.value.sz_recipe_display_name
      description       = each.value.sz_recipe_description
      security_policies = each.value.security_policies
      defined_tags      = each.value.defined_tags
      freeform_tags     = each.value.freeform_tags
}

resource "oci_cloud_guard_security_zone" "these" {
  for_each = local.security_zones
      compartment_id          = each.value.compartment_id
      display_name            = each.value.sz_display_name
      description             = each.value.sz_description
      security_zone_recipe_id = oci_cloud_guard_security_recipe.these[each.key].id
      defined_tags            = each.value.defined_tags
      freeform_tags           = each.value.freeform_tags
}