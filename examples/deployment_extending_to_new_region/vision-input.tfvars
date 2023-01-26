tenancy_ocid         = "ocid1.tenancy.oc1..aaa...ir7xdq"
user_ocid            = "ocid1.user.oc1..aaa...yfhyvq"
fingerprint          = "c1:91:41:...:36:76:54:39"
private_key_path     = "../private_key.pem"
private_key_password = ""

service_label = "vision"
region        = "us-phoenix-1"

use_enclosing_compartment = true
existing_enclosing_compartment_ocid = "ocid1.compartment.oc1..aaa...vves2a"

extend_landing_zone_to_new_region = true

vcn_cidrs = ["10.0.0.0/25"]
vcn_names = ["myvcn-dr"]
subnets_names = ["front","mid","back"]
subnets_sizes = ["4","3","3"]

exacs_vcn_cidrs           = ["10.2.0.0/20"]
exacs_vcn_names           = ["exavcn-dr"]
exacs_client_subnet_cidrs = ["10.2.0.0/24"]
exacs_backup_subnet_cidrs = ["10.2.1.0/28"]

network_admin_email_endpoints  = ["john.doe@myorg.com"]
security_admin_email_endpoints = ["john.doe@myorg.com"]
exainfra_admin_email_endpoints = ["john.doe@myorg.com"]
