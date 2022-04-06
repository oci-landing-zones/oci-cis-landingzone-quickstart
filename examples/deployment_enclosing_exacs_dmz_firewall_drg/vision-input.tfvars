tenancy_ocid         = "ocid1.tenancy.oc1..aaa...ir7xdq"
user_ocid            = "ocid1.user.oc1..aaa...yfhyvq"
fingerprint          = "c1:91:41:...:36:76:54:39"
private_key_path     = "../private_key.pem"
private_key_password = ""

service_label = "vision"
region        = "us-ashburn-1"

use_enclosing_compartment = true
existing_enclosing_compartment_ocid = "ocid1.compartment.oc1..aaa...vves2a"

vcn_cidrs = ["192.168.0.0/16"]

exacs_vcn_cidrs           = ["10.0.0.0/20" , "10.1.0.0/20"]
exacs_vcn_names           = ["exavcn-dev"  , "exavcn-prd" ]
exacs_client_subnet_cidrs = ["10.0.0.0/24" , "10.1.0.0/24"]
exacs_backup_subnet_cidrs = ["10.0.1.0/28" , "10.1.1.0/28"]
deploy_exainfra_cmp       = true

hub_spoke_architecture = true

existing_drg_id = ocid1.drg.oc1.iad.aaa...7rv6xa

dmz_vcn_cidr = "172.16.0.0/24"
dmz_number_of_subnets = 3
dmz_for_firewall = true

public_src_lbr_cidrs     = ["0.0.0.0/0"] # HTTPS
public_src_bastion_cidrs = ["111.2.33.44/32"] # SSH

network_admin_email_endpoints  = ["john.doe@myorg.com"]
security_admin_email_endpoints = ["john.doe@myorg.com"]
exainfra_admin_email_endpoints = ["john.doe@myorg.com"]
