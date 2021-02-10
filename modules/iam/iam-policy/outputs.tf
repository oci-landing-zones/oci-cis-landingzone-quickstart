# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "policies" {
  description = "The policies, are indexed by name."
  value = {for c in oci_identity_policy.these : c.name => c}
} 