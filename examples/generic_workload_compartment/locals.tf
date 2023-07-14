# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  ### Discovering the home region name and region key.
  home_region_key           = data.oci_identity_tenancy.this.home_region_key # Home region key obtained from the tenancy data source
  parent_compartment_name   = data.oci_identity_compartment.parent_compartment_name.name
  
  workload_compartment_name = var.workload_compartment_name
  database_compartment_name = var.database_compartment_name

}