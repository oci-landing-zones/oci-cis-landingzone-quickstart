# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "key_id" {
  description = "Custmer Managed Key ID"
  value       = oci_kms_key.this.id
}