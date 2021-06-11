locals {
  subnet_names = ["web", "app", "db"]
  vcn_names = { for v in var.spoke_vcn_cidrs : "spoke${index(var.spoke_vcn_cidrs, v)}" => {
    name : "${var.service_label}-spoke${index(var.spoke_vcn_cidrs, v)}-vcn",
    cidr : v
    }
  }

  vcns = { for key, vcn in local.vcn_names : vcn.name => {
    compartment_id    = module.cis_compartments.compartments[local.network_compartment_name].id
    cidr              = vcn.cidr
    dns_label         = key
    is_create_igw     = false
    is_attach_drg     = true
    block_nat_traffic = false
    defined_tags      = null
    subnets = { for s in local.subnet_names : "${vcn.name}-${s}-subnet" => {
      compartment_id  = null
      defined_tags    = null
      cidr            = cidrsubnet(vcn.cidr, 4, index(local.subnet_names, s))
      dns_label       =  s
      private         = false
      dhcp_options_id = null
      }
    }

    }
  }
  vcn_ids = module.lz_spoke_vcns.vcns
  subnets = module.lz_spoke_vcns.subnets
  route_tables = { for key, subnet in local.subnets : replace(key,"subnet","route-table") => {
    compartment_id = subnet.compartment_id
    vcn_id         = subnet.vcn_id
    subnet_id      = subnet.id
    defined_tags   = null
    route_rules = [{
      is_create         = true
      destination       = "0.0.0.0/0"
      destination_type  = "CIDR_BLOCK"
      network_entity_id = module.lz_spoke_vcns.drg.id
      description       = "I wrote"
    },
    {
        is_create         = true
        destination       = local.valid_service_gateway_cidrs[0]
        destination_type  = "SERVICE_CIDR_BLOCK"
        network_entity_id = module.lz_spoke_vcns.service_gateways[subnet.vcn_id].id
        description       = "I wrote"
    }]
    }
  }
}

module "lz_spoke_vcns" {
  source               = "../modules/network/vcn-basic"
  compartment_id       = module.cis_compartments.compartments[local.network_compartment_name].id
  service_label        = var.service_label
  service_gateway_cidr = local.valid_service_gateway_cidrs[0]
  is_create_drg        = true
  vcns                 = local.vcns

}


module lz_route_tables {
    source             = "../modules/network/vcn-routing"
    compartment_id     = module.cis_compartments.compartments[local.network_compartment_name].id
    subnets_route_tables = local.route_tables
}
#   subnets_route_tables = {
#     ("${var.service_label}-spoke-${count.index}-route-table") = {
#       compartment_id = null
#       route_rules = [{
#         is_create         = true
#         destination       = local.valid_service_gateway_cidrs[0]
#         destination_type  = "SERVICE_CIDR_BLOCK"
#         network_entity_id = module.cis_spoke2_vcn[0].service_gateway.id
#         },
#         {
#           is_create         = true
#           destination       = local.anywhere
#           destination_type  = "CIDR_BLOCK"
#           network_entity_id = module.cis_vcn.drg != null ? module.cis_vcn.drg.id : null
#         }
#       ]
#     }
#   }




#   subnets = {for s in range(var.dmz_number_of_subnets) : "${var.service_label}-spoke-${index(var.spoke_vcn_cidrs,v)}-web-subnet" => {
#     compartment_id = null
#     defined_tags = null
#     cidr              = cidrsubnet(var.dmz_vcn_cidr,var.dmz_subnet_size,s)
#     dns_label         = null
#     private           = local.dmz_subnet_names[s] == "outdoor" && !var.no_internet_access ? false : true
#     ad                = null
#     dhcp_options_id   = null
#   } 
#   }
# }



