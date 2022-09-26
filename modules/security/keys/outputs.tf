# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "keys" {
  description = "The managed keys."
  value       = oci_kms_key.these
}  
