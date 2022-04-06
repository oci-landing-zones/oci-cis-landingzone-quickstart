tenancy_ocid         = "ocid1.tenancy.oc1..aaa...ir7xdq"
user_ocid            = "ocid1.user.oc1..aaa...yfhyvq"
fingerprint          = "c1:91:41:...:36:76:54:39"
private_key_path     = "../private_key.pem"
private_key_password = ""

service_label = "vision"
region        = "us-ashburn-1"

# (...) Variable assignments according to your particular network topology requirements. See previous examples.

# (...) Endpoint notifications assignments. See example above.

create_service_connector_audit = true
service_connector_audit_state = "ACTIVE"
service_connector_audit_target = "streaming"
service_connector_audit_target_OCID = "ocid1.stream.oc1.phx.ama...qkb5ya"
create_service_connector_vcnFlowLogs = true
service_connector_vcnFlowLogs_state = "ACTIVE"
service_connector_vcnFlowLogs_target = "streaming"
service_connector_vcnFlowLogs_target_OCID = "ocid1.stream.oc1.phx.ama...qkb5ya"
