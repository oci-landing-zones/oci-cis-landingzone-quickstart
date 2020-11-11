# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "oci_objectstorage_buckets" {
     value = module.cis_buckets.oci_objectstorage_buckets
     sensitive = true
}
