### This Terraform configuration provisions a VCN, an Internet Gateway, a NAT Gateway, a Service Gateway, three subnets and three route tables.
### Among the subnets, one is public and two are private (meant to host app and db hosts). Each subnet is attached a different route table, with distinct route rules.
### The route table attached to the public subnet has a rule for the Internet Gateway with 0.0.0.0/0 destination 
### The route table attached to the app private subnet has two rules: one for the NAT Gateway with 0.0.0.0/0 destination and one for the Service Gateway with region's Object Store destination 
### The route table attached to the db private subnet has a rule for the Service Gateway with region's Object Store destination

module "cis_vcn" {
  source               = "../modules/network/vcn"
  compartment_id       = data.terraform_remote_state.iam.outputs.network_compartment_id
  vcn_display_name     = local.vcn_display_name
  vcn_cidr             = var.vcn_cidr
  vcn_dns_label        = lower(format("%s", var.service_label))
  service_label        = var.service_label
  service_gateway_cidr = local.valid_service_gateway_cidrs[0]

  subnets = {
    (local.public_subnet_name) = {
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
      route_table_id    = module.cis_vcn.route_tables[local.public_subnet_route_table_name].id
      security_list_ids = [module.cis_security_lists.security_lists[local.public_subnet_security_list_name].id]
    }, 
    (local.private_subnet_app_name) = {
      compartment_id    = null
      defined_tags      = null
      freeform_tags     = null
      dynamic_cidr      = false
      cidr              = var.private_subnet_app_cidr
      cidr_len          = null
      cidr_num          = null
      enable_dns        = true
      dns_label         = "appsubnet"
      private           = true
      ad                = null
      dhcp_options_id   = null
      route_table_id    = module.cis_vcn.route_tables[local.private_subnet_app_route_table_name].id
      security_list_ids = [module.cis_security_lists.security_lists[local.private_subnet_app_security_list_name].id]
    },
    (local.private_subnet_db_name) = {
      compartment_id    = null
      defined_tags      = null
      freeform_tags     = null
      dynamic_cidr      = false
      cidr              = var.private_subnet_db_cidr
      cidr_len          = null
      cidr_num          = null
      enable_dns        = true
      dns_label         = "dbsubnet"
      private           = true
      ad                = null
      dhcp_options_id   = null
      route_table_id    = module.cis_vcn.route_tables[local.private_subnet_db_route_table_name].id
      security_list_ids = [module.cis_security_lists.security_lists[local.private_subnet_db_security_list_name].id]
    }
  }

  route_tables         = {
    (local.public_subnet_route_table_name) = {
      compartment_id = null
      route_rules = [{
          destination = local.anywhere
          destination_type = "CIDR_BLOCK"
          network_entity_id = module.cis_vcn.internet_gateway_id
        }
      ]
    },
    (local.private_subnet_app_route_table_name) = {
      compartment_id = null
      route_rules = [{
          destination = local.valid_service_gateway_cidrs[0]
          destination_type = "SERVICE_CIDR_BLOCK"
          network_entity_id = module.cis_vcn.service_gateway_id
        },
        {
          destination = local.anywhere
          destination_type = "CIDR_BLOCK"
          network_entity_id = module.cis_vcn.nat_gateway_id
        }
      ]
    },
    (local.private_subnet_db_route_table_name) = {
      compartment_id = null
      route_rules = [{
          destination = local.valid_service_gateway_cidrs[0]
          destination_type = "SERVICE_CIDR_BLOCK"
          network_entity_id = module.cis_vcn.service_gateway_id
        }
      ]  
    }
  }
}
/*
module "cis_subnets" {
  source                  = "../modules/network/subnets"
  default_compartment_id  = var.tenancy_ocid
  vcn_id                  = module.cis_vcn.vcn_id
  vcn_cidr                = var.vcn_cidr

  subnets = {
    (local.public_subnet_name) = {
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
      route_table_id    = module.cis_vcn.route_tables[local.public_subnet_route_table_name].id
      security_list_ids = [module.cis_security_lists.security_lists[local.public_subnet_security_list_name].id]
    }, 
    (local.private_subnet_app_name) = {
      compartment_id    = null
      defined_tags      = null
      freeform_tags     = null
      dynamic_cidr      = false
      cidr              = var.private_subnet_app_cidr
      cidr_len          = null
      cidr_num          = null
      enable_dns        = true
      dns_label         = "appsubnet"
      private           = true
      ad                = null
      dhcp_options_id   = null
      route_table_id    = module.cis_vcn.route_tables[local.private_subnet_app_route_table_name].id
      security_list_ids = [module.cis_security_lists.security_lists[local.private_subnet_app_security_list_name].id]
    },
    (local.private_subnet_db_name) = {
      compartment_id    = null
      defined_tags      = null
      freeform_tags     = null
      dynamic_cidr      = false
      cidr              = var.private_subnet_db_cidr
      cidr_len          = null
      cidr_num          = null
      enable_dns        = true
      dns_label         = "dbsubnet"
      private           = true
      ad                = null
      dhcp_options_id   = null
      route_table_id    = module.cis_vcn.route_tables[local.private_subnet_db_route_table_name].id
      security_list_ids = [module.cis_security_lists.security_lists[local.private_subnet_db_security_list_name].id]
    }
  } 
}
*/