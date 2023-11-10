# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "lz_top_compartments" {
  value = [ for c in module.lz_top_compartments.compartments : c.name ]
}
output "lz_provisioning_groups" {
  value = flatten([ for k in keys(local.enclosing_compartments) : [ for g in module.lz_provisioning_groups[k].groups : g.name ] if length(module.lz_provisioning_groups) > 0 ])
}
output "lz_groups" {
  value = flatten([ for k in keys(local.enclosing_compartments) : [ for g in module.lz_groups[k].groups : g.name ] if length(module.lz_groups) > 0 ])
}
output "lz_dynamic_groups" {
  value = flatten([ for k in keys(local.enclosing_compartments) : [ for g in module.lz_dynamic_groups[k].dynamic_groups : g.name ] if length(module.lz_dynamic_groups) > 0 ])
}