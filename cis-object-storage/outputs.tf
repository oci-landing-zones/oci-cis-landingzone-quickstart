output "object_storage_bucket" {
    value = module.cis_buckets.object_storage_bucket
    sensitive = true
}
