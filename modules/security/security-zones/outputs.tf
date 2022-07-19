# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# output "security_zone" {
#   description = "OCI Security Zone"
#   value       = oci_cloud_guard_security_zone.these
# }

# output "security_zone_recipe" {
#   description = "OCI Security Zone Recipe"
#   value       = oci_cloud_guard_security_recipe.this
# }



output "security_zone" {
  description = "The seccurity zones, indexed by keys."
  value = {for k, v in local.security_zones : k => oci_cloud_guard_security_zone.these[k]}
} 

output "security_zone_recipe" {
  description = "The seccurity zones, indexed by keys."
  value = {for k, v in local.security_zones : k => oci_cloud_guard_security_recipe.these[k]}
} 
