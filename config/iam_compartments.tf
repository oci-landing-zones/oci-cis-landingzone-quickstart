# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  #------------------------------------------------------------------------------------------------------
  #-- Any of these local variables can be overriden in a _override.tf file
  #------------------------------------------------------------------------------------------------------
  
  custom_cmps_defined_tags  = null
  custom_cmps_freeform_tags = null

  custom_enclosing_compartment_name = null
  custom_security_compartment_name  = null
  custom_network_compartment_name   = null
  custom_appdev_compartment_name    = null
  custom_database_compartment_name  = null
  custom_exainfra_compartment_name  = null
}

module "lz_top_compartment" {
  count     = var.extend_landing_zone_to_new_region == false && var.use_enclosing_compartment == true && var.existing_enclosing_compartment_ocid == null ? 1 : 0
  source = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam//compartments?ref=v0.1.6"
  providers = { oci = oci.home }
  tenancy_ocid = var.tenancy_ocid
  compartments_configuration = local.enclosing_compartment_configuration
}

module "lz_compartments" {
  source = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam//compartments?ref=v0.1.6"
  providers = { oci = oci.home }
  tenancy_ocid = var.tenancy_ocid
  compartments_configuration = var.extend_landing_zone_to_new_region == false ? local.enclosed_compartments_configuration : local.empty_compartments_configuration
}

