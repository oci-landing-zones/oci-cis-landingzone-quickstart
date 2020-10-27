locals {
    
  public_subnet = {
    compartment_id    = null
    defined_tags      = null
    freeform_tags     = null
    dynamic_cidr      = false
    cidr              = var.public_subnet_cidr
    cidr_len          = null
    cidr_num          = null
    enable_dns        = true
    dns_label         = "public"
    private           = false
    ad                = null
    dhcp_options_id   = null
    route_table_id    = module.cis_vcn.internet_route_table_id
    security_list_ids = [module.cis_security_lists.security_lists["${var.service_label}-Public-Subnet-Security-List"].id]
  }

  private_subnet = {
    compartment_id    = null
    defined_tags      = null
    freeform_tags     = null
    dynamic_cidr      = false
    cidr              = var.private_subnet_cidr
    cidr_len          = null
    cidr_num          = null
    enable_dns        = true
    dns_label         = "private"
    private           = true
    ad                = null
    dhcp_options_id   = null
    route_table_id    = null
    security_list_ids = [module.cis_security_lists.security_lists["${var.service_label}-Private-Subnet-Security-List"].id]
  }
}

module "cis_vcn" {
  source                = "../modules/network/vcn"
  compartment_ocid       = var.tenancy_ocid
  vcn_display_name       = "${var.service_label}-VCN"
  vcn_cidr               = var.vcn_cidr
  vcn_dns_label          = lower(format("%s", var.service_label))
  service_label          = var.service_label
  vcn_internet_connected = tobool(var.vcn_internet_connected)
}

module "cis_subnets" {
  source                  = "../modules/network/subnets"
  default_compartment_id  = var.tenancy_ocid
  vcn_id                  = module.cis_vcn.vcn_id
  vcn_cidr                = var.vcn_cidr

  # If a public subnet is requested, we create a public subnet and a private subnet. Otherwise, we create a private subnet only.
  subnets = tobool(var.create_public_subnet) ? {"${var.service_label}-Public-Subnet" = local.public_subnet, "${var.service_label}-Private-Subnet" = local.private_subnet} : {"${var.service_label}-Private-Subnet" = local.private_subnet}

}
