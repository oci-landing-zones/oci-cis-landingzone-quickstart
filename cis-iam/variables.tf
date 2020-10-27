variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "private_key_password" {}
variable "home_region" {}
variable "service_label" {}

/*
variable "service_identifier" {
  default = "myservice"
}
variable "app_tag" {
  default = "myapp"
}
*/
// Must be one of: prod, stage, dev, test
/*
variable "env" {
  default = "dev"
}
*/
/*
variable "compartment_create" {
  default = true
}
*/
/*
locals {
  env_map = {
    prod="PROD"
    stage="STAGE"
    dev="DEV"
    test="TEST"
  }

  env_enum = "${local.env_map[var.env]}"
}
*/
