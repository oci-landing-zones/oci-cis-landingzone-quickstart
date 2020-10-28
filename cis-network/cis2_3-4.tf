module "cis_nsgs" {
  source                  = "../modules/network/security"
  default_compartment_id  = var.tenancy_ocid
  vcn_id                  = module.cis_vcn.vcn_id
  
  nsgs                  = {
    "${var.service_label}-Network-Security-Group-1" = {
      compartment_id    = null
      defined_tags      = null
      freeform_tags     = null
      ingress_rules     = [
        {
          description   = "Ingress rules for network security group"
          stateless     = false
          protocol      = "6"
          src           = var.private_subnet_cidr
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
          description   = "Egress rules for network security group"
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