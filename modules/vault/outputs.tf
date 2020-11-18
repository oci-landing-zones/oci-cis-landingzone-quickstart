# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "keys" {
  description = "Vault keys, indexed by the key display_name"
  value       = {for k in oci_kms_key.these : k.display_name => k}
}