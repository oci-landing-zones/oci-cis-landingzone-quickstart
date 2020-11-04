provider "oci" {
  region               = var.region
  tenancy_ocid         = var.tenancy_ocid
  user_ocid            = var.user_ocid
  fingerprint          = var.fingerprint
  private_key_path     = var.private_key_path
  private_key_password = var.private_key_password
}

### This data source is used to read configuration from the cis-network configuration state.
### Specifically, this configuration provisions resources using resource references managed in cis-network configuration, like subnets.
data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "../cis-network/terraform.tfstate"
  }
}

### This data source is used to read configuration from the cis-iam configuration state.
### Specifically, this configuration provisions resources in compartments managed by the cis-iam configuration.
data "terraform_remote_state" "iam" {
  backend = "local"
  config = {
    path = "../cis-iam/terraform.tfstate"
  }
}