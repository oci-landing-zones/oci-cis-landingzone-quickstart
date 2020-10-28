module "cis_vcn" {
  source               = "../modules/network/vcn"
  compartment_id       = var.tenancy_ocid
  vcn_display_name     = "${var.service_label}-VCN"
  vcn_cidr             = var.vcn_cidr
  vcn_dns_label        = lower(format("%s", var.service_label))
  service_label        = var.service_label
  service_gateway_cidr = local.valid_service_gateway_cidrs[0]
}

module "cis_subnets" {
  source                  = "../modules/network/subnets"
  default_compartment_id  = var.tenancy_ocid
  vcn_id                  = module.cis_vcn.vcn_id
  vcn_cidr                = var.vcn_cidr

  subnets = {
    "${var.service_label}-Public-Subnet" = {
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
    }, 
    "${var.service_label}-Private-Subnet" = {
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
      route_table_id    = module.cis_vcn.private_route_table_id
      security_list_ids = [module.cis_security_lists.security_lists["${var.service_label}-Private-Subnet-Security-List"].id]
    }
  } 
}
