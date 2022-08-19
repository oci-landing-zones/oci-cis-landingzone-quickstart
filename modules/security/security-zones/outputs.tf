# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "security_zone_recipes" {
  description = "The seccurity zones recipes, indexed by keys."
  value = {for v in oci_cloud_guard_security_recipe.these : v.display_name => v}
} 

output "security_zones" {
  description = "The seccurity zones, indexed by keys."
  value = {for v in oci_cloud_guard_security_zone.these : v.display_name => v}
} 
