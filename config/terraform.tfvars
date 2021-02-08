# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

##### The uncommented variable assignments below are for REQUIRED variables that do NOT have a default value in variables.tf.
##### They must be provided appropriate values.

#tenancy_ocid         = "<tenancy_ocid>"
#user_ocid            = "<tenancy_admin_ocid>"
#fingerprint          = "<tenancy_admin_api_key_fingerprint>"
#private_key_path     = "<path_to_tenancy_admin_private_key_file>"
private_key_password = ""
home_region          = "us-ashburn-1"
#region               = "<tenancy_region>"
region_key    = "iad"
service_label = "avx"

/*TF_VAR_fingerprint=39:3c:e8:11:10:6a:36:72:44:00:73:0e:3b:a3:7f:35
TF_VAR_user_ocid=ocid1.user.oc1..aaaaaaaahczj3lb3aekzhrzmseeogrlhzz4rpd467kzpwtzui5mkangr2tha
TF_VAR_tenancy_ocid=ocid1.tenancy.oc1..aaaaaaaa7avyc4vh6q4qb2rrqazbxx4l3t6u4dnir45kovtjgyy6c7g75xaq
TF_VAR_compartment_ocid=ocid1.tenancy.oc1..aaaaaaaa7avyc4vh6q4qb2rrqazbxx4l3t6u4dnir45kovtjgyy6c7g75xaq
TF_VAR_private_key_path=/Users/travis/.oci/sessions/TMAVX/oci_api_key.pem
TF_VAR_region=us-ashburn-1
*/

### For Networking
is_vcn_onprem_connected = false
#onprem_cidr             = "192.168.1.10"
#public_src_bastion_cidr = "35.0.0.0"

### For Security
network_admin_email_endpoint  = "tmitchell@aviatrix.com"
security_admin_email_endpoint = "tmitchell@aviatrix.com"

##### The commented variable assignments below are for variables with a default value in variables.tf.
##### For overriding the default values, uncomment the variable and provide an appropriate value.

# vcn_cidr                                        = "10.0.0.0/16" 
# public_subnet_cidr                              = "10.0.1.0/24" 
# private_subnet_app_cidr                         = "10.0.2.0/24" 
# private_subnet_db_cidr                          = "10.0.3.0/24" 
# public_src_lbr_cidr                             = "0.0.0.0/0" 
cloud_guard_configuration_status                = "DISABLED" 
cloud_guard_configuration_self_manage_resources = false 



