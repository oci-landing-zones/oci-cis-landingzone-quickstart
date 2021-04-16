# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

##### The uncommented variable assignments below are for REQUIRED variables that do NOT have a default value in variables.tf.
##### They must be provided appropriate values.

tenancy_ocid         = "<tenancy_ocid>"
user_ocid            = "<tenancy_admin_ocid>"
fingerprint          = "<tenancy_admin_api_key_fingerprint>"
private_key_path     = "<path_to_tenancy_admin_private_key_file>"
private_key_password = ""
home_region          = "<tenancy_home_region>"
region               = "<tenancy_region>"
region_key           = "<3-letter-region-key>"
service_label        = "<a_label_to_prefix_resource_names_with>"

### For Networking
is_vcn_onprem_connected       = <false_or_true>
onprem_cidr                   = "<onprem_cidr_block_range>"
public_src_bastion_cidr       = "<external_cidr_block_range_allowed_to_connect_to_bastion_servers>"

### For Security
network_admin_email_endpoint  = "<email_to_receive_network_related_notifications>"
security_admin_email_endpoint = "<email_to_receive_security_related_notifications>"

##### The commented variable assignments below are for variables with a default value in variables.tf.
##### For overriding the default values, uncomment the variable and provide an appropriate value.

# vcn_cidr                                        = "10.0.0.0/16" 
# public_subnet_cidr                              = "10.0.1.0/24" 
# private_subnet_app_cidr                         = "10.0.2.0/24" 
# private_subnet_db_cidr                          = "10.0.3.0/24" 
# public_src_lbr_cidr                             = "0.0.0.0/0" 
# cloud_guard_configuration_status                = "ENABLED" 
# cloud_guard_configuration_self_manage_resources = false 
# vss_enabled                                     = true
# vss_scan_schedule                               = "WEEKLY"
# vss_scan_day                                    = "SUNDAY"



