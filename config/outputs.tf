output "service_label" {
    value = local.display_outputs == true ? var.service_label : null
}

output "compartments" {
    value = local.display_outputs == true ? {for k, v in module.lz_compartments.compartments : k => {name:v.name, id:v.id, parent_id:v.compartment_id, time_created:v.time_created}} : null
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