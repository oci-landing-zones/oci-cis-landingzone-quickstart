# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# General
variable "tenancy_ocid" {}
variable "user_ocid" {
    default = ""
}
variable "fingerprint" {
    default = ""
}
variable "private_key_path" {
    default = ""
}
variable "private_key_password" {
    default = ""
}

variable "home_region" {
    default = "us-ashburn-1"
}
variable "region" {
    default = "us-ashburn-1"
}
variable "region_key" {
    default = "iad"
}
variable "service_label" {
    default = "cis"
}

# Networking
variable "vcn_cidr" {
    default = "10.0.0.0/16"
}
variable "public_subnet_cidr" {
    default = "10.0.1.0/24"
}
variable "private_subnet_app_cidr" {
    default = "10.0.2.0/24"
}
variable "private_subnet_db_cidr" {
    default = "10.0.3.0/24"
}
variable "public_src_bastion_cidr" {
    default = "177.235.205.77/32"
}
variable "public_src_lbr_cidr" {
    default = "0.0.0.0/0"
}

# Monitoring
variable "network_admin_email_endpoint" {
    default = "andre.correa@oracle.com"
}
variable "security_admin_email_endpoint" {
    default = "andremo_br@yahoo.com"
}
variable "cloud_guard_configuration_status" {
  default = "ENABLED"
}
# Setting this variable to true lets the user seed the oracle managed entities with minimal changes to the original entities.
# False will delegate this responsibility to CloudGuard for seeding the oracle managed entities.
variable "cloud_guard_configuration_self_manage_resources" {
  default = false
}