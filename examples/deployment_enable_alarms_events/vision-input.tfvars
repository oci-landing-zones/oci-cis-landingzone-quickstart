tenancy_ocid         = "ocid1.tenancy.oc1..aaa...ir7xdq"
user_ocid            = "ocid1.user.oc1..aaa...yfhyvq"
fingerprint          = "c1:91:41:...:36:76:54:39"
private_key_path     = "../private_key.pem"
private_key_password = ""

service_label = "vision"
region        = "us-ashburn-1"

# (...) Variable assignments according to your particular network topology requirements. See previous examples.

network_admin_email_endpoints  = ["john.doe@myorg.com"]
security_admin_email_endpoints = ["john.doe@myorg.com"]
storage_admin_email_endpoints  = ["john.doe@myorg.com"]
compute_admin_email_endpoints  = ["john.doe@myorg.com"]
budget_admin_email_endpoints   = ["john.doe@myorg.com"]
database_admin_email_endpoints = ["john.doe@myorg.com"]
exainfra_admin_email_endpoints = ["john.doe@myorg.com"]
create_alarms_as_enabled = true
create_events_as_enabled = true      
