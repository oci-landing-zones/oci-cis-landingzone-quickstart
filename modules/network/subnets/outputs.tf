# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "subnets" {
  description = "The returned resource attributes for the subnets."
  value       = oci_core_subnet.this != null && length(oci_core_subnet.this) > 0 ? {
    for x in oci_core_subnet.this:
      x.display_name => x
  } : null
}

output "ads" {
  description = "The available Availability Domains."
  value       = data.oci_identity_availability_domains.this
}