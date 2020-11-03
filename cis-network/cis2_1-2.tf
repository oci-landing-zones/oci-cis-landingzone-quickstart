### This Terraform configuration creates three security lists: 
### One security list to be attached to a public subnet.
###   Ingress rule: port 22 from any source other than 0.0.0.0/0.
###   Egress rule: port 22 on app private subnet cidr.
### Two initially empty security lists to be attached to private subnets. 
###   On these subnets, the security rules are driven by NSGs (Network Security Groups). See cis2_3-4.tf

module "cis_security_lists" {
  source                   = "../modules/network/security"
  default_compartment_id   = data.terraform_remote_state.iam.outputs.network_compartment_id
  vcn_id                   = module.cis_vcn.vcn_id
  default_security_list_id = module.cis_vcn.default_security_list_id
  
  security_lists = { 
    (local.public_subnet_security_list_name) = { 
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
          min = 22
          max = 22
        }
        icmp_type     = null
        icmp_code     = null
      }]
      egress_rules    = [{
        stateless     = false
        protocol      = "6"
        dst           = var.private_subnet_app_cidr
        dst_type      = "CIDR_BLOCK"
        src_port      = null
        dst_port      = {
          min = 22
          max = 22
        }
        icmp_type     = null
        icmp_code     = null
      }]
    },
    (local.private_subnet_app_security_list_name) = { 
      compartment_id  = null
      defined_tags    = null
      freeform_tags   = null
      ingress_rules   = null
      egress_rules    = null
    },
    (local.private_subnet_db_security_list_name) = { 
      compartment_id  = null
      defined_tags    = null
      freeform_tags   = null
      ingress_rules   = null
      egress_rules    = null
    }
  }
}  