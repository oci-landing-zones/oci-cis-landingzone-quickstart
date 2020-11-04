locals {
  anywhere = "0.0.0.0/0"
  valid_service_gateway_cidrs = ["oci-${var.region_key}-objectstorage", "all-${var.region_key}-services-in-oracle-services-network"]

  # VCN names
  vcn_display_name = "${var.service_label}-VCN"
  
  # Subnet names
  public_subnet_name      = "${var.service_label}-Public-Subnet"
  private_subnet_app_name = "${var.service_label}-Private-Subnet-App"
  private_subnet_db_name  = "${var.service_label}-Private-Subnet-DB"
  
  # Security lists names
  public_subnet_security_list_name      = "${local.public_subnet_name}-Security-List"
  private_subnet_app_security_list_name = "${local.private_subnet_app_name}-Security-List"
  private_subnet_db_security_list_name  = "${local.private_subnet_db_name}-Security-List"

  # Network security groups names
  bastion_nsg_name = "${var.service_label}-NSG-Bastion"
  lbr_nsg_name = "${var.service_label}-NSG-LBR"
  app_nsg_name = "${var.service_label}-NSG-App"
  db_nsg_name  = "${var.service_label}-NSG-DB"

  # Route tables names
  public_subnet_route_table_name      = "${local.public_subnet_name}-Route"
  private_subnet_app_route_table_name = "${local.private_subnet_app_name}-Route"
  private_subnet_db_route_table_name  = "${local.private_subnet_db_name}-Route"
}