output "lz_top_compartment" {
    value = module.lz_top_compartment.compartments
}

output "lz_iam_admin_group" {
    value = length(module.lz_iam_admin_group) > 0 ? module.lz_iam_admin_group[0].group_name : null
}

output "lz_network_admin_group" {
    value = length(module.lz_network_admin_group) > 0 ? module.lz_network_admin_group[0].group_name : null
}

output "lz_security_admin_group" {
    value = length(module.lz_security_admin_group) > 0 ? module.lz_security_admin_group[0].group_name : null
}

output "lz_appdev_admin_group" {
    value = length(module.lz_appdev_admin_group) > 0 ? module.lz_appdev_admin_group[0].group_name : null
}

output "lz_database_admin_group" {
    value = length(module.lz_database_admin_group) > 0 ? module.lz_database_admin_group[0].group_name : null
}

output "lz_auditor_group" {
    value = length(module.lz_auditor_group) > 0 ? module.lz_auditor_group[0].group_name : null
}

output "lz_announcement_reader_group" {
    value = length(module.lz_announcement_reader_group) > 0 ? module.lz_announcement_reader_group[0].group_name : null
}