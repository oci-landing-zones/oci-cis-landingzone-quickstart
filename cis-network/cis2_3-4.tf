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
          src           = var.public_subnet_cidr
          src_type      = "CIDR_BLOCK"
          src_port      = null
          dst_port      = {
            min = 21
            max = 23
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
          dst           = "10.1.2.3/32"
          dst_type      = "CIDR_BLOCK"
          src_port      = null
          dst_port      = {
            min = 21
            max = 23
          }
          icmp_code     = null
          icmp_type     = null
        }
      ]
    }
  }   
}