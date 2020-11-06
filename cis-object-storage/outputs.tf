output "oci_objectstorage_buckets" {
     value = module.cis_buckets.oci_objectstorage_buckets
     sensitive = true
}
