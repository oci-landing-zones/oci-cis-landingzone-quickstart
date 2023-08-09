# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

##### The uncommented variable assignments below are for REQUIRED variables that do NOT have a default value in variables.tf. They must be provided appropriate values.
##### The commented variable assignments are for variables with a default value in variables.tf. For overriding them, uncomment the variable and provide an appropriate value.

# ------------------------------------------------------
# ----- Terraform Environment
# ------------------------------------------------------
tenancy_ocid         = "<tenancy_ocid>"
user_ocid            = "<user_ocid>"
fingerprint          = "<user_api_key_fingerprint>"
private_key_path     = "<path_to_user_private_key_file>"
private_key_password = ""
region               = "<tenancy_region>"

# ------------------------------------------------------
# ----- Workload Variables
# ------------------------------------------------------
service_label                          = "<a_label_to_prefix_resource_names_with>"
existing_lz_enclosing_compartment_ocid = "<OCID_of_CIS_LZ_enclosing_compartment>"
existing_lz_security_compartment_ocid  = "<OCID_of_CIS_LZ_security_compartment>"
existing_lz_network_compartment_ocid   = "<OCID_of_CIS_LZ_network_compartment>"
existing_lz_appdev_compartment_ocid    = "<OCID_of_CIS_LZ_appdev_compartment>"
workload_names                         = ["<workload_name_1", "workload_name_2"]
# create_workload_groups_and_policies    = false
# create_workload_dynamic_groups_and_policies = false