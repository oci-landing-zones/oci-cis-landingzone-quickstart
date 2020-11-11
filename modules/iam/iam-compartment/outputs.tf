# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "compartments" {
  value = {for c in data.oci_identity_compartments.these.compartments : c.name => c}
} 