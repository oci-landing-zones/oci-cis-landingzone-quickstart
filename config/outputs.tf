output "service_label" {
    value = local.display_outputs == true ? var.service_label : null
}

output "compartments" {
    value = local.display_outputs == true && var.extend_landing_zone_to_new_region == false ? {for k, v in module.lz_compartments.compartments : k => {name:v.name, id:v.id, parent_id:v.compartment_id, time_created:v.time_created}} : null
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