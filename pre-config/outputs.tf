# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "lz_top_compartments" {
  value = module.lz_top_compartments.compartments
}
output "lz_provisioning_groups" {
  value = { for k in keys(local.enclosing_compartments) : k => module.lz_provisioning_groups[k].groups if length(module.lz_provisioning_groups) > 0 }
}
output "lz_groups" {
  value = { for k in keys(local.enclosing_compartments) : k => module.lz_groups[k].groups if length(module.lz_groups) > 0 }
}
output "lz_dynamic_groups" {
  value = { for k in keys(local.enclosing_compartments) : k => module.lz_dynamic_groups[k].dynamic_groups if length(module.lz_dynamic_groups) > 0 }
}
output "home_region" {
    value = var.home_region
}
output "release" {
    value = fileexists("${path.module}/../release.txt") ? file("${path.module}/../release.txt") : "undefined"
}
output "unique_prefix" {
    value = var.unique_prefix
}