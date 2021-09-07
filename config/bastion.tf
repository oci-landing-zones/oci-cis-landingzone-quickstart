# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "lz_app_bastion" {
    source = "../modules/security/bastion"
    count = (var.bastion_create == true && var.is_vcn_onprem_connected  == false && var.hub_spoke_architecture == false) ? 1 : 0
    bastion = {
        name = local.bastion_name
        compartment_id = module.lz_compartments.compartments[local.appdev_compartment_name].id
        target_subnet_id = module.lz_vcn_spokes.subnets[replace("${keys(module.lz_vcn_spokes.vcns)[0]}-${local.spoke_subnet_names[1]}-subnet", "-vcn", "")].id
        client_cidr_block_allow_list = var.public_src_bastion_cidrs
        max_session_ttl_in_seconds = local.bastion_max_session_ttl_in_seconds
    }
}

module "lz_app_bastion_sec_list" {
    depends_on     = [module.lz_vcn_spokes]
    source         = "../modules/network/security"
    count = (var.bastion_create == true && var.is_vcn_onprem_connected  == false && var.hub_spoke_architecture == false) ? 1 : 0
    compartment_id = module.lz_compartments.compartments[local.network_compartment_name].id
    security_lists = {
        ("${var.service_label}-0-bastion_security_list") = {
            vcn_id = module.lz_vcn_spokes.vcns[keys(module.lz_vcn_spokes.vcns)[0]].id,
            compartment_id = module.lz_compartments.compartments[local.network_compartment_name].id,
            defined_tags    = null,
            ingress_rules = [],
            egress_rules = [{
                stateless = true,
                protocol = "6",
                dst = module.lz_vcn_spokes.subnets[replace("${keys(module.lz_vcn_spokes.vcns)[0]}-${local.spoke_subnet_names[1]}-subnet", "-vcn", "")].cidr_block,
                dst_type = "CIDR_BLOCK",
                dst_port = {
                    min = 1521,
                    max = 1522
                },
                src_port = null
                icmp_type = null,
                icmp_code = null
            }]
        }
    }
}

data "oci_core_subnet" "lz_app_subnet" {
    depends_on     = [module.lz_vcn_spokes]
    subnet_id = module.lz_vcn_spokes.subnets[replace("${keys(module.lz_vcn_spokes.vcns)[0]}-${local.spoke_subnet_names[1]}-subnet", "-vcn", "")].id
}


resource "oci_core_subnet" "lz_app_subnet_update"{
    depends_on     = [module.lz_vcn_spokes, module.lz_app_bastion_sec_list]
    count = (var.bastion_create == true && var.is_vcn_onprem_connected  == false && var.hub_spoke_architecture == false) ? 1 : 0
    //cidr_block = module.lz_vcn_spokes.subnets[replace("${keys(module.lz_vcn_spokes.vcns)[0]}-${local.spoke_subnet_names[1]}-subnet", "-vcn", "")].cidr_block
    //compartment_id = module.lz_compartments.compartments[local.network_compartment_name].id
    //vcn_id = module.lz_vcn_spokes.vcns[keys(module.lz_vcn_spokes.vcns)[0]].id
    //display_name = replace("${keys(module.lz_vcn_spokes.vcns)[0]}-${local.spoke_subnet_names[1]}-subnet", "-vcn", "")
    cidr_block = data.oci_core_subnet.lz_app_subnet.cidr_block
    compartment_id = data.oci_core_subnet.lz_app_subnet.compartment_id
    vcn_id = data.oci_core_subnet.lz_app_subnet.vcn_id
    availability_domain = data.oci_core_subnet.lz_app_subnet.availability_domain
    defined_tags = data.oci_core_subnet.lz_app_subnet.defined_tags
    dhcp_options_id = data.oci_core_subnet.lz_app_subnet.dhcp_options_id
    display_name = data.oci_core_subnet.lz_app_subnet.display_name
    dns_label = data.oci_core_subnet.lz_app_subnet.dns_label
    //freeform_tags = data.oci_core_subnet.lz_app_subnet.freeform_tags
    //ipv6cidr_block = data.oci_core_subnet.lz_app_subnet.ipv6cidr_block
    prohibit_internet_ingress = data.oci_core_subnet.lz_app_subnet.prohibit_internet_ingress
    prohibit_public_ip_on_vnic = data.oci_core_subnet.lz_app_subnet.prohibit_public_ip_on_vnic
    route_table_id = data.oci_core_subnet.lz_app_subnet.route_table_id
    security_list_ids = concat(tolist(module.lz_vcn_spokes.subnets[replace("${keys(module.lz_vcn_spokes.vcns)[0]}-${local.spoke_subnet_names[1]}-subnet", "-vcn", "")].security_list_ids),
                        module.lz_app_bastion_sec_list[*].security_lists["${var.service_label}-0-bastion_security_list"].id)

}

