### Create Private Vault and Customer Managed Key
module "cis_vault" {
    source             = "../modules/object-storage/vault"
    tenancy_ocid = var.tenancy_ocid
    compartment_id     = data.terraform_remote_state.iam.outputs.security_compartment_id
    compartment_name = local.security_compartment_name
    vault_name = local.vault_name
    vault_type = local.vault_type
    key_display_name = local.key_display_name
    key_key_shape_algorithm = local.key_key_shape_algorithm
    key_key_shape_length = local.key_key_shape_length
    service_label = local.service_label
    region = var.region
    defined_tags = {(data.terraform_remote_state.iam.outputs.rotateby_full_tag_name) = time_offset.expiry_time.rfc3339}
}  

terraform {
  required_providers {
    time = {
      source = "hashicorp/time"
      version = "0.6.0"
    }
  }
}

resource "time_offset" "expiry_time" {
  offset_days = 7
}

### Creates a bucket *in* the specified compartment 
module "cis_buckets" {
    source             = "../modules/object-storage/bucket"
    region = var.region
    tenancy_ocid = var.tenancy_ocid
    depends_on = [module.cis_vault]
    kms_key_id = module.cis_vault.key_id
    buckets = {
        "${var.service_label}-ComputeBucket" = {
            compartment_id = data.terraform_remote_state.iam.outputs.compute_storage_compartment_id
        },
        "${var.service_label}-AppDevBucket" = {
            compartment_id = data.terraform_remote_state.iam.outputs.appdev_compartment_id
        }
    }

    
}  

