locals {
  anywhere = "0.0.0.0/0"
  valid_service_gateway_cidrs = ["oci-${var.region_key}-objectstorage", "all-${var.region_key}-services-in-oracle-services-network"]
}