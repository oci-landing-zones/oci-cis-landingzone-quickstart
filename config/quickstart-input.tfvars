# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

tenancy_ocid         = "<tenancy_ocid>"
user_ocid            = "<tenancy_admin_ocid>"
fingerprint          = "<tenancy_admin_api_key_fingerprint>"
private_key_path     = "<path_to_tenancy_admin_private_key_file>"
private_key_password = ""
region               = "<home_region>"
region_key           = "<3-letter-region-key>"
service_label        = "<a_label_to_prefix_resource_names_with>"

### For Networking
is_vcn_onprem_connected       = <false_or_true>
onprem_cidr                   = "<onprem_cidr_block_range>"
public_src_bastion_cidr       ="<external_cidr_block_range_allowed_to_connect_to_bastion_servers>"

### For Security
network_admin_email_endpoint  ="<email_to_receive_network_related_notifications>"
security_admin_email_endpoint ="<email_to_receive_security_related_notifications>"
