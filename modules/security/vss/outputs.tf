# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "vss_recipes" {
  description = "The VSS recipes, including custom ones."
  value       = merge(oci_vulnerability_scanning_host_scan_recipe.these, oci_vulnerability_scanning_host_scan_recipe.custom)
}

output "vss_targets" {
  description = "The VSS targets, including custom ones."
  value       = merge(oci_vulnerability_scanning_host_scan_target.these, oci_vulnerability_scanning_host_scan_target.custom)
}