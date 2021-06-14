# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

##### The uncommented variable assignments below are for REQUIRED variables that do NOT have a default value in variables.tf.

tenancy_ocid         = "<tenancy_ocid>"
user_ocid            = "<tenancy_admin_ocid>"
fingerprint          = "<tenancy_admin_api_key_fingerprint>"
private_key_path     = "<path_to_tenancy_admin_private_key_file>"
private_key_password = ""
home_region          = "<tenancy_home_region>"
unique_prefix        = "<a_label_to_prefix_resource_names_with>"

##### The commented variable assignments below are for variables with a default value in variables.tf.
##### For overriding the default values, uncomment the variable and provide an appropriate value.

#enclosing_compartment_names                 = ["<compartment1_name>","<compartment2_name>"] # max is 5.
#existing_enclosing_compartments_parent_ocid = "<existing_enclosing_compartments_parent_ocid>" # the code defaults to tenancy_ocid if nothing is informed.

#use_existing_lz_groups                 = false
/*
existing_iam_admin_group_name           = "<existing_iam_admin_group_name>"
existing_cred_admin_group_name          = "<existing_cred_admin_group_name>"
existing_security_admin_group_name      = "<existing_security_admin_group_name>"
existing_network_admin_group_name       = "<existing_network_admin_group_name>"
existing_appdev_admin_group_name        = "<existing_appdev_admin_group_name>"
existing_database_admin_group_name      = "<existing_database_admin_group_name>"
existing_auditor_group_name             = "<existing_auditor_group_name>"
existing_announcement_reader_group_name = "<existing_announcement_reader_group_name>"
*/