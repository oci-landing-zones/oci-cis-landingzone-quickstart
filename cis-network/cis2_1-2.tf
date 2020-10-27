module "cis_security_lists" {
  source                  = "../modules/network/security"
  default_compartment_id  = var.tenancy_ocid
  vcn_id                  = module.cis_vcn.vcn_id
  default_security_list_id = module.cis_vcn.default_security_list_id
  
  # If a public subnet is requested, we create security lists for the public and the private subnet. Otherwise, we create a security list for the private subnet only.
  #security_lists = tobool(var.create_public_subnet) ? {"${var.service_label}-Public-Subnet-Security-List" = local.public_security_list, "${var.service_label}-Private-Subnet-Security-List" = local.private_security_list} : {"${var.service_label}-Private-Subnet-Security-List" = local.private_security_list}

  security_lists = {
    "${var.service_label}-Public-Subnet-Security-List" = { 
      compartment_id  = null
      defined_tags    = null
      freeform_tags   = null
      ingress_rules   = [{
        stateless     = false
        protocol      = "6"
        src           = var.public_src_cidr
        src_type      = "CIDR_BLOCK"
        src_port      = null
        dst_port      = {
          min = 21
          max = 23
        }
        icmp_type     = null
        icmp_code     = null
      }]
      egress_rules    = [{
        stateless     = false
        protocol      = "6"
        dst           = var.private_subnet_cidr
        dst_type      = "CIDR_BLOCK"
        src_port      = null
        dst_port      = {
          min = 21
          max = 23
        }
        icmp_type     = null
        icmp_code     = null
      }]
    },
    "${var.service_label}-Private-Subnet-Security-List" = { 
      compartment_id  = null
      defined_tags    = null
      freeform_tags   = null
      ingress_rules   = [{
        stateless     = false
        protocol      = "6"
        src           = var.public_subnet_cidr
        src_type      = "CIDR_BLOCK"
        src_port      = null
        dst_port      = {
          min = 21
          max = 23
        }
        icmp_type     = null
        icmp_code     = null
      }]
      egress_rules    = null
    }
  }
}  