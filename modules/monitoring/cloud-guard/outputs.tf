# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output cloud_guard_config {
  description = "Cloud Guard configuration information."
  value = oci_cloud_guard_cloud_guard_configuration.this
}

output cloud_guard_target {
  description = "Cloud Guard target information."
  value = length(oci_cloud_guard_target.this) > 0 ? oci_cloud_guard_target.this[0] : null
}

output "cloned_configuration_detector_recipe" {
  description = "Cloned Cloud Guard configuration detector recipe."  
  value = length(oci_cloud_guard_detector_recipe.configuration_cloned) > 0 ? oci_cloud_guard_detector_recipe.configuration_cloned[0] : null
}

output "cloned_activity_detector_recipe" {
  description = "Cloned Cloud Guard activity detector recipe."
  value = length(oci_cloud_guard_detector_recipe.activity_cloned) > 0 ? oci_cloud_guard_detector_recipe.activity_cloned[0] : null
}

output "cloned_threat_detector_recipe" {
  description = "Cloned Cloud Guard threat detector recipe."  
  value = length(oci_cloud_guard_detector_recipe.threat_cloned) > 0 ? oci_cloud_guard_detector_recipe.threat_cloned[0] : null
}

output "cloned_responder_recipe" {
  description = "Cloned Cloud Guard responder recipe."
  value = length(oci_cloud_guard_responder_recipe.responder_cloned) > 0 ? oci_cloud_guard_responder_recipe.responder_cloned[0] : null
}