tenancy_ocid         = "ocid1.tenancy.oc1..aaa...ir7xdq"
user_ocid            = "ocid1.user.oc1..aaa...kxyuif"
fingerprint          = "g1:77:53:...:12:23:45:18"
private_key_path     = "../private_key.pem"
private_key_password = ""

service_label = "vision"
region        = "us-ashburn-1"

use_enclosing_compartment = true
existing_enclosing_compartment_ocid = "ocid1.compartment.oc1..aaa...xxft3b" # cis_lz_dev compartment OCID
policies_in_root_compartment = "USE"
existing_iam_admin_group_name      = "vision-iam-admin-group"
existing_cred_admin_group_name     = "vision-cred-admin-group"
existing_security_admin_group_name = "vision-security-admin-group"
existing_network_admin_group_name  = "vision-network-admin-group"
existing_appdev_admin_group_name   = "vision-appdev-admin-group"
existing_database_admin_group_name = "vision-database-admin-group"
existing_exinfra_admin_group_name  = "vision-exainfra-admin-group"
existing_auditor_group_name        = "vision-auditor-group"
existing_announcement_reader_group_name = "vision-announcement-reader-group"

# (...) Variable assignments according to your particular network topology requirements. See previous examples.

# (...) Other variable assignments
