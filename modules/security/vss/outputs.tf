output "vss_recipes" {
  description = "VSS recipes, indexed by recipe name."
  value       = {for r in oci_vulnerability_scanning_host_scan_recipe.these : r.display_name => r}
}

output "vss_targets" {
  description = "VSS targets, indexed by target name."
  value       = {for t in oci_vulnerability_scanning_host_scan_target.these : t.display_name => t}
}