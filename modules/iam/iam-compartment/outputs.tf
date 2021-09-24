# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "compartments" {
  description = "The compartments, indexed by keys in var.compartments."
  value = {for k, v in var.compartments : k => oci_identity_compartment.these[k]}
} 