locals {
  #------------------------------------------------------------------------------------------------------
  #-- These variables are not meant to be overriden
  #------------------------------------------------------------------------------------------------------

  #-- Enable compartment variables for future usage.
  enable_enclosing_compartment = true 
  enable_network_compartment   = true 
  enable_security_compartment  = true 
  enable_appdev_compartment    = true 
  enable_database_compartment  = true 
  enable_exainfra_compartment  = var.deploy_exainfra_cmp
  
  #-----------------------------------------------------------
  #----- Tags to apply to compartments
  #-----------------------------------------------------------
  default_cmps_defined_tags = null
  default_cmps_freeform_tags = local.landing_zone_tags

  cmps_defined_tags = local.custom_cmps_defined_tags != null ? merge(local.custom_cmps_defined_tags, local.default_cmps_defined_tags) : local.default_cmps_defined_tags
  cmps_freeform_tags = local.custom_cmps_freeform_tags != null ? merge(local.custom_cmps_freeform_tags, local.default_cmps_freeform_tags) : local.default_cmps_freeform_tags

  #-----------------------------------------------------------
  #----- Enclosing compartment definition
  #-----------------------------------------------------------
  enclosing_compartment_key = "${var.service_label}-top-cmp"
  default_enclosing_compartment_name = "top-cmp"
  provided_enclosing_compartment_name = local.custom_enclosing_compartment_name != null ? local.custom_enclosing_compartment_name : "${var.service_label}-${local.default_enclosing_compartment_name}"

  enclosing_cmp = local.enable_enclosing_compartment ? { 
    (local.enclosing_compartment_key) : { 
      name : local.provided_enclosing_compartment_name, 
      description : "CIS Landing Zone enclosing compartment", 
      defined_tags : local.cmps_defined_tags, 
      freeform_tags : local.cmps_freeform_tags,
      children : {}
    }   
  } : {}

  #-----------------------------------------------------------
  #----- Enclosed compartments definition
  #-----------------------------------------------------------
  
  network_compartment_key  = "${var.service_label}-network-cmp"
  default_network_compartment_name = "network-cmp"
  provided_network_compartment_name = local.custom_network_compartment_name != null ? local.custom_network_compartment_name : "${var.service_label}-${local.default_network_compartment_name}"

  network_cmp = local.enable_network_compartment ? {
    (local.network_compartment_key) : { 
      name : local.provided_network_compartment_name, 
      description : "CIS Landing Zone compartment for all network related resources: VCNs, subnets, network gateways, security lists, NSGs, load balancers, VNICs, and others.", 
      defined_tags : local.cmps_defined_tags, 
      freeform_tags : local.cmps_freeform_tags,
      children : {}
    }
  } : {}

  security_compartment_key = "${var.service_label}-security-cmp"
  default_security_compartment_name = "security-cmp"
  provided_security_compartment_name = local.custom_security_compartment_name != null ? local.custom_security_compartment_name : "${var.service_label}-${local.default_security_compartment_name}"

  security_cmp = local.enable_security_compartment ? {
    (local.security_compartment_key) : { 
      name : local.provided_security_compartment_name, 
      description : "CIS Landing Zone compartment for all security related resources: vaults, topics, notifications, logging, scanning, and others.", 
      defined_tags : local.cmps_defined_tags,
      freeform_tags : local.cmps_freeform_tags,
      children : {}
    }
  } : {}    

  appdev_compartment_key   = "${var.service_label}-appdev-cmp"
  default_appdev_compartment_name = "appdev-cmp"
  provided_appdev_compartment_name = local.custom_appdev_compartment_name != null ? local.custom_appdev_compartment_name : "${var.service_label}-${local.default_appdev_compartment_name}"

  appdev_cmp = local.enable_appdev_compartment ? {
    (local.appdev_compartment_key) : { 
      name : local.provided_appdev_compartment_name, 
      description : "CIS Landing Zone compartment for all resources related to application development: compute instances, storage, functions, OKE, API Gateway, streaming, and others.", 
      defined_tags : local.cmps_defined_tags,
      freeform_tags : local.cmps_freeform_tags,
      children : {}
    }
  } : {}    
  
  database_compartment_key = "${var.service_label}-database-cmp"
  default_database_compartment_name = "database-cmp"
  provided_database_compartment_name = local.custom_database_compartment_name != null ? local.custom_database_compartment_name : "${var.service_label}-${local.default_database_compartment_name}"

  database_cmp = local.enable_database_compartment ? {
    (local.database_compartment_key) : { 
      name : local.provided_database_compartment_name, 
      description : "CIS Landing Zone compartment for all database related resources.", 
      defined_tags : local.cmps_defined_tags,
      freeform_tags : local.cmps_freeform_tags,
      children : {}
    }
  } : {}    
  
  exainfra_compartment_key = "${var.service_label}-exainfra-cmp"
  default_exainfra_compartment_name = "exainfra-cmp"
  provided_exainfra_compartment_name = local.custom_exainfra_compartment_name != null ? local.custom_exainfra_compartment_name : "${var.service_label}-${local.default_exainfra_compartment_name}"

  exainfra_cmp = local.enable_exainfra_compartment ? {
    (local.exainfra_compartment_key) : { 
      name : local.provided_exainfra_compartment_name, 
      description : "CIS Landing Zone compartment for Exadata Cloud Service infrastructure.", 
      defined_tags : local.cmps_defined_tags,
      freeform_tags : local.cmps_freeform_tags,
      children : {}
    } 
  } : {}    

  #------------------------------------------------------------------------
  #----- Enclosing compartment configuration definition. Input to module.
  #------------------------------------------------------------------------  
  enclosing_compartment_configuration = {
    default_parent_id : var.tenancy_ocid
    compartments : local.enclosing_cmp
  }

  #------------------------------------------------------------------------
  #----- Enclosing compartment configuration definition. Input to module.
  #------------------------------------------------------------------------
  enclosed_compartments_configuration = {
    default_parent_id : local.enclosing_compartment_id
    compartments : merge(local.network_cmp, local.security_cmp, local.appdev_cmp, local.database_cmp, local.exainfra_cmp)
  }

  empty_compartments_configuration = {
    default_parent_id : null
    compartments : {}
  }

  #----------------------------------------------------------------------------------
  #----- Variables with compartment names and OCIDs per compartments module output
  #----------------------------------------------------------------------------------
  enclosing_compartment_name = var.use_enclosing_compartment == true ? (var.existing_enclosing_compartment_ocid != null ? data.oci_identity_compartment.existing_enclosing_compartment.name : local.provided_enclosing_compartment_name /*module.lz_top_compartment[0].compartments[local.enclosing_compartment_key].name*/) : "tenancy"
  enclosing_compartment_id   = var.use_enclosing_compartment == true ? (var.existing_enclosing_compartment_ocid != null ? var.existing_enclosing_compartment_ocid : module.lz_top_compartment[0].compartments[local.enclosing_compartment_key].id) : var.tenancy_ocid

  security_compartment_name = var.extend_landing_zone_to_new_region == false ? module.lz_compartments.compartments[local.security_compartment_key].name : local.provided_security_compartment_name
  security_compartment_id   = var.extend_landing_zone_to_new_region == false ? module.lz_compartments.compartments[local.security_compartment_key].id : data.oci_identity_compartments.security.compartments[0].id

  network_compartment_name = var.extend_landing_zone_to_new_region == false ? module.lz_compartments.compartments[local.network_compartment_key].name : local.provided_network_compartment_name
  network_compartment_id   = var.extend_landing_zone_to_new_region == false ? module.lz_compartments.compartments[local.network_compartment_key].id : data.oci_identity_compartments.network.compartments[0].id

  appdev_compartment_name = var.extend_landing_zone_to_new_region == false ? module.lz_compartments.compartments[local.appdev_compartment_key].name : local.provided_appdev_compartment_name
  appdev_compartment_id   = var.extend_landing_zone_to_new_region == false ? module.lz_compartments.compartments[local.appdev_compartment_key].id : data.oci_identity_compartments.appdev.compartments[0].id
  
  database_compartment_name = var.extend_landing_zone_to_new_region == false ? module.lz_compartments.compartments[local.database_compartment_key].name : local.provided_database_compartment_name
  database_compartment_id   = var.extend_landing_zone_to_new_region == false ? module.lz_compartments.compartments[local.database_compartment_key].id : data.oci_identity_compartments.database.compartments[0].id
  
  exainfra_compartment_name = var.extend_landing_zone_to_new_region == false && var.deploy_exainfra_cmp == true ? module.lz_compartments.compartments[local.exainfra_compartment_key].name : local.provided_exainfra_compartment_name
  exainfra_compartment_id   = var.extend_landing_zone_to_new_region == false && var.deploy_exainfra_cmp == true ? module.lz_compartments.compartments[local.exainfra_compartment_key].id : length(data.oci_identity_compartments.exainfra.compartments) > 0 ? data.oci_identity_compartments.exainfra.compartments[0].id : "exainfra_cmp_undefined"
}