# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "private_key_password" {}
variable "region" {}
variable "region_key" {}
variable "vcn_cidr" {}
variable "public_subnet_cidr" {}
variable "private_subnet_app_cidr" {}
variable "private_subnet_db_cidr" {}
variable "public_src_bastion_cidr" {}
variable "public_src_lbr_cidr" {}
variable "service_label" {}