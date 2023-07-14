# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "service_label" {
    value = local.display_outputs == true ? var.service_label : null
}

output "compartments" {
    value = local.display_outputs == true && var.extend_landing_zone_to_new_region == false ? merge({for k, v in module.lz_compartments.compartments : k => {name:v.name, id:v.id, parent_id:v.compartment_id, time_created:v.time_created}}, length(module.lz_top_compartment) > 0 ? {for k, v in module.lz_top_compartment[0].compartments : k => {name:v.name, id:v.id, parent_id:v.compartment_id, time_created:v.time_created}} : {}) : null
}

output "vcns" {
    value = local.display_outputs == true ? {for k, v in merge(module.lz_vcn_spokes.vcns, module.lz_exacs_vcns.vcns) : k => {id:v.id, cidr_block:v.cidr_block, dns_label:v.dns_label}} : null
}

output "subnets" {
    value = local.display_outputs == true ? {for k, v in merge(module.lz_vcn_spokes.subnets, module.lz_exacs_vcns.subnets) : k => {id:v.id, vcn_id:v.vcn_id, cidr_block:v.cidr_block, dns_label:v.dns_label, private:v.prohibit_public_ip_on_vnic}} : null
}

output "dmz_vcn" {
    value = local.display_outputs == true ? {for k, v in module.lz_vcn_dmz.vcns : k => {id:v.id, cidr_block:v.cidr_block, dns_label:v.dns_label}} : null
}

output "dmz_subnets" {
    value = local.display_outputs == true ? {for k, v in module.lz_vcn_dmz.subnets : k => {id:v.id, vcn_id:v.vcn_id, cidr_block:v.cidr_block, dns_label:v.dns_label, private:v.prohibit_public_ip_on_vnic}} : null
}

output "drg" {
    value = local.display_outputs == true ? (module.lz_drg.drg != null ? {id: module.lz_drg.drg.id, name: module.lz_drg.drg.display_name, parent_id:module.lz_drg.drg.compartment_id, time_created:module.lz_drg.drg.time_created} : null) : null
}

output "bastions" {
    value = local.display_outputs == true ? {for k, v in module.lz_app_bastion.bastions : k => {id: v.id, subnet_id: v.target_subnet_id, allowed_cidrs: v.client_cidr_block_allow_list}} : null
}

output "vss_recipes" {
    value = local.display_outputs == true ? (length(module.lz_scanning) > 0 ? {for k, v in module.lz_scanning[0].vss_recipes : k => {name: v.display_name, id: v.id, compartment_id: v.compartment_id}}: null) : null
}

output "vss_targets" {
    value = local.display_outputs == true ? (length(module.lz_scanning) > 0 ? {for k, v in module.lz_scanning[0].vss_targets : k => {name: v.display_name, id: v.id, compartment_id: v.compartment_id}}: null) : null
}

output "kms_vault" {
    value = local.display_outputs == true ? (length(module.lz_vault) > 0 ? {name: module.lz_vault[0].vault.display_name, id: module.lz_vault[0].vault.id, type: module.lz_vault[0].vault.vault_type, compartment_id: module.lz_vault[0].vault.compartment_id, management_endpoint: module.lz_vault[0].vault.management_endpoint, crypto_endpoint: module.lz_vault[0].vault.crypto_endpoint, state: module.lz_vault[0].vault.state} : null) : null
}

output "kms_keys" {
    value = local.display_outputs == true ? (length(module.lz_keys) > 0 ? {for k,v in module.lz_keys[0].keys : k => {name: v.display_name, id: v.id, compartment_id: v.compartment_id, key_shape: v.key_shape, management_endpoint: v.management_endpoint, state: v.state}} : null) : null
}

output "buckets" {
    value = local.display_outputs == true ? (length(module.lz_buckets) > 0 ? {for k, v in module.lz_buckets[0].buckets : k => {name: v.name, bucket_id: v.bucket_id, compartment_id: v.compartment_id, access_type: v.access_type, versioning: v.versioning, storage_tier: v.storage_tier}} : null) : null
}

output "cloud_guard_target" {
    value = local.display_outputs == true ? (length(module.lz_cloud_guard) > 0 ? {"display_name" : module.lz_cloud_guard[0].cloud_guard_target.display_name, "compartment_id" :  module.lz_cloud_guard[0].cloud_guard_target.compartment_id} : null) : null
}

output "service_connector_target" {
    value = local.display_outputs == true ? (length(module.lz_service_connector) > 0 ? module.lz_service_connector[0].service_connector_target : null) : null
}    

output "logging_analytics_log_group" {
    value = local.display_outputs == true ? (length(module.lz_logging_analytics) > 0 ? module.lz_logging_analytics[0].log_group : null) : null
}

output "cis_level" {
    value = local.display_outputs == true ? var.cis_level : null
}

output "region" {
    value = local.display_outputs == true ? var.region : null
}

output "release" {
    value = local.display_outputs == true ? (fileexists("${path.module}/../release.txt") ? file("${path.module}/../release.txt") : "unknown") : null
}
