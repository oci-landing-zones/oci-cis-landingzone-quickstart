# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "bastions" {
  description = "The bastions, indexed by name."
  value       = { for b in oci_bastion_bastion.these : b.name => b }
}
