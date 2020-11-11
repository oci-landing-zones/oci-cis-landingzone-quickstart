# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# General
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "private_key_password" {}
variable "home_region" {}
variable "region" {}
variable "region_key" {}
variable "service_label" {}

# Networking
variable "vcn_cidr" {}
variable "public_subnet_cidr" {}
variable "private_subnet_app_cidr" {}
variable "private_subnet_db_cidr" {}
variable "public_src_bastion_cidr" {}
variable "public_src_lbr_cidr" {}

# Monitoring
variable "network_admin_email_endpoint" {}
variable "security_admin_email_endpoint" {}