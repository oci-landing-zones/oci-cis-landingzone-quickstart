# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

#--------------------------------------------------------------------------------------------------------------
# The compartments variable defines a Terraform object describing a compartments topology with divisions (HR),
# lifecycle environments (DEV, PROD) and workloads (WORKLOAD-1, WORKLOAD-2).
# This object is passed into a generic Terraform module that creates any compartments topology in OCI.
# The object defines sub-objects indexed by uppercased strings, like SHARED-CMP, HR-CMP, DEV-CMP, etc.
# These strings can actually be any random strings, but once defined they MUST NOT BE CHANGED, 
# or Terraform will try to destroy and recreate the compartments.
#---------------------------------------------------------------------------------------------------------------


# ------------------------------------------------------
# ----- General
# ------------------------------------------------------

parent_compartment_id = "ocid1.compartment.oc1..aaaaaaaaazpbxtunsnblbdefwuxnmu5z7t7wgrfn4fp74g7ymfhfvnthf3ia" # Required
create_database_compartment = false
landing_zone_prefix = "iss216"
workload_compartment_user_group_name = "iss216-appdev-admin-group"
database_workload_compartment_user_group_name = "iss216-database-admin-group"
