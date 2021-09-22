module "lz_drg" {
  source         = "../modules/network/drg"
  depends_on     = [ null_resource.slow_down_drg ]
  compartment_id = module.lz_compartments.compartments[local.network_compartment.key].id
  service_label  = var.service_label
  is_create_drg  = (var.is_vcn_onprem_connected == true || var.hub_spoke_architecture) && var.existing_drg_id == ""
}

resource "null_resource" "slow_down_drg" {
   depends_on = [ module.lz_compartments ]
   provisioner "local-exec" {
     command = "sleep ${local.delay_in_secs}" # Wait for compartments to be available.
   }
}