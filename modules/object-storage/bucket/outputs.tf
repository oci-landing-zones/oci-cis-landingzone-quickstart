# Output Buckets indexed by bucket name
output "oci_objectstorage_buckets" {
  description = "The buckets, indexed by bucket name."
  value = {
    for bkt in oci_objectstorage_bucket.these:
      bkt.name => bkt
}
}
