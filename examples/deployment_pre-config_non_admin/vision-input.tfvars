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
existing_iam_admin_group_name      = "xyz-iam-admin-group"
existing_cred_admin_group_name     = "xyz-cred-admin-group"
existing_security_admin_group_name = "xyz-security-admin-group"
existing_network_admin_group_name  = "xyz-network-admin-group"
existing_appdev_admin_group_name   = "xyz-appdev-admin-group"
existing_database_admin_group_name = "xyz-database-admin-group"
existing_exinfra_admin_group_name  = "xyz-exainfra-admin-group"
existing_auditor_group_name        = "xyz-auditor-group"
existing_announcement_reader_group_name = "xyz-announcement-reader-group"

# (...) Variable assignments according to your particular network topology requirements. See previous examples.

# (...) Other variable assignments
