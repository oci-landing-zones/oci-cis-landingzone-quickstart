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
    # Security Zones Keys
    single_compartment_sz_key     = "single-compartment-security-zone-key"
    enclosing_compartment_sz_key  = "enclosing-compartment-security-zone-key"
    appdev_compartment_sz_key     = "appdev-compartment-security-zone-key"
    database_compartment_sz_key   = "database-compartment-security-zone-key"
    network_compartment_sz_key    = "network-compartment-security-zone-key"
    security_compartment_sz_key   = "security-compartment-security-zone-key"
    exadata_compartment_sz_key    = "exadata-compartment-security-zone-key"
    
 
    # Security Zones Names
    single_compartment_sz_name      = var.single_compartment_id != null ? "${data.oci_identity_compartment.single_compartment[0].name}-security-zone" : "_void_"
    enclosing_compartment_sz_name   = var.enclosing_compartment_id != null ? "${data.oci_identity_compartment.enclosing_compartment[0].name}-security-zone" : "_void_"
    appdev_compartment_sz_name      = var.appdev_compartment_id != null ? "${data.oci_identity_compartment.appdev_compartment[0].name}-security-zone" : "_void_"
    database_compartment_sz_name    = var.database_compartment_id != null ? "${data.oci_identity_compartment.database_compartment[0].name}-security-zone" : "_void_"
    network_compartment_sz_name     = var.network_compartment_id != null ? "${data.oci_identity_compartment.network_compartment[0].name}-security-zone" : "_void_"
    security_compartment_sz_name    = var.security_compartment_id != null ? "${data.oci_identity_compartment.security_compartment[0].name}-security-zone" : "_void_"
    exadata_compartment_sz_name     = var.exadata_compartment_id != null ? "${data.oci_identity_compartment.exadata_compartment[0].name}-security-zone" : "_void_"

    # Security Zones Names
    single_compartment_sz_recipe_name      = var.single_compartment_id != null ? "${data.oci_identity_compartment.single_compartment[0].name}-security-zone-recipe" : "_void_"
    enclosing_compartment_sz_recipe_name   = var.enclosing_compartment_id != null ? "${data.oci_identity_compartment.enclosing_compartment[0].name}-security-zone-recipe" : "_void_"
    appdev_compartment_sz_recipe_name      = var.appdev_compartment_id != null ? "${data.oci_identity_compartment.appdev_compartment[0].name}-security-zone-recipe" : "_void_"
    database_compartment_sz_recipe_name    = var.database_compartment_id != null ? "${data.oci_identity_compartment.database_compartment[0].name}-security-zone-recipe" : "_void_"
    network_compartment_sz_recipe_name     = var.network_compartment_id != null ? "${data.oci_identity_compartment.network_compartment[0].name}-security-zone-recipe" : "_void_"
    security_compartment_sz_recipe_name    = var.security_compartment_id != null ? "${data.oci_identity_compartment.security_compartment[0].name}-security-zone-recipe" : "_void_"
    exadata_compartment_sz_recipe_name     = var.exadata_compartment_id != null ? "${data.oci_identity_compartment.exadata_compartment[0].name}-security-zone-recipe" : "_void_"

    # Secuirty Zone recipes aligned to CIS 1.2 Level 2
    cis_1_2_L2 = [
        "ocid1.securityzonessecuritypolicy.oc1..aaaaaaaa5ocyo7jqjzgjenvccch46buhpaaofplzxlp3xbxfcdwwk2tyrwqa",
        "ocid1.securityzonessecuritypolicy.oc1..aaaaaaaauoi2xnbusvfd4yffdjaaazk64gndp4flumaw3r7vedwndqd6vmrq"
      ]
    # Secuirty Zone recipes aligned to CIS 1.2 Level 1
    cis_1_2_L1 = [
        "ocid1.securityzonessecuritypolicy.oc1..aaaaaaaa7pgtjyod3pze6wuylgmts6ensywmeplabsxqq2bk4ighps4fqq4a", 
        "ocid1.securityzonessecuritypolicy.oc1..aaaaaaaaxxs63ulmtcnxqmcvy6eaozh5jdtiaa2bk7wll5bbdsbnmmoczp5a",
        "ocid1.securityzonessecuritypolicy.oc1..aaaaaaaaqmq4jqcxqbjj5cjzb7t5ira66dctyypq2m2o4psxmx6atp45lyda",
        "ocid1.securityzonessecuritypolicy.oc1..aaaaaaaaff6n52aojbgdg46jpm3kn7nizmh6iwvr7myez7svtfxsfs7irigq",
    ]

  
  landing_zone_security_policies = coalesce(var.cis_level,"1") == "2" ? setunion(local.cis_1_2_L2,local.cis_1_2_L1,coalesce(var.security_policies,[])) : setunion(local.cis_1_2_L1,coalesce(var.security_policies,[]))

  single_compartment_security_zone = var.single_compartment_id != null ? {"${local.single_compartment_sz_key}" = { 
    sz_display_name       = "${local.single_compartment_sz_name}"
    recipe_display_name   = "${local.single_compartment_sz_recipe_name}"
    compartment_id        = var.single_compartment_id
    description           = var.description
    security_policies     = local.landing_zone_security_policies
    defined_tags          = var.defined_tags
    freeform_tags         = var.freeform_tags
  }} : {}

  enclosing_compartment_security_zone = var.enclosing_compartment_id != null ? {"${local.enclosing_compartment_sz_key}" = { 
    sz_display_name       = "${local.enclosing_compartment_sz_name}"
    recipe_display_name   = "${local.enclosing_compartment_sz_recipe_name}"
    compartment_id        = var.enclosing_compartment_id
    description           = var.description
    security_policies     = local.landing_zone_security_policies
    defined_tags          = var.defined_tags
    freeform_tags         = var.freeform_tags
  }} : {}

  appdev_compartment_security_zone = var.appdev_compartment_id != null ? {"${local.appdev_compartment_sz_key}" = { 
    sz_display_name       = "${local.appdev_compartment_sz_name}"
    recipe_display_name   = "${local.appdev_compartment_sz_recipe_name}"
    compartment_id        = var.appdev_compartment_id
    description           = var.description
    security_policies     = local.landing_zone_security_policies
    defined_tags          = var.defined_tags
    freeform_tags         = var.freeform_tags
  }} : {}

  database_compartment_security_zone = var.database_compartment_id != null? {"${local.database_compartment_sz_key}" = { 
    sz_display_name       = "${local.database_compartment_sz_name}"
    recipe_display_name   = "${local.database_compartment_sz_recipe_name}"
    compartment_id        = var.database_compartment_id
    description           = var.description
    security_policies     = local.landing_zone_security_policies
    defined_tags          = var.defined_tags
    freeform_tags         = var.freeform_tags
  }} : {}

  network_compartment_security_zone = var.network_compartment_id != null ? {"${local.network_compartment_sz_key}" = { 
    sz_display_name       = "${local.network_compartment_sz_name}"
    recipe_display_name   = "${local.network_compartment_sz_recipe_name}"
    compartment_id        = var.network_compartment_id
    description           = var.description
    security_policies     = local.landing_zone_security_policies
    defined_tags          = var.defined_tags
    freeform_tags         = var.freeform_tags
  }} : {}

  security_compartment_security_zone = var.security_compartment_id != null ? {"${local.security_compartment_sz_key}" = { 
    sz_display_name       = "${local.security_compartment_sz_name}"
    recipe_display_name   = "${local.security_compartment_sz_recipe_name}"
    compartment_id        = var.security_compartment_id
    description           = var.description
    security_policies     = local.landing_zone_security_policies
    defined_tags          = var.defined_tags
    freeform_tags         = var.freeform_tags
  }} : {}

  exadata_compartment_security_zone = var.exadata_compartment_id != null ? {"${local.exadata_compartment_sz_key}" = { 
    sz_display_name       = "${local.exadata_compartment_sz_name}"
    recipe_display_name   = "${local.exadata_compartment_sz_recipe_name}"
    compartment_id        = var.exadata_compartment_id
    description           = var.description
    security_policies     = local.landing_zone_security_policies
    defined_tags          = var.defined_tags
    freeform_tags         = var.freeform_tags
  }} : {}

  landing_zone_compartment_security_zones = merge(local.appdev_compartment_security_zone,local.database_compartment_security_zone, local.network_compartment_security_zone, local.security_compartment_security_zone, local.exadata_compartment_security_zone)

  security_zones = var.single_compartment_id != null ? local.single_compartment_security_zone : (var.enclosing_compartment_id != null ? local.enclosing_compartment_security_zone : local.landing_zone_compartment_security_zones)

}

resource "oci_cloud_guard_security_recipe" "these" {
  for_each = local.security_zones
      compartment_id    = each.value.compartment_id
      display_name      = "${each.value.recipe_display_name}"
      description       = "${replace(each.value.recipe_display_name, "-", " ")} recipes. ${each.value.description}"
      security_policies = each.value.security_policies
      defined_tags      = each.value.defined_tags
      freeform_tags     = each.value.freeform_tags
}

resource "oci_cloud_guard_security_zone" "these" {
  for_each = local.security_zones
      compartment_id          = each.value.compartment_id
      display_name            = each.value.sz_display_name
      description             = "${replace(each.value.sz_display_name, "-", " ")}. ${each.value.description}"
      security_zone_recipe_id = oci_cloud_guard_security_recipe.these[each.key].id
      defined_tags            = each.value.defined_tags
      freeform_tags           = each.value.freeform_tags
}