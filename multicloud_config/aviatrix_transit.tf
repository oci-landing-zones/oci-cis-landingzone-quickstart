resource "oci_core_network_security_group" "nsg" {
  compartment_id = module.cis_vcn.vcn.compartment_id
  vcn_id         = module.cis_vcn.vcn.id
  display_name = "aviatrix-transit-nsg"
}

resource "oci_core_network_security_group_security_rule" "rule_egress_all" {
  network_security_group_id = oci_core_network_security_group.nsg.id

  direction   = "EGRESS"
  protocol    = "all"
  destination = "0.0.0.0/0"
}

resource "oci_core_network_security_group_security_rule" "rule_ingress_tcp443" {
  network_security_group_id = oci_core_network_security_group.nsg.id
  protocol                  = "6"
  direction                 = "INGRESS"
  source                    = "0.0.0.0/0"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "rule_ingress_all_icmp_type3_code4" {
  network_security_group_id = oci_core_network_security_group.nsg.id
  protocol                  = 1
  direction                 = "INGRESS"
  source                    = "0.0.0.0/0"
  stateless                 = true

  icmp_options {
    type = 3
    code = 4
  }
}

resource "oci_core_network_security_group_security_rule" "rule_ingress_vcn_icmp_type3" {
  network_security_group_id = oci_core_network_security_group.nsg.id
  protocol                  = 1
  direction                 = "INGRESS"
  source                    = module.cis_vcn.vcn.cidr_block
  stateless                 = true

  icmp_options {
    type = 3
  }
}

#######

# Create an Aviatrix Oracle OCI Account
resource "aviatrix_account" "oci_account" {
  account_name                 = "CIS_OCI_Network2"
  cloud_type                   = 16
  oci_tenancy_id               = var.tenancy_ocid
  oci_user_id                  = var.user_ocid
  oci_compartment_id           = module.cis_vcn.vcn.compartment_id
  oci_api_private_key_filepath = var.private_key_path
}

# Aviatrix OCI Transit Module
module "aviatrix_oci_transit" {
 # count       = var.aviatrix_enabled ? 1 : 0
  source      = "../modules/aviatrix-oci-transit"
  region      = var.region
  account     = aviatrix_account.oci_account.account_name
  vcn_name    = module.cis_vcn.vcn.display_name 
  subnet_cidr = module.cis_vcn.subnet_objects["avx-Public-Subnet"].cidr_block
  #depends_on  = [module.network]
}