output "lz_top_compartments" {
    value = module.lz_top_compartments.compartments
}

output "lz_iam_admin_groups" {
    value = {for k in keys(local.enclosing_compartments) : k => module.lz_iam_admin_groups[k].group}
}

output "lz_cred_admin_groups" {
    value = {for k in keys(local.enclosing_compartments) : k => module.lz_cred_admin_groups[k].group}
}

output "lz_network_admin_groups" {
    value = {for k in keys(local.enclosing_compartments) : k => module.lz_network_admin_groups[k].group}
}

output "lz_security_admin_groups" {
    value = {for k in keys(local.enclosing_compartments) : k => module.lz_security_admin_groups[k].group}
}    

output "lz_appdev_admin_groups" {
    value = {for k in keys(local.enclosing_compartments) : k => module.lz_appdev_admin_groups[k].group}
}

output "lz_database_admin_groups" {
    value = {for k in keys(local.enclosing_compartments) : k => module.lz_database_admin_groups[k].group}
}

output "lz_auditor_groups" {
    value = {for k in keys(local.enclosing_compartments) : k => module.lz_auditor_groups[k].group}
}

output "lz_announcement_reader_groups" {
    value = {for k in keys(local.enclosing_compartments) : k => module.lz_announcement_reader_groups[k].group}
}