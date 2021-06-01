# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

##### The uncommented variable assignments below are for REQUIRED variables that do NOT have a default value in variables.tf.
##### They must be provided appropriate values.

tenancy_ocid         = "<tenancy_ocid>"
user_ocid            = "<tenancy_admin_ocid>"
fingerprint          = "<tenancy_admin_api_key_fingerprint>"
private_key_path     = "<path_to_tenancy_admin_private_key_file>"
private_key_password = ""
region               = "<tenancy_region>"
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

##### Networking
# vcn_cidr                                        = "10.0.0.0/16" 
# public_subnet_cidr                              = "10.0.1.0/24" 
# private_subnet_app_cidr                         = "10.0.2.0/24" 
# private_subnet_db_cidr                          = "10.0.3.0/24" 
# public_src_lbr_cidr                             = "0.0.0.0/0" 

##### Cloud Guard
# cloud_guard_configuration_status                = "ENABLED"

##### Service Connector Hub
# create_service_connector_audit                  = false
# service_connector_audit_target                  = "objectstorage"
# service_connector_audit_state                   = "INACTIVE"
# service_connector_audit_target_OCID             = ""
# service_connector_audit_target_cmpt_OCID        = ""
# sch_audit_objStore_objNamePrefix                = "sch-audit"
# create_service_connector_vcnFlowLogs            = false
# service_connector_vcnFlowLogs_target            = "objectstorage"
# service_connector_vcnFlowLogs_state             = "INACTIVE"
# service_connector_vcnFlowLogs_target_OCID       = ""
# service_connector_vcnFlowLogs_target_cmpt_OCID  = ""
# sch_vcnFlowLogs_objStore_objNamePrefix          = "sch-vcnFlowLogs"