# module "cis_spoke2_vcn" {
#   # depends_on           = [module.cis_dmz_vcn]
#   count                = length(var.spoke_vcn_cidrs) # var.hub_spoke_architecture == true ? 1 : 0
#   source               = "../modules/network/vcn-basic"
#   compartment_id       = module.cis_compartments.compartments[local.network_compartment_name].id
#   vcn_display_name     = "${var.service_label}-spoke-${count.index}-vcn"
#   vcn_cidr             = var.spoke_vcn_cidrs[count.index]
#   vcn_dns_label        = "spoke${count.index}"
#   service_label        = var.service_label
#   service_gateway_cidr = local.valid_service_gateway_cidrs[0]
# #  drg_id               = module.cis_vcn.drg.id
#   is_create_drg        = false
#   is_create_igw        = false
#   is_hub_spoke         = var.hub_spoke_architecture
#   subnets = {
#     ("${var.service_label}-spoke-${count.index}-web-subnet") = {
#       compartment_id    = null
#       defined_tags      = null
#       freeform_tags     = null
#       dynamic_cidr      = false
#       cidr              = cidrsubnet(var.spoke_vcn_cidrs[count.index],4,0)
#       cidr_len          = null
#       cidr_num          = null
#       enable_dns        = true
#       dns_label         = null # "spoke-${count.index}web"
#       private           = true
#       ad                = null
#       dhcp_options_id   = null
#       route_table_id    = module.cis_spoke2_vcn[count.index].subnets_route_tables["${var.service_label}-spoke-${count.index}-route-table"].id
#       # security_list_ids = [module.cis_spoke2_security_lists[count.index].security_lists["${var.service_label}-spoke${count.index}-security-list"].id]
#       security_list_ids = null
#     },
#     ("${var.service_label}-spoke-${count.index}-app-subnet") = {
#       compartment_id    = null
#       defined_tags      = null
#       freeform_tags     = null
#       dynamic_cidr      = false
#       cidr              = cidrsubnet(var.spoke_vcn_cidrs[count.index],4,0)
#       cidr_len          = null
#       cidr_num          = null
#       enable_dns        = true
#       dns_label         = null # "spoke-${count.index}app"
#       private           = true
#       ad                = null
#       dhcp_options_id   = null
#       route_table_id    = module.cis_spoke2_vcn[0].subnets_route_tables["${var.service_label}-spoke-${count.index}-route-table"].id
#       #security_list_ids = [module.cis_spoke2_security_lists[count.index].security_lists["${var.service_label}-spoke${count.index}-security-list"].id]
#       security_list_ids = null
#     },
#     ("${var.service_label}-spoke-${count.index}-db-subnet") = {
#       compartment_id    = null
#       defined_tags      = null
#       freeform_tags     = null
#       dynamic_cidr      = false
#       cidr              = cidrsubnet(var.spoke_vcn_cidrs[count.index],4,0)
#       cidr_len          = null
#       cidr_num          = null
#       enable_dns        = true
#       dns_label         = null # "spoke-${count.index}db"
#       private           = true
#       ad                = null
#       dhcp_options_id   = null
#       route_table_id    = module.cis_spoke2_vcn[0].subnets_route_tables["${var.service_label}-spoke-${count.index}-route-table"].id
#       security_list_ids = [module.cis_spoke2_security_lists[0].security_lists["${var.service_label}-spoke${count.index}-security-list"].id]
#       security_list_ids = null
#     }
#   }

#   subnets_route_tables = {
#     ("${var.service_label}-spoke-${count.index}-route-table") = {
#       compartment_id = null
#       route_rules = [{
#         is_create         = true
#         destination       = local.valid_service_gateway_cidrs[0]
#         destination_type  = "SERVICE_CIDR_BLOCK"
#         network_entity_id = module.cis_spoke2_vcn[0].service_gateway.id
#         },
#         {
#           is_create         = true
#           destination       = local.anywhere
#           destination_type  = "CIDR_BLOCK"
#           network_entity_id = module.cis_vcn.drg != null ? module.cis_vcn.drg.id : null
#         }
#       ]
#     }
#   }
# }

