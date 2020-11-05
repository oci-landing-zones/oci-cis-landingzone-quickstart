output "keys_requiring_rotation" {
    value = formatdate("YYYYMMDDhhmmss", timestamp())
     /* value = [for k in data.oci_kms_keys.these.keys : "Please rotate key ${k.display_name}." 
                if timeadd(formatdate("YYYY-MM-DD'T'hh:mm:ssZ",k.time_created),"8760h") < timeadd(timestamp(),"0h")
             ]  */
}

data "oci_kms_keys" "these" {
    compartment_id      = data.terraform_remote_state.iam.outputs.security_compartment_id
    management_endpoint = "https://bbp2f47gaacuu-management.kms.${var.region}.oraclecloud.com/20180608/keys"
}