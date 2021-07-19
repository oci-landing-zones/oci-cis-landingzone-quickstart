output "compartments" {
    value = local.display_outputs == true ? {for k, v in module.lz_compartments.compartments : k => {id:v.id, parent_id:v.compartment_id, time_created:v.time_created}} : null
}

output "vcns" {
    value = local.display_outputs == true ? {for k, v in module.lz_vcn_spokes.vcns : k => {id:v.id, cidr_block:v.cidr_block, dns_label:v.dns_label}} : null
}

output "dmz_vcn" {
    value = local.display_outputs == true ? {for k, v in module.lz_vcn_dmz.vcns : k => {id:v.id, cidr_block:v.cidr_block, dns_label:v.dns_label}} : null
}

output "dmz_subnets" {
    value = local.display_outputs == true ? {for k, v in module.lz_vcn_dmz.subnets : k => {id:v.id, cidr_block:v.cidr_block, dns_label:v.dns_label, private:v.prohibit_public_ip_on_vnic}} : null
}

output "drg" {
    value = local.display_outputs == true ? (module.lz_vcn_spokes.drg != null ? {id: module.lz_vcn_spokes.drg.id, name: module.lz_vcn_spokes.drg.display_name, parent_id:module.lz_vcn_spokes.drg.compartment_id, time_created:module.lz_vcn_spokes.drg.time_created} : null) : null
}

output "service_label" {
    value = local.display_outputs == true ? var.service_label : null
}