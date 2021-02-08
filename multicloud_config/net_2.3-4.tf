# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration creates four NSGs (Network Security Groups)
### 1) NSG for bastion servers:
###   Ingress rule: port 22 from sources other than 0.0.0.0/0
###   Egress rules: a) port 22 on NSG #3 (App NSG), b) port 22 on NSG #4 (DB NSG)
### 2) NSG for load balancers:
###   Ingress rule: port 443 from any sources
###   Egress rule: port 80 on NSG #3 (App NSG)
### 3) NSG for application hosts
###   Ingress rules: a) port 22 from NSG #1 (Bastion NSG), b) port 80 from NSG #2 (LBR NSG)
###   Egress rules: a) port 443 on region's Object Store service, b) port 1521 on NSG #4 (DB NSG)
### 4) NSG for database hosts:
###   Ingress rules: port 22 from the NSG #1 (Bastion NSG), b) port 1521 from NSG #2 (App NSG)
###   Egress rule: port 443 on region's Object Store service.

module "cis_nsgs" {
  source                 = "../modules/network/security"
  default_compartment_id = module.cis_compartments.compartments[local.network_compartment_name].id
  vcn_id                 = module.cis_vcn.vcn_id

  nsgs = {
    (local.bastion_nsg_name) = { # Bastion NSG
      compartment_id = null
      defined_tags   = null
      freeform_tags  = null
      ingress_rules = [
        {
          description = "SSH ingress rule for ${var.public_src_bastion_cidr}."
          stateless   = false
          protocol    = "6"
          src         = var.public_src_bastion_cidr
          src_type    = "CIDR_BLOCK"
          src_port    = null
          dst_port = {
            min = 22
            max = 22
          }
          icmp_code = null
          icmp_type = null
        },
        { # Bastion NSG from on-prem CIDR for SSH
          is_create   = tobool(var.is_vcn_onprem_connected)
          description = "SSH ingress rule for ${var.onprem_cidr}."
          stateless   = false
          protocol    = "6"
          src         = var.onprem_cidr
          src_type    = "CIDR_BLOCK"
          src_port    = null
          dst_port = {
            min = 22
            max = 22
          }
          icmp_code = null
          icmp_type = null
        }
      ]
      egress_rules = [
        {
          description = "SSH egress rule for ${local.app_nsg_name}."
          stateless   = false
          protocol    = "6"
          dst         = local.app_nsg_name
          dst_type    = "NSG_NAME"
          src_port    = null
          dst_port = {
            min = 22
            max = 22
          }
          icmp_code = null
          icmp_type = null
        },
        {
          description = "SSH egress rule for ${local.db_nsg_name}."
          stateless   = false
          protocol    = "6"
          dst         = local.db_nsg_name
          dst_type    = "NSG_NAME"
          src_port    = null
          dst_port = {
            min = 22
            max = 22
          }
          icmp_code = null
          icmp_type = null
        }
      ]
    },
    (local.lbr_nsg_name) = { # LBR NSG
      compartment_id = null
      defined_tags   = null
      freeform_tags  = null
      ingress_rules = [
        { # LBR NSG from external CIDR for HTTPS
          is_create   = true
          description = "HTTPS ingress rule for ${var.public_src_lbr_cidr}."
          stateless   = false
          protocol    = "6"
          src         = var.public_src_lbr_cidr
          src_type    = "CIDR_BLOCK"
          src_port    = null
          dst_port = {
            min = 443
            max = 443
          }
          icmp_code = null
          icmp_type = null
        },
        { # LBR NSG from on-prem CIDR for HTTPS
          is_create   = tobool(var.is_vcn_onprem_connected)
          description = "HTTPS ingress rule for ${var.onprem_cidr}."
          stateless   = false
          protocol    = "6"
          src         = var.onprem_cidr
          src_type    = "CIDR_BLOCK"
          src_port    = null
          dst_port = {
            min = 443
            max = 443
          }
          icmp_code = null
          icmp_type = null
        }
      ]
      egress_rules = [
        {
          description = "HTTP egress rule for ${local.app_nsg_name}."
          stateless   = false
          protocol    = "6"
          dst         = local.app_nsg_name
          dst_type    = "NSG_NAME"
          src_port    = null
          dst_port = {
            min = 80
            max = 80
          }
          icmp_code = null
          icmp_type = null
        }
      ]
    }
    (local.app_nsg_name) = { # App NSG
      compartment_id = null
      defined_tags   = null
      freeform_tags  = null
      ingress_rules = [
        {
          description = "SSH ingress rule for ${local.bastion_nsg_name}."
          stateless   = false
          protocol    = "6"
          src         = local.bastion_nsg_name
          src_type    = "NSG_NAME"
          src_port    = null
          dst_port = {
            min = 22
            max = 22
          }
          icmp_code = null
          icmp_type = null
        },
        {
          description = "HTTP ingress rule for ${local.lbr_nsg_name}."
          stateless   = false
          protocol    = "6"
          src         = local.lbr_nsg_name
          src_type    = "NSG_NAME"
          src_port    = null
          dst_port = {
            min = 80
            max = 80
          }
          icmp_code = null
          icmp_type = null
        }
      ]
      egress_rules = [
        {
          description = "DB egress rule for ${local.db_nsg_name}."
          stateless   = false
          protocol    = "6"
          dst         = local.db_nsg_name
          dst_type    = "NSG_NAME"
          src_port    = null
          dst_port = {
            min = 1521
            max = 1521
          }
          icmp_code = null
          icmp_type = null
        },
        {
          description = "OSN egress rule for ${local.valid_service_gateway_cidrs[0]}."
          stateless   = false
          protocol    = "6"
          dst         = local.valid_service_gateway_cidrs[0]
          dst_type    = "SERVICE_CIDR_BLOCK"
          src_port    = null
          dst_port = {
            min = 443
            max = 443
          }
          icmp_code = null
          icmp_type = null
        }
      ]
    },
    (local.db_nsg_name) = { # DB NSG
      compartment_id = null
      defined_tags   = null
      freeform_tags  = null
      ingress_rules = [
        {
          description = "SSH ingress rule for ${local.bastion_nsg_name}."
          stateless   = false
          protocol    = "6"
          src         = local.bastion_nsg_name
          src_type    = "NSG_NAME"
          src_port    = null
          dst_port = {
            min = 22
            max = 22
          }
          icmp_code = null
          icmp_type = null
        },
        {
          description = "DB ingress rule for ${local.app_nsg_name}."
          stateless   = false
          protocol    = "6"
          src         = local.app_nsg_name
          src_type    = "NSG_NAME"
          src_port    = null
          dst_port = {
            min = 1521
            max = 1522
          }
          icmp_code = null
          icmp_type = null
        }
      ]
      egress_rules = [
        { # DB NSG to OSN
          is_create   = true
          description = "OSN egress rule for ${local.valid_service_gateway_cidrs[0]}."
          stateless   = false
          protocol    = "6"
          dst         = local.valid_service_gateway_cidrs[0]
          dst_type    = "SERVICE_CIDR_BLOCK"
          src_port    = null
          dst_port = {
            min = 443
            max = 443
          }
          icmp_code = null
          icmp_type = null
        }
      ]
    }
  }
}