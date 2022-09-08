provider "oci" {
  auth   = "InstancePrincipal"
  region = "${var.region}"
}

provider "oci" {
  alias  = "home"
  region = local.regions_map[local.home_region_key]
}
