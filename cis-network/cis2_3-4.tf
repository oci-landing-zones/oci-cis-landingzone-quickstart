### This Terraform configuration creates two NSGs (Network Security Groups)
### First NSG has one ingress and two egress rules:
###   Ingress rule: port 22 from the public subnet cidr.
###   Egress rules: a) port 22 on the second NSG, b) port 443 on region's Object Store service.
### Second NSG has one ingress and one egress rule:
###   Ingress rule: port 22 from the first NSG.
###   Egress rule: port 443 on region's Object Store service.

module "cis_nsgs" {
  source                  = "../modules/network/security"
  default_compartment_id  = data.terraform_remote_state.iam.outputs.network_compartment_id
  vcn_id                  = module.cis_vcn.vcn_id
  
  nsgs                  = {
    (local.app_nsg_name) = {
      compartment_id    = null
      defined_tags      = null
      freeform_tags     = null
      ingress_rules     = [
        {
          description   = "Ingress rule for ${local.app_nsg_name} network security group."
          stateless     = false
          protocol      = "6"
          src           = var.public_subnet_cidr
          src_type      = "CIDR_BLOCK"
          src_port      = null
          dst_port      = {
            min = 22
            max = 22
          }
          icmp_code     = null
          icmp_type     = null
        }
      ]
      egress_rules        = [
        {
          description   = "Egress rule for ${local.app_nsg_name} network security group."
          stateless     = false
          protocol      = "6"
          dst           = local.db_nsg_name
          dst_type      = "NSG_NAME"
          src_port      = null
          dst_port      = {
            min = 22
            max = 22
          }
          icmp_code     = null
          icmp_type     = null
        },
        {
          description     = "Egress rule for ${local.app_nsg_name} network security group."
          stateless     = false
          protocol      = "6"
          dst           = local.valid_service_gateway_cidrs[0]
          dst_type      = "SERVICE_CIDR_BLOCK"
          src_port      = null
          dst_port      = {
            min = 443
            max = 443
          }
          icmp_code     = null
          icmp_type     = null
        }
      ]
    },
    (local.db_nsg_name) = {
      compartment_id    = null
      defined_tags      = null
      freeform_tags     = null
      ingress_rules     = [
        {
          description   = "Ingress rule for ${local.db_nsg_name} network security group."
          stateless     = false
          protocol      = "6"
          src           = local.app_nsg_name
          src_type      = "NSG_NAME"
          src_port      = null
          dst_port      = {
            min = 22
            max = 22
          }
          icmp_code     = null
          icmp_type     = null
        }
      ]
      egress_rules        = [
        {
          description   = "Egress rule for ${local.db_nsg_name} network security group."
          stateless     = false
          protocol      = "6"
          dst           = local.valid_service_gateway_cidrs[0]
          dst_type      = "SERVICE_CIDR_BLOCK"
          src_port      = null
          dst_port      = {
            min = 443
            max = 443
          }
          icmp_code     = null
          icmp_type     = null
        }
      ]
    }
  }   
}