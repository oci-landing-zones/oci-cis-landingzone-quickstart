variable "compartment_id" {
  description = "Compartment's OCID where VCN will be created."
}

variable "vcn_display_name" {
  description = "Name of Virtual Cloud Network."
}

variable "vcn_cidr" {
  description = "A VCN covers a single, contiguous IPv4 CIDR block of your choice."
  default     = "10.0.0.0/16"
}

variable "vcn_dns_label" {
  description = "A DNS label for the VCN, used in conjunction with the VNIC's hostname and subnet's DNS label to form a fully qualified domain name (FQDN) for each VNIC within this subnet."
  default     = "vcn"
}

variable "subnet_dns_label" {
  description = "A DNS label prefix for the subnet, used in conjunction with the VNIC's hostname and VCN's DNS label to form a fully qualified domain name (FQDN) for each VNIC within this subnet."
  default     = "subnet"
}

variable "service_label" {
  description = "A service label to be used as part of resource names."
  default     = "cis"
}

variable "block_nat_traffic" {
  description = "Whether or not to block traffic through NAT gateway."
  default     = false
  type        = bool
}

variable "service_gateway_cidr" {
  description = "The OSN service cidr accessible through Service Gateway"
  default     = ""
  type        = string
}


variable "subnets" {
  description         = "Parameters for each subnet to be managed."
  type                = map(object({
    compartment_id    = string,
    defined_tags      = map(string),
    freeform_tags     = map(string),
    dynamic_cidr      = bool,
    cidr              = string,
    cidr_len          = number,
    cidr_num          = number,
    enable_dns        = bool,
    dns_label         = string,
    private           = bool,
    ad                = number,
    dhcp_options_id   = string,
    route_table_id    = string,
    security_list_ids = list(string)
  }))  
}

variable "route_tables" {
  description = "Parameters for each route table to be managed."
  type = map(object({
    compartment_id = string
    route_rules = list(object({
      destination = string,
      destination_type = string,
      network_entity_id = string
    }))
  }))
}