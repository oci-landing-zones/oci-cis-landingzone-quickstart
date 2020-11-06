# Object Storage Namespace
data "oci_objectstorage_namespace" "bucket_namespace" {

    #Optional
    compartment_id = var.compartment_id
}

resource "oci_objectstorage_bucket" "storage_bucket" {
    compartment_id = var.compartment_id
    name = var.bucket_name
    namespace = data.oci_objectstorage_namespace.bucket_namespace.namespace
    
    #Fill in with Vault
    kms_key_id = var.kms_key_id

    # Check Get the tag and namespace
    #defined_tags = {"Operations.CostCenter"= "42"}
    #freeform_tags = {"Department"= "Finance"}
}

data "terraform_remote_state" "object-storage" {
  backend = "local"
  config = {
    path = "../cis-object-storage/terraform.tfstate"
  }
